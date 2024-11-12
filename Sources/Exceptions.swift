import SwiftOperators
import SwiftSyntax

func markExceptions(_ syntax: some SyntaxProtocol) -> Exceptions {
    let exceptions = Exceptions()
    exceptions.walk(syntax)
    return exceptions
}

class Exceptions: SyntaxVisitor {
    var hangingLists: Set<LabeledExprListSyntax> = []
    var singleLineItemLists: Set<CodeBlockItemListSyntax> = []

    init() {
        super.init(viewMode: .sourceAccurate)
    }

    override func visit(_ node: ClosureExprSyntax) -> SyntaxVisitorContinueKind {
        if node.statements.isSimple {
            singleLineItemLists.insert(node.statements)
        }
        return .visitChildren
    }

    override func visit(_ node: FunctionCallExprSyntax) -> SyntaxVisitorContinueKind {
        hangingLists.insert(node.arguments)
        return .visitChildren
    }

    override func visit(_ node: FunctionDeclSyntax) -> SyntaxVisitorContinueKind {
        if node.signature.returnClause != nil {
            if let body = node.body, body.statements.isSimple {
                singleLineItemLists.insert(body.statements)
            }
        }
        return .visitChildren
    }

    override func visit(_ node: InitializerClauseSyntax) -> SyntaxVisitorContinueKind {
        walk(node.value)
        if let expr = FunctionCallExprSyntax(node.value) {
            hangingLists.remove(expr.arguments)
        }

        return .skipChildren
    }
}

fileprivate extension CodeBlockItemListSyntax {
    var isSimple: Bool {
        return count <= 1 && first?.item.isSimple ?? true
    }
}

fileprivate extension CodeBlockItemSyntax.Item {
    var isSimple: Bool {
        if case let .expr(expr) = self {
            return expr.isSimple
        } else {
            return false
        }
    }
}

fileprivate extension ExprSyntax {
    var isSimple: Bool {
        return !isAssignment
    }

    var isAssignment: Bool {
        guard let infixExpr = InfixOperatorExprSyntax(self) else {
            return false
        }
        if AssignmentExprSyntax(infixExpr.operator) != nil {
            return true
        } else if let op = BinaryOperatorExprSyntax(infixExpr.operator) {
            let infixOp = OperatorTable.standardOperators.infixOperator(named: op.operator.text)
            return infixOp?.precedenceGroup == "assignment"
        } else {
            return false
        }
    }
}
