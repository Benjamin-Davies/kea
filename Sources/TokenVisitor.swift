import Foundation
import SwiftSyntax

func tokens(_ syntax: SourceFileSyntax, exceptions: Exceptions) -> [Token] {
    let visitor = TokenVisitor(exceptions: exceptions)
    visitor.walk(syntax)
    return visitor.tokens
}

private class TokenVisitor: SyntaxVisitor {
    let exceptions: Exceptions

    var tokens: [Token] = []
    var depth: UInt = 0
    var triviaDepth: UInt = 0

    init(exceptions: Exceptions) {
        self.exceptions = exceptions
        super.init(viewMode: .sourceAccurate)
    }

    func visit(_ node: Trivia) {
        for piece in node {
            switch piece {
            case .spaces, .tabs:
                break
            case .newlines(let count), .carriageReturns(let count),
                .carriageReturnLineFeeds(let count):
                if count >= 2 {
                    updateLastToken { $0.doubleNewline = true }
                }
            case .lineComment(let comment), .docLineComment(let comment):
                updateLastToken {
                    $0.stickiness = triviaDepth
                }
                tokens.append(Token(comment.trimmingCharacters(in: .whitespacesAndNewlines)))
                updateLastToken {
                    $0.stickiness = triviaDepth
                    $0.newline = true
                }
            case .blockComment(let comment), .docBlockComment(let comment):
                updateLastToken {
                    $0.stickiness = triviaDepth
                }
                tokens.append(Token(comment))
                updateLastToken {
                    $0.stickiness = triviaDepth
                }
            default:
                fatalError("TODO: \(piece.debugDescription)")
            }
        }
    }

    override func visit(_ node: TokenSyntax) -> SyntaxVisitorContinueKind {
        visit(node.leadingTrivia)

        if node.text.last == "\n" {
            tokens.append(Token(String(node.text.dropLast())))
            updateLastToken {
                $0.stickiness = depth - 1
                $0.newline = true
            }
        } else if node.tokenKind != .endOfFile {
            tokens.append(Token(node.text))
        }
        updateLastToken {
            switch node.tokenKind {
            case .atSign, .backslash, .period, .prefixAmpersand, .prefixOperator:
                $0.attachRight = true
            case .comma, .colon, .semicolon, .exclamationMark, .postfixQuestionMark, .postfixOperator:
                $0.attachLeft = true
            case .ellipsis, .stringSegment, .binaryOperator("..."), .binaryOperator("..<"):
                $0.attachLeft = true
                $0.attachRight = true

            case .leftBrace:
                $0.stickiness = depth
                $0.startIndent = true
            case .rightBrace:
                $0.endIndent = true
            case .leftAngle, .leftParen, .leftSquare:
                $0.attachRight = true
                $0.startIndent = true
            case .rightAngle, .rightParen, .rightSquare:
                $0.attachLeft = true
                $0.endIndent = true

            default:
                break
            }
        }
        triviaDepth = depth

        visit(node.trailingTrivia)

        return .visitChildren
    }

    // Non-leaf nodes

    override func visit(_ node: AccessorDeclSyntax) -> SyntaxVisitorContinueKind {
        updateLastToken {
            $0.stickiness = depth
        }
        recurse(node.attributes)
        recurse(node.modifier)
        recurse(node.accessorSpecifier)
        recurse(node.parameters)
        recurse(node.effectSpecifiers)
        recurse(node.body) {
            $0.stickiness = depth
        }

        return .skipChildren
    }

    override func visit(_ node: ArrayElementListSyntax) -> SyntaxVisitorContinueKind {
        recurse(collection: node, allowTrailingComma: true) {
            recurse($0.expression)
        } trailingComma: {
            $0.trailingComma
        }

        return .skipChildren
    }

    override func visit(_ node: AttributeSyntax) -> SyntaxVisitorContinueKind {
        recurse(node.atSign)
        recurse(node.attributeName)
        recurse(node.leftParen) {
            $0.attachLeft = true
        }
        recurse(node.arguments)
        recurse(node.rightParen)

        updateLastToken {
            $0.stickiness = depth
            $0.newline = true
        }

        return .skipChildren
    }

