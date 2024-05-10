import SwiftSyntax

class Pad: SyntaxRewriter {
    // Declarations

    override func visit(_ node: FunctionDeclSyntax) -> DeclSyntax {
        var node = node
        node.funcKeyword.trailingTrivia.ensureWhitespace()
        node.body?.leadingTrivia.ensureWhitespace()
        return super.visit(node)
    }

    override func visit(_ node: ImportDeclSyntax) -> DeclSyntax {
        var node = node
        node.importKeyword.trailingTrivia.ensureWhitespace()
        return super.visit(node)
    }

    override func visit(_ node: StructDeclSyntax) -> DeclSyntax {
        var node = node
        node.structKeyword.trailingTrivia.ensureWhitespace()
        node.memberBlock.leadingTrivia.ensureWhitespace()
        return super.visit(node)
    }

    override func visit(_ node: VariableDeclSyntax) -> DeclSyntax {
        var node = node
        node.bindingSpecifier.trailingTrivia.ensureWhitespace()
        return super.visit(node)
    }

    // Expressions

    override func visit(_ node: ClosureExprSyntax) -> ExprSyntax {
        var node = node
        if node.signature != nil {
            node.leftBrace.trailingTrivia.ensureWhitespace()
            node.signature?.trailingTrivia.ensureNewline()
        } else {
            node.leftBrace.trailingTrivia.ensureNewline()
        }
        return super.visit(node)
    }

    override func visit(_ node: FunctionCallExprSyntax) -> ExprSyntax {
        var node = node
        node.trailingClosure?.leadingTrivia.ensureWhitespace()
        return super.visit(node)
    }

    override func visit(_ node: TryExprSyntax) -> ExprSyntax {
        var node = node
        node.tryKeyword.trailingTrivia.ensureWhitespace()
        return super.visit(node)
    }

    // Statements

    override func visit(_ node: ForStmtSyntax) -> StmtSyntax {
        var node = node
        node.forKeyword.trailingTrivia.ensureWhitespace()
        node.inKeyword.leadingTrivia.ensureWhitespace()
        node.inKeyword.trailingTrivia.ensureWhitespace()
        node.body.leadingTrivia.ensureWhitespace()
        return super.visit(node)
    }

    // Collections

    override func visit(_ node: ArrayElementSyntax) -> ArrayElementSyntax {
        var node = node
        node.trailingComma?.trailingTrivia.ensureWhitespace()
        return super.visit(node)
    }

    override func visit(_ node: AttributeSyntax) -> AttributeSyntax {
        var node = node
        node.trailingTrivia.ensureWhitespace()
        return super.visit(node)
    }

    override func visit(_ node: ClosureShorthandParameterSyntax) -> ClosureShorthandParameterSyntax {
        var node = node
        node.trailingComma?.trailingTrivia.ensureWhitespace()
        return super.visit(node)
    }

    override func visit(_ node: CodeBlockItemSyntax) -> CodeBlockItemSyntax {
        var node = node
        node.trailingTrivia.ensureNewline()
        return super.visit(node)
    }

    override func visit(_ node: FunctionParameterSyntax) -> FunctionParameterSyntax {
        var node = node
        node.secondName?.leadingTrivia.ensureWhitespace()
        node.colon.trailingTrivia.ensureWhitespace()
        node.trailingComma?.trailingTrivia.ensureWhitespace()
        return super.visit(node)
    }

    override func visit(_ node: LabeledExprSyntax) -> LabeledExprSyntax {
        var node = node
        node.colon?.trailingTrivia.ensureWhitespace()
        node.trailingComma?.trailingTrivia.ensureWhitespace()
        return super.visit(node)
    }

    override func visit(_ node: MemberBlockItemSyntax) -> MemberBlockItemSyntax {
        super.visit(node.with(\.trailingTrivia, .newline))
    }

    override func visit(_ node: PatternBindingSyntax) -> PatternBindingSyntax {
        var node = node
        node.trailingComma?.trailingTrivia.ensureWhitespace()
        return super.visit(node)
    }

    // Miscellaneous Syntax

    override func visit(_ node: ClosureSignatureSyntax) -> ClosureSignatureSyntax {
        var node = node
        node.inKeyword.leadingTrivia.ensureWhitespace()
        return super.visit(node)
    }

    override func visit(_ node: CodeBlockSyntax) -> CodeBlockSyntax {
        var node = node
        node.leftBrace.trailingTrivia.ensureNewline()
        return super.visit(node)
    }

    override func visit(_ node: FunctionEffectSpecifiersSyntax) -> FunctionEffectSpecifiersSyntax {
        var node = node
        node.asyncSpecifier?.leadingTrivia.ensureWhitespace()
        node.throwsSpecifier?.leadingTrivia.ensureWhitespace()
        return super.visit(node)
    }

    override func visit(_ node: InheritanceClauseSyntax) -> InheritanceClauseSyntax {
        var node = node
        node.colon.trailingTrivia.ensureWhitespace()
        return super.visit(node)
    }

    override func visit(_ node: InitializerClauseSyntax) -> InitializerClauseSyntax {
        var node = node
        node.equal.leadingTrivia.ensureWhitespace()
        node.equal.trailingTrivia.ensureWhitespace()
        return super.visit(node)
    }

    override func visit(_ node: MemberBlockSyntax) -> MemberBlockSyntax {
        var node = node
        node.leftBrace.trailingTrivia.ensureNewline()
        return super.visit(node)
    }

    override func visit(_ node: ReturnClauseSyntax) -> ReturnClauseSyntax {
        var node = node
        node.arrow.leadingTrivia.ensureWhitespace()
        node.arrow.trailingTrivia.ensureWhitespace()
        return super.visit(node)
    }

    override func visit(_ node: TypeAnnotationSyntax) -> TypeAnnotationSyntax {
        var node = node
        node.colon.trailingTrivia.ensureWhitespace()
        return super.visit(node)
    }
}
