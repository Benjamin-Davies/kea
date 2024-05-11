import SwiftSyntax

public func format(_ syntax: SourceFileSyntax) -> SourceFileSyntax {
    rewrite(syntax, with: Shrink(), Expand(), Indent())
}

func rewrite(_ syntax: SourceFileSyntax, with rewriters: SyntaxRewriter...) -> SourceFileSyntax {
    rewriters.reduce(syntax) { syntax, rewriter in
        rewriter.visit(syntax)
    }
}
