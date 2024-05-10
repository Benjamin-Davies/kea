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

    override func visit(_ node: ArrayElementListSyntax) -> ArrayElementListSyntax {
        var node = node
        for index in node.indices {
            if node.index(after: index) == node.endIndex {
                node[index].trailingComma = nil
            } else {
                node[index].trailingComma = .commaToken()
            }
        }
        return super.visit(node)
    }

    override func visit(_ node: ClosureParameterListSyntax) -> ClosureParameterListSyntax {
        var node = node
        for index in node.indices {
            if node.index(after: index) == node.endIndex {
                node[index].trailingComma = nil
            } else {
                node[index].trailingComma = .commaToken()
            }
        }
        return super.visit(node)
    }

    override func visit(_ node: CodeBlockItemSyntax) -> CodeBlockItemSyntax {
        super.visit(node.with(\.semicolon, nil))
    }

    override func visit(_ node: LabeledExprListSyntax) -> LabeledExprListSyntax {
        var node = node
        for index in node.indices {
            if node.index(after: index) == node.endIndex {
                node[index].trailingComma = nil
            } else {
                node[index].trailingComma = .commaToken()
            }
        }
        return super.visit(node)
    }

    override func visit(_ node: MemberBlockItemSyntax) -> MemberBlockItemSyntax {
        super.visit(node.with(\.semicolon, nil))
    }

    override func visit(_ node: PatternBindingListSyntax) -> PatternBindingListSyntax {
        var node = node
        for index in node.indices {
            node[index].trailingComma = index == node.indices.last ? nil : .commaToken()
        }
        return super.visit(node)
    }
}
