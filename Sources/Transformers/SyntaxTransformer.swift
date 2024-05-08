import SwiftSyntax

class SyntaxTransformer {
    // Sections are ordered as they appear in the SwiftSyntax library.

    // Trivia

    func transform(_ trivia: Trivia) -> Trivia {
        trivia
    }

    // Tokens

    func transform(_ syntax: TokenSyntax) -> TokenSyntax {
        syntax
            .with(\.leadingTrivia, transform(syntax.leadingTrivia))
            .with(\.trailingTrivia, transform(syntax.trailingTrivia))
    }

    // Declarations

    func transform(_ syntax: DeclSyntax) -> DeclSyntax {
        if let syntax = syntax.as(ImportDeclSyntax.self) {
            return DeclSyntax(transform(syntax))
        }
        if let syntax = syntax.as(VariableDeclSyntax.self) {
            return DeclSyntax(transform(syntax))
        }
        fatalError("TODO")
    }

    func transform(_ syntax: ImportDeclSyntax) -> ImportDeclSyntax {
        syntax
            .with(\.importKeyword, transform(syntax.importKeyword))
            .with(\.path, transform(syntax.path))
    }

    func transform(_ syntax: ImportPathComponentListSyntax) -> ImportPathComponentListSyntax {
        ImportPathComponentListSyntax(syntax.map(transform))
    }

    func transform(_ syntax: ImportPathComponentSyntax) -> ImportPathComponentSyntax {
        syntax.with(\.name, transform(syntax.name))
    }

    func transform(_ syntax: VariableDeclSyntax) -> VariableDeclSyntax {
        syntax
            .with(\.bindingSpecifier, transform(syntax.bindingSpecifier))
            .with(\.bindings, transform(syntax.bindings))
    }

    // Expressions

    func transform(_ syntax: ExprSyntax) -> ExprSyntax {
        if let syntax = syntax.as(ArrayExprSyntax.self) {
            return ExprSyntax(transform(syntax))
        }
        if let syntax = syntax.as(DeclReferenceExprSyntax.self) {
            return ExprSyntax(transform(syntax))
        }
        if let syntax = syntax.as(FunctionCallExprSyntax.self) {
            return ExprSyntax(transform(syntax))
        }
        if let syntax = syntax.as(MemberAccessExprSyntax.self) {
            return ExprSyntax(transform(syntax))
        }
        if let syntax = syntax.as(StringLiteralExprSyntax.self) {
            return ExprSyntax(transform(syntax))
        }
        fatalError("TODO")
    }

    func transform(_ syntax: ArrayExprSyntax) -> ArrayExprSyntax {
        syntax
            .with(\.leftSquare, transform(syntax.leftSquare))
            .with(\.elements, transform(syntax.elements))
            .with(\.rightSquare, transform(syntax.rightSquare))
    }

    func transform(_ syntax: DeclReferenceExprSyntax) -> DeclReferenceExprSyntax {
        syntax.with(\.baseName, transform(syntax.baseName))
    }

    func transform(_ syntax: FunctionCallExprSyntax) -> FunctionCallExprSyntax {
        syntax
            .with(\.calledExpression, transform(syntax.calledExpression))
            .with(\.leftParen, syntax.leftParen.map(transform))
            .with(\.arguments, transform(syntax.arguments))
            .with(\.rightParen, syntax.rightParen.map(transform))
    }

    func transform(_ syntax: MemberAccessExprSyntax) -> MemberAccessExprSyntax {
        syntax
            .with(\.base, syntax.base.map(transform))
            .with(\.period, transform(syntax.period))
            .with(\.declName, transform(syntax.declName))
    }

    func transform(_ syntax: StringLiteralExprSyntax) -> StringLiteralExprSyntax {
        syntax
            .with(\.openingPounds, syntax.openingPounds.map(transform))
            .with(\.openingQuote, transform(syntax.openingQuote))
            .with(\.segments, transform(syntax.segments))
            .with(\.closingQuote, transform(syntax.closingQuote))
            .with(\.closingPounds, syntax.closingPounds.map(transform))
    }

    // Patterns

