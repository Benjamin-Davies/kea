import SwiftSyntax

class Pad: SyntaxRewriter {
    // Declarations

    override func visit(_ node: FunctionDeclSyntax) -> DeclSyntax {
        var node = node
        node.funcKeyword.trailingTrivia = .space
        node.body?.leadingTrivia = .space
        return super.visit(node)
    }

    override func visit(_ node: ImportDeclSyntax) -> DeclSyntax {
        super.visit(node.with(\.importKeyword.trailingTrivia, .space))
    }

    override func visit(_ node: StructDeclSyntax) -> DeclSyntax {
        super.visit(node
            .with(\.structKeyword.trailingTrivia, .space)
            .with(\.memberBlock.leadingTrivia, .space))
    }

    override func visit(_ node: VariableDeclSyntax) -> DeclSyntax {
        super.visit(node.with(\.bindingSpecifier.trailingTrivia, .space))
    }

    // Expressions

    override func visit(_ node: ClosureExprSyntax) -> ExprSyntax {
        var node = node
        if node.signature != nil {
            node.leftBrace.trailingTrivia = .space
            node.signature?.trailingTrivia = .newline
        } else {
            node.leftBrace.trailingTrivia = .newline
        }
        return super.visit(node)
    }

    override func visit(_ node: FunctionCallExprSyntax) -> ExprSyntax {
        var node = node
        node.trailingClosure?.leadingTrivia = .space
        return super.visit(node)
    }

    override func visit(_ node: TryExprSyntax) -> ExprSyntax {
        var node = node
        node.tryKeyword.trailingTrivia = .space
        return super.visit(node)
    }

    // Statements

    override func visit(_ node: ForStmtSyntax) -> StmtSyntax {
        var node = node
        node.forKeyword.trailingTrivia = .space
        node.inKeyword.leadingTrivia = .space
        node.inKeyword.trailingTrivia = .space
        return super.visit(node)
    }

    // Collections

    override func visit(_ node: ArrayElementSyntax) -> ArrayElementSyntax {
        var node = node
        node.trailingComma?.trailingTrivia = .space
        return super.visit(node)
    }

    override func visit(_ node: AttributeSyntax) -> AttributeSyntax {
        var node = node
        node.trailingTrivia = .space
        return super.visit(node)
    }

    override func visit(_ node: ClosureShorthandParameterSyntax) -> ClosureShorthandParameterSyntax {
        var node = node
        node.trailingComma?.trailingTrivia = .space
        return super.visit(node)
    }

    override func visit(_ node: CodeBlockItemSyntax) -> CodeBlockItemSyntax {
        super.visit(node.with(\.trailingTrivia, .newline))
    }

    override func visit(_ node: FunctionParameterSyntax) -> FunctionParameterSyntax {
        var node = node
        node.secondName?.leadingTrivia = .space
        node.colon.trailingTrivia = .space
        node.trailingComma?.trailingTrivia = .space
        return super.visit(node)
    }

    override func visit(_ node: LabeledExprSyntax) -> LabeledExprSyntax {
        var node = node
        node.colon?.trailingTrivia = .space
        node.trailingComma?.trailingTrivia = .space
        return super.visit(node)
    }

    override func visit(_ node: MemberBlockItemSyntax) -> MemberBlockItemSyntax {
        super.visit(node.with(\.trailingTrivia, .newline))
    }

    override func visit(_ node: PatternBindingSyntax) -> PatternBindingSyntax {
        var node = node
        node.trailingComma?.trailingTrivia = .space
        return super.visit(node)
    }

    // Miscellaneous node

    override func visit(_ node: ClosureSignatureSyntax) -> ClosureSignatureSyntax {
        var node = node
        node.inKeyword.leadingTrivia = .space
        return super.visit(node)
    }

    override func visit(_ node: CodeBlockSyntax) -> CodeBlockSyntax {
        var node = node
        node.leftBrace.trailingTrivia = .newline
        return super.visit(node)
    }

    override func visit(_ node: FunctionEffectSpecifiersSyntax) -> FunctionEffectSpecifiersSyntax {
        var node = node
        node.asyncSpecifier?.leadingTrivia = .space
        node.throwsSpecifier?.leadingTrivia = .space
        return super.visit(node)
    }

    override func visit(_ node: InheritanceClauseSyntax) -> InheritanceClauseSyntax {
        var node = node
        node.colon.leadingTrivia = .space
        node.colon.trailingTrivia = .space
        return super.visit(node)
    }

    override func visit(_ node: InitializerClauseSyntax) -> InitializerClauseSyntax {
        var node = node
        node.equal.leadingTrivia = .space
        node.equal.trailingTrivia = .space
        return super.visit(node)
    }

    override func visit(_ node: MemberBlockSyntax) -> MemberBlockSyntax {
        var node = node
        node.leftBrace.trailingTrivia = .newline
        return super.visit(node)
    }

    override func visit(_ node: ReturnClauseSyntax) -> ReturnClauseSyntax {
        var node = node
        node.arrow.leadingTrivia = .space
        node.arrow.trailingTrivia = .space
        return super.visit(node)
    }

    override func visit(_ node: TypeAnnotationSyntax) -> TypeAnnotationSyntax {
        var node = node
        node.colon.trailingTrivia = .space
        return super.visit(node)
    }
}
