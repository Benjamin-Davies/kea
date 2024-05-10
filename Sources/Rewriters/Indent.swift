import SwiftSyntax

class Indent: SyntaxRewriter {
    var indentLevel = 0
    var isNewline = true

    func visit(_ trivia: Trivia) -> Trivia {
        if trivia.isEmpty {
            if isNewline {
                isNewline = false
                return .tabs(indentLevel)
            }
            return trivia
        }

        var pieces = trivia.pieces

        var index = 0
        while index < pieces.count {
            if isNewline {
                while pieces[index].isSpaceOrTab {
                    pieces.remove(at: index)
                }
                pieces.insert(.tabs(indentLevel), at: index)
                isNewline = false
            }

            // Try and add the indent to the following token's leading trivia
            if pieces[index].isNewline {
                isNewline = true
            }

            index += 1
        }

        return Trivia(pieces: pieces)
    }

    override func visit(_ node: TokenSyntax) -> TokenSyntax {
        var node = node

        node.leadingTrivia = visit(node.leadingTrivia)

        if isNewline {
            var pieces = node.leadingTrivia.pieces
            pieces.append(.tabs(indentLevel))
            node.leadingTrivia = Trivia(pieces: pieces)
            isNewline = false
        }

        // Remove one level of indentation for braces
        let isBrace = node.tokenKind == .leftBrace || node.tokenKind == .rightBrace
        if isBrace && node.leadingTrivia.pieces.last == .tabs(indentLevel) {
            var pieces = node.leadingTrivia.pieces
            pieces[pieces.indices.last!] = .tabs(indentLevel - 1) 
            node.leadingTrivia = Trivia(pieces: pieces)
        }

        node.trailingTrivia = visit(node.trailingTrivia)
        return node
    }

    // Expressions

    override func visit(_ node: ClosureExprSyntax) -> ExprSyntax {
        indentLevel += 1
        let node = super.visit(node)
        indentLevel -= 1
        return node
    }

    // Miscellaneous Syntax

    override func visit(_ node: CodeBlockSyntax) -> CodeBlockSyntax {
        indentLevel += 1
        let node = super.visit(node)
        indentLevel -= 1
        return node
    }

    override func visit(_ node: MemberBlockSyntax) -> MemberBlockSyntax {
        indentLevel += 1
        let node = super.visit(node)
        indentLevel -= 1
        return node
    }
}
