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
            case .atSign, .prefixAmpersand, .prefixOperator:
                $0.attachRight = true
            case .comma, .colon, .semicolon, .postfixQuestionMark, .postfixOperator:
                $0.attachLeft = true
            case .period, .ellipsis, .stringSegment:
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

    override func visit(_ node: CodeBlockItemSyntax) -> SyntaxVisitorContinueKind {
        switch node.item {
        case .decl(let decl):
            walk(decl)
        case .stmt(let stmt):
            walk(stmt)
        case .expr(let expr):
            walk(expr)
        }
        updateLastToken { $0.stickiness = 0 }

        return .skipChildren
    }

    override func visit(_ node: FunctionCallExprSyntax) -> SyntaxVisitorContinueKind {
        walk(node.calledExpression)
        walk(optional: node.leftParen) {
            $0.attachLeft = true
        }
        walk(node.arguments)
        walk(optional: node.rightParen)
        walk(optional: node.trailingClosure)
        walk(node.additionalTrailingClosures)

        return .skipChildren
    }

    override func visit(_ node: FunctionParameterClauseSyntax) -> SyntaxVisitorContinueKind {
        walk(node.leftParen) {
            $0.attachLeft = true
        }
        walk(node.parameters)
        walk(node.rightParen)

        return .skipChildren
    }

    // Helpers

    func walk(optional node: (some SyntaxProtocol)?) {
        if let node {
            walk(node)
        }
    }

    func walk(_ node: some SyntaxProtocol, f: (inout Token) -> ()) {
        walk(node)
        updateLastToken(f: f)
    }

    func walk(optional node: (some SyntaxProtocol)?, f: (inout Token) -> ()) {
        if let node {
            walk(node)
            updateLastToken(f: f)
        }
    }

    func updateLastToken(f: (inout Token) -> ()) {
        guard !tokens.isEmpty else { return }
        f(&tokens[tokens.endIndex - 1])
    }
}