    override func visit(_ node: CatchItemListSyntax) -> SyntaxVisitorContinueKind {
        for element in node {
            // Artifically increase the depth of catch conditions
            recurse(element)
        }

        return .skipChildren
    }

    override func visit(_ node: ClosureExprSyntax) -> SyntaxVisitorContinueKind {
        let multiLine = !exceptions.singleLineItemLists.contains(node.statements)

        recurse(node.leftBrace) {
            $0.stickiness = .max
        }
        recurse(node.signature)
        updateLastToken {
            if multiLine {
                $0.stickiness = 0
            }
            $0.startIndent = true
        }

        recurse(node.statements) {
            if multiLine {
                $0.stickiness = 0
            }
            $0.newline = multiLine
        }

        recurse(node.rightBrace)

        return .skipChildren
    }

    override func visit(_ node: CodeBlockItemListSyntax) -> SyntaxVisitorContinueKind {
        let singleLine = exceptions.singleLineItemLists.contains(node)

        updateLastToken {
            if node.isEmpty && $0.text == "{" {
                $0.attachRight = true
                $0.newline = false
            }
        }

        for item in node {
            recurse(item) {
                $0.stickiness = depth
                if singleLine {
                    $0.newline = false
                }
            }
        }

        return .skipChildren
    }

    override func visit(_ node: CodeBlockItemSyntax) -> SyntaxVisitorContinueKind {
        switch node.item {
        case .decl(let decl):
            recurse(decl)
        case .stmt(let stmt):
            recurse(stmt)
        case .expr(let expr):
            recurse(expr)
        }
        updateLastToken {
            $0.stickiness = depth
            $0.newline = true
        }

        return .skipChildren
    }

    override func visit(_ node: DictionaryElementListSyntax) -> SyntaxVisitorContinueKind {
        updateLastToken {
            if node.count > 1 {
                $0.newline = true
            }
        }

        recurse(collection: node, allowTrailingComma: true) {
            recurse($0.key)
            recurse($0.colon)
            recurse($0.value)
        } trailingComma: {
            $0.trailingComma
        }

        return .skipChildren
    }

    override func visit(_ node: EnumCaseParameterClauseSyntax) -> SyntaxVisitorContinueKind {
        recurse(node.leftParen) {
            $0.attachLeft = true
        }
        recurse(node.parameters)
        recurse(node.rightParen)

        return .skipChildren
    }

    override func visit(_ node: FunctionCallExprSyntax) -> SyntaxVisitorContinueKind {
        // Use walk, not recurse, so that method chains have a constant depth
        walk(node.calledExpression)

        recurse(node.leftParen) {
            $0.attachLeft = true
        }
        recurse(node.arguments)
        recurse(node.rightParen)
        recurse(node.trailingClosure)
        recurse(node.additionalTrailingClosures)

        return .skipChildren
    }

    override func visit(_ node: FunctionDeclSyntax) -> SyntaxVisitorContinueKind {
        recurse(node.attributes)
        recurse(node.modifiers)
        recurse(node.funcKeyword)
        recurse(node.name)
        recurse(node.genericParameterClause)
        recurse(node.signature)
        recurse(node.genericWhereClause)
        recurse(node.body)

        return .skipChildren
    }

    override func visit(_ node: FunctionParameterClauseSyntax) -> SyntaxVisitorContinueKind {
        recurse(node.leftParen) {
            $0.attachLeft = true
        }
        recurse(node.parameters)
        recurse(node.rightParen)

        return .skipChildren
    }

    override func visit(_ node: GenericArgumentClauseSyntax) -> SyntaxVisitorContinueKind {
        recurse(node.leftAngle) {
            $0.attachLeft = true
        }
        recurse(node.arguments)
        recurse(node.rightAngle)

        return .skipChildren
    }

