import SwiftSyntax

extension SyntaxProtocol {
    var tokens: [Token] {
        let visitor = TokenVisitor()
        visitor.walk(self)
        return visitor.tokens
    }
}

fileprivate class TokenVisitor: SyntaxVisitor {
    var tokens: [Token] = []
    var depth: UInt = 0

    init() {
        super.init(viewMode: .sourceAccurate)
    }

    func visit(_ node: Trivia) {
        for piece in node {
            switch piece {
            case .spaces, .tabs:
                break
            case .newlines(let count):
                if count >= 2 {
                    updateLastToken { $0.doubleNewline = true }
                }
            case .lineComment(let comment):
                tokens.append(Token(comment))
                updateLastToken { $0.stickiness = 0 }
            default:
                fatalError("TODO: \(piece.debugDescription)")
            }
        }
    }

    override func visit(_ node: TokenSyntax) -> SyntaxVisitorContinueKind {
        visit(node.leadingTrivia)

        if node.tokenKind != .endOfFile {
            tokens.append(Token(node.text))
        }
        updateLastToken {
            switch node.tokenKind {
            case .atSign, .period, .prefixAmpersand, .prefixOperator:
                $0.attachRight = true
            case .comma, .colon, .semicolon, .postfixQuestionMark, .postfixOperator:
                $0.attachLeft = true
            case .ellipsis, .stringSegment:
                $0.attachLeft = true
                $0.attachRight = true

            case .leftBrace:
                $0.stickiness = 0
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

        visit(node.trailingTrivia)

        return .visitChildren
    }

    // Non-leaf nodes

    override func visit(_ node: ArrayElementListSyntax) -> SyntaxVisitorContinueKind {
        recurse(collection: node) {
            recurse($0.expression)
        } trailingComma: { $0.trailingComma }

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
            $0.stickiness = 0
        }

        return .skipChildren
    }

    override func visit(_ node: FunctionCallExprSyntax) -> SyntaxVisitorContinueKind {
        recurse(node.calledExpression)
        recurse(node.leftParen) {
            $0.attachLeft = true
        }
        recurse(node.arguments)
        recurse(node.rightParen)
        recurse(node.trailingClosure)
        recurse(node.additionalTrailingClosures)

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

    override func visit(_ node: LabeledExprListSyntax) -> SyntaxVisitorContinueKind {
        recurse(collection: node) {
            recurse($0.label)
            recurse($0.colon)
            recurse($0.expression)
        } trailingComma: { $0.trailingComma }

        return .skipChildren
    }

    override func visit(_ node: MemberAccessExprSyntax) -> SyntaxVisitorContinueKind {
        recurse(node.base)
        recurse(node.period) {
            $0.attachLeft = node.base != nil
        }
        recurse(node.declName)

        return .skipChildren
    }

    // Helpers

    func recurse(_ node: (some SyntaxProtocol)?, f: (inout Token) -> () = { _ in }) {
        if let node {
            depth += 1
            walk(node)
            depth -= 1

            updateLastToken(f: f)
        }
    }

    func recurse<C: SyntaxCollection>(collection node: C, recurseChild: (C.Element) -> (), trailingComma: (C.Element) -> TokenSyntax?) {
        updateLastToken {
            $0.stickiness = depth
        }

        for (i, element) in node.enumerated() {
            recurseChild(element)

            appendComma(trailing: i == node.count - 1)
            if let comma = trailingComma(element) {
                visit(comma.trailingTrivia)
            }

            updateLastToken {
                $0.stickiness = depth
            }
        }
    }

    func appendComma(trailing: Bool) {
        if trailing {
            // TODO: add comma, but only show it if it is the last token on the line
            return
        }

        tokens.append(Token(","))
        updateLastToken {
            $0.attachLeft = true
            $0.stickiness = depth
        }
    }

    func updateLastToken(f: (inout Token) -> ()) {
        guard !tokens.isEmpty else { return }
        f(&tokens[tokens.endIndex - 1])
    }
}