    func transform(_ syntax: PatternSyntax) -> PatternSyntax {
        if let syntax = syntax.as(IdentifierPatternSyntax.self) {
            return PatternSyntax(transform(syntax))
        }
        fatalError("TODO")
    }

    func transform(_ syntax: IdentifierPatternSyntax) -> IdentifierPatternSyntax {
        syntax.with(\.identifier, transform(syntax.identifier))
    }

    // Statements

    // Collections

    func transform<T: SyntaxCollection>(_ syntax: T, _ transform: (T.Element, Bool) -> T.Element) -> T {
        var syntax = syntax
        let lastIndex = syntax.index(before: syntax.endIndex)
        for index in syntax.indices {
            syntax[index] = transform(syntax[index], index == lastIndex)
        }
        return syntax
    }

    func transform(_ syntax: ArrayElementListSyntax) -> ArrayElementListSyntax {
        transform(syntax, transform)
    }

    func transform(_ syntax: ArrayElementSyntax, last: Bool) -> ArrayElementSyntax {
        syntax
            .with(\.expression, transform(syntax.expression))
            .with(\.trailingComma, syntax.trailingComma.map(transform))
    }

    func transform(_ syntax: CodeBlockItemListSyntax) -> CodeBlockItemListSyntax {
        transform(syntax, transform)
    }

    func transform(_ syntax: CodeBlockItemSyntax, last: Bool) -> CodeBlockItemSyntax {
        syntax
            .with(\.item, transform(syntax.item))
            .with(\.semicolon, syntax.semicolon.map(transform))
    }

    func transform(_ syntax: CodeBlockItemSyntax.Item) -> CodeBlockItemSyntax.Item {
        switch syntax {
        case .decl(let decl):
            return .decl(transform(decl))
        case .expr(let expr):
            return .expr(transform(expr))
        case .stmt(_):
            fatalError("TODO")
        }
    }

    func transform(_ syntax: LabeledExprListSyntax) -> LabeledExprListSyntax {
        transform(syntax, transform)
    }

    func transform(_ syntax: LabeledExprSyntax, last: Bool) -> LabeledExprSyntax {
        syntax
            .with(\.label, syntax.label.map(transform))
            .with(\.colon, syntax.colon.map(transform))
            .with(\.expression, transform(syntax.expression))
            .with(\.trailingComma, syntax.trailingComma.map(transform))
    }

    func transform(_ syntax: PatternBindingListSyntax) -> PatternBindingListSyntax {
        transform(syntax, transform)
    }

    func transform(_ syntax: PatternBindingSyntax, last: Bool) -> PatternBindingSyntax {
        syntax
            .with(\.pattern, transform(syntax.pattern))
            .with(\.initializer, syntax.initializer.map(transform))
    }

    func transform(_ syntax: StringLiteralSegmentListSyntax) -> StringLiteralSegmentListSyntax {
        transform(syntax, transform)
    }

    func transform(_ syntax: StringLiteralSegmentListSyntax.Element, last: Bool) -> StringLiteralSegmentListSyntax.Element {
        if let syntax = syntax.as(StringSegmentSyntax.self) {
            return StringLiteralSegmentListSyntax.Element(transform(syntax))
        }
        fatalError("TODO")
    }

    func transform(_ syntax: StringSegmentSyntax) -> StringSegmentSyntax {
        syntax.with(\.content, transform(syntax.content))
    }

    // Miscellaneous Syntax

    func transform(_ syntax: InitializerClauseSyntax) -> InitializerClauseSyntax {
        syntax
            .with(\.equal, transform(syntax.equal))
            .with(\.value, transform(syntax.value))
    }

    func transform(_ syntax: SourceFileSyntax) -> SourceFileSyntax {
        syntax
            .with(\.shebang, syntax.shebang.map(transform))
            .with(\.statements, transform(syntax.statements))
            .with(\.endOfFileToken, transform(syntax.endOfFileToken))
    }
}

extension SourceFileSyntax {
    func transform(with transformers: SyntaxTransformer...) -> SourceFileSyntax {
        var syntax = self
        for transformer in transformers {
            syntax = transformer.transform(syntax)
        }
        return syntax
    }
}
