import SwiftSyntax

class ChangeIndentType: SyntaxRewriter {
    let indentType: IndentType

    init(indentType: IndentType) {
        self.indentType = indentType
    }

    func visit(_ trivia: Trivia) -> Trivia {
        Trivia(pieces: trivia.map { piece in
            switch piece {
            case .tabs(let level):
                switch indentType {
                case .twoSpaces:
                    return .spaces(2 * level)
                case .fourSpaces:
                    return .spaces(4 * level)
                case .tab:
                    return .tabs(level)
                }
            default:
                return piece
            }
        })
    }

    override func visit(_ node: TokenSyntax) -> TokenSyntax {
        var node = node
        node.leadingTrivia = visit(node.leadingTrivia)
        node.trailingTrivia = visit(node.trailingTrivia)
        return node
    }
}
