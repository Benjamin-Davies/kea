import SwiftSyntax

public func format(_ syntax: SourceFileSyntax) -> SourceFileSyntax {
    let indentType = detectIndentType(syntax)
    print(indentType)
    return rewrite(
        syntax,
        with: [
            Shrink(),
            Expand(),
            Indent(),
            ChangeIndentType(indentType: indentType),
        ])
}

func rewrite(_ syntax: SourceFileSyntax, with rewriters: [SyntaxRewriter]) -> SourceFileSyntax {
    rewriters.reduce(syntax) { syntax, rewriter in
        rewriter.visit(syntax)
    }
}