    override func visit(_ node: GenericParameterClauseSyntax) -> SyntaxVisitorContinueKind {
        recurse(node.leftAngle) {
            $0.attachLeft = true
        }
        recurse(node.parameters)
        recurse(node.genericWhereClause)
        recurse(node.rightAngle)

        return .skipChildren
    }

    override func visit(_ node: GenericWhereClauseSyntax) -> SyntaxVisitorContinueKind {
        updateLastToken {
            $0.stickiness = depth
        }
        recurse(node.whereKeyword) {
            $0.hangingIndent = true
        }
        recurse(node.requirements) {
            $0.stickiness = depth
        }

        return .skipChildren
    }

    override func visit(_ node: GuardStmtSyntax) -> SyntaxVisitorContinueKind {
        recurse(conditional: node.guardKeyword, node.conditions, node.elseKeyword, body: node.body)

        return .skipChildren
    }

    override func visit(_ node: IfExprSyntax) -> SyntaxVisitorContinueKind {
        recurse(conditional: node.ifKeyword, node.conditions, body: node.body)
        recurse(node.elseKeyword)
        recurse(node.elseBody)

        return .skipChildren
    }

    override func visit(_ node: LabeledExprListSyntax) -> SyntaxVisitorContinueKind {
        recurse(collection: node) {
            recurse($0.label)
            recurse($0.colon)
            recurse($0.expression)
        } trailingComma: {
            $0.trailingComma
        }

        if exceptions.hangingLists.contains(node) {
            updateLastToken {
                $0.stickiness = .max
            }
        }

        return .skipChildren
    }

    override func visit(_ node: MemberAccessExprSyntax) -> SyntaxVisitorContinueKind {
        if let base = node.base {
            // Use walk, not recurse, so that method chains have a constant depth
            walk(base)
            updateLastToken {
                $0.stickiness = depth
            }
        }

        recurse(node.period) {
            if node.base != nil {
                $0.attachLeft = true
                $0.hangingIndent = true
            }
        }
        recurse(node.declName)

        return .skipChildren
    }

    override func visit(_ node: MemberBlockItemSyntax) -> SyntaxVisitorContinueKind {
        recurse(node.decl) {
            $0.stickiness = depth
            $0.newline = true
        }

        if let semicolon = node.semicolon {
            visit(semicolon.trailingTrivia)
        }

        return .skipChildren
    }

    override func visit(_ node: MemberTypeSyntax) -> SyntaxVisitorContinueKind {
        recurse(node.baseType)
        recurse(node.period) {
            $0.attachLeft = true
            $0.hangingIndent = true
        }
        recurse(node.name)
        recurse(node.genericArgumentClause)

        return .skipChildren
    }

    override func visit(_ node: StringLiteralExprSyntax) -> SyntaxVisitorContinueKind {
        recurse(node.openingPounds) {
            $0.attachRight = true
        }
        recurse(node.openingQuote) {
            if node.openingQuote.text == #"""""# {
                $0.stickiness = depth
                $0.newline = true
            }
        }

        for segment in node.segments {
            recurse(segment) {
                $0.doubleHangingIndent = true
            }
        }

