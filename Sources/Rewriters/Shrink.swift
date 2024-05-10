import SwiftSyntax

class Shrink: SyntaxRewriter {
    // Trivia

    func visit(_ trivia: Trivia) -> Trivia {
        // Just remove comments and spaces for now
        // TODO: preserve comments, invalid code, some double-spaces, etc.
        .init(pieces: [])
    }

    // Tokens

    override func visit(_ node: TokenSyntax) -> TokenSyntax {
        super.visit(node
            .with(\.leadingTrivia, visit(node.leadingTrivia))
            .with(\.trailingTrivia, visit(node.trailingTrivia)))
    }

    // Collections

    override func visit(_ node: ArrayElementSyntax) -> ArrayElementSyntax {
        super.visit(node
            .with(\.trailingComma, isLastInParent(node) ? nil : .commaToken()))
    }

    override func visit(_ node: ClosureParameterSyntax) -> ClosureParameterSyntax {
        super.visit(node
            .with(\.trailingComma, isLastInParent(node) ? nil : .commaToken()))
    }

    override func visit(_ node: CodeBlockItemSyntax) -> CodeBlockItemSyntax {
        super.visit(node.with(\.semicolon, nil))
    }

    override func visit(_ node: LabeledExprSyntax) -> LabeledExprSyntax {
        super.visit(node
            .with(\.trailingComma, isLastInParent(node) ? nil : .commaToken()))
    }

    override func visit(_ node: MemberBlockItemSyntax) -> MemberBlockItemSyntax {
        super.visit(node.with(\.semicolon, nil))
    }

    override func visit(_ node: PatternBindingSyntax) -> PatternBindingSyntax {
        super.visit(node
            .with(\.trailingComma, isLastInParent(node) ? nil : .commaToken()))
    }
}

fileprivate func isLastInParent(_ node: some SyntaxProtocol) -> Bool {
    node.lastToken(viewMode: .all)?.id == node.parent?.lastToken(viewMode: .all)?.id
}
