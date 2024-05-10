import SwiftSyntax

class Pad: SyntaxTransformer {
    // Declarations

    override func transform(_ syntax: ImportDeclSyntax) -> ImportDeclSyntax {
        super.transform(syntax).with(\.importKeyword.trailingTrivia, .space)
    }

    override func transform(_ syntax: VariableDeclSyntax) -> VariableDeclSyntax {
        super.transform(syntax).with(\.bindingSpecifier.trailingTrivia, .space)
    }

    // Collections

    override func transform(_ syntax: ArrayElementSyntax, last: Bool) -> ArrayElementSyntax {
        var syntax = super.transform(syntax, last: last)
        syntax.trailingComma?.trailingTrivia = .space
        return syntax
    }

    override func transform(_ syntax: CodeBlockItemSyntax, last: Bool) -> CodeBlockItemSyntax {
        super
            .transform(syntax, last: last)
            .with(\.trailingTrivia, .newline)
    }

    override func transform(_ syntax: LabeledExprSyntax, last: Bool) -> LabeledExprSyntax {
        var syntax = super.transform(syntax, last: last)
        syntax.colon?.trailingTrivia = .space
        syntax.trailingComma?.trailingTrivia = .space
        return syntax
    }

    override func transform(_ syntax: PatternBindingSyntax, last: Bool) -> PatternBindingSyntax {
        var syntax = super.transform(syntax, last: last)
        syntax.trailingComma?.trailingTrivia = .space
        return syntax
    }

    // Miscellaneous Syntax

    override func transform(_ syntax: InitializerClauseSyntax) -> InitializerClauseSyntax {
        var syntax = super.transform(syntax)
        syntax.equal.leadingTrivia = .space
        syntax.equal.trailingTrivia = .space
        return syntax
    }
}
