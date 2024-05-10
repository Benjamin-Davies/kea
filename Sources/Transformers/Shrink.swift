import SwiftSyntax

class Shrink: SyntaxTransformer {
    // Trivia

    override func transform(_ trivia: Trivia) -> Trivia {
        // Just remove comments and spaces for now
        // TODO: preserve comments, invalid code, some double-spaces, etc.
        .init(pieces: [])
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
