import SwiftSyntax

class Shrink: SyntaxTransformer {
    // Trivia

    override func transform(_ trivia: Trivia) -> Trivia {
        var pieces: [TriviaPiece] = []
        for piece in trivia {
            switch piece {
            case .lineComment(_):
                pieces += [piece] + .newline
            case .spaces(_), .newlines(_):
                continue
            default:
                fatalError("TODO")
            }
        }
        return Trivia(pieces: pieces)
    }

    // Declarations

    override func transform(_ syntax: ImportDeclSyntax) -> ImportDeclSyntax {
        super.transform(syntax).with(\.importKeyword.trailingTrivia, .space)
    }

    override func transform(_ syntax: VariableDeclSyntax) -> VariableDeclSyntax {
        super.transform(syntax).with(\.bindingSpecifier.trailingTrivia, .space)
    }

    // Collections

    override func transform(_ syntax: ArrayElementSyntax, last: Bool) -> ArrayElementSyntax {
        super
            .transform(syntax, last: last)
            .with(\.trailingComma, last ? nil : .commaToken())
    }

    override func transform(_ syntax: CodeBlockItemSyntax, last: Bool) -> CodeBlockItemSyntax {
        super
            .transform(syntax, last: last)
            .with(\.semicolon, nil)
            .with(\.trailingTrivia, .newline)
    }

    override func transform(_ syntax: LabeledExprSyntax, last: Bool) -> LabeledExprSyntax {
        super
            .transform(syntax, last: last)
            .with(\.trailingComma, last ? nil : .commaToken())
    }

    override func transform(_ syntax: PatternBindingSyntax, last: Bool) -> PatternBindingSyntax {
        super
            .transform(syntax, last: last)
            .with(\.trailingComma, last ? nil : .commaToken())
    }
}