        if node.closingQuote.text == #"""""# {
            updateLastToken {
                $0.stickiness = depth
                $0.newline = true
            }
        }
        recurse(node.closingQuote) {
            $0.doubleHangingIndent = true
        }
        recurse(node.closingPounds) {
            $0.attachLeft = true
        }

        return .skipChildren
    }

    override func visit(_ node: SubscriptCallExprSyntax) -> SyntaxVisitorContinueKind {
        // Use walk, not recurse, so that method chains have a constant depth
        walk(node.calledExpression)

        recurse(node.leftSquare) {
            $0.attachLeft = true
        }
        recurse(node.arguments)
        recurse(node.rightSquare)
        recurse(node.trailingClosure)
        recurse(node.additionalTrailingClosures)

        return .skipChildren
    }

    override func visit(_ node: SwitchCaseLabelSyntax) -> SyntaxVisitorContinueKind {
        recurse(node.caseKeyword) {
            $0.endIndent = true
        }
        recurse(node.caseItems)
        recurse(node.colon) {
            $0.startIndent = true
        }

        return .skipChildren
    }

    override func visit(_ node: SwitchCaseSyntax) -> SyntaxVisitorContinueKind {
        recurse(node.attribute)
        recurse(node.label) {
            $0.stickiness = depth
            $0.newline = true
        }
        recurse(node.statements)

        return .skipChildren
    }

    override func visit(_ node: SwitchDefaultLabelSyntax) -> SyntaxVisitorContinueKind {
        recurse(node.defaultKeyword) {
            $0.endIndent = true
        }
        recurse(node.colon) {
            $0.startIndent = true
        }

        return .skipChildren
    }

    override func visit(_ node: SwitchExprSyntax) -> SyntaxVisitorContinueKind {
        recurse(node.switchKeyword)
        recurse(node.subject)
        recurse(node.leftBrace) {
            $0.stickiness = depth
        }
        for c in node.cases {
            recurse(c) {
                $0.stickiness = depth
            }
        }
        recurse(node.rightBrace) {
            $0.endIndent = true
        }

        return .skipChildren
    }

    override func visit(_ node: TernaryExprSyntax) -> SyntaxVisitorContinueKind {
        recurse(node.condition)
        recurse(node.questionMark)
        recurse(node.thenExpression)
        recurse(node.colon) {
            $0.attachLeft = false
        }
        recurse(node.elseExpression)

        return .skipChildren
    }

    override func visit(_ node: WhileStmtSyntax) -> SyntaxVisitorContinueKind {
        recurse(conditional: node.whileKeyword, node.conditions, body: node.body)

        return .skipChildren
    }

    // Helpers

    func recurse(_ node: (some SyntaxProtocol)?, f: (inout Token) -> Void = { _ in }) {
        if let node {
            if let token = TokenSyntax(node) {
                _ = visit(token)
            } else {
                depth += 1
                walk(node)
                depth -= 1
                triviaDepth = depth
            }

            updateLastToken(f: f)
        }
    }

    func recurse<C: SyntaxCollection>(
        collection node: C, allowTrailingComma: Bool = false, recurseChild: (C.Element) -> Void,
        trailingComma: (C.Element) -> TokenSyntax?
    ) {
        updateLastToken {
            $0.stickiness = depth
        }

        for (i, element) in node.enumerated() {
            recurseChild(element)

            let trailing = i == node.count - 1
            if !trailing || allowTrailingComma {
                tokens.append(Token(","))
                updateLastToken {
                    $0.attachLeft = true
                    $0.stickiness = triviaDepth
                    $0.omitIfNotLastOnLine = trailing
                }
                triviaDepth = depth
            }

            if let comma = trailingComma(element) {
                visit(comma.trailingTrivia)
            }

            updateLastToken {
                $0.stickiness = triviaDepth
            }
        }
    }

    func recurse(conditional keyword: TokenSyntax, _ conditions: ConditionElementListSyntax, _ secondKeyword: TokenSyntax? = nil, body: CodeBlockSyntax) {
        if conditions.count <= 1 {
            recurse(keyword)
            depth += 1
            recurse(conditions)
            depth -= 1
            recurse(secondKeyword)
            recurse(body)
            return
        }

        recurse(keyword)

        depth += 1
        recurse(conditions.first) {
            $0.startIndent = true
            $0.stickiness = depth
        }
        for condition in conditions.dropFirst() {
            recurse(condition) {
                $0.stickiness = depth
            }
        }
        depth -= 1

        if let secondKeyword {
            recurse(secondKeyword) {
                $0.endIndent = true
            }
            recurse(body.leftBrace)
        } else {
            recurse(body.leftBrace) {
                $0.endIndent = true
            }
        }
        recurse(body.statements)
        recurse(body.rightBrace)
    }

    func updateLastToken(f: (inout Token) -> Void) {
        guard !tokens.isEmpty else { return }
        f(&tokens[tokens.endIndex - 1])
    }
}
