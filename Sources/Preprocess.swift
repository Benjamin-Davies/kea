import SwiftOperators
import SwiftSyntax

func preprocess(_ syntax: SourceFileSyntax, rearrange: Bool) -> SourceFileSyntax {
    var newSyntax = try! SourceFileSyntax(OperatorTable.standardOperators.foldAll(syntax))!
    if rearrange {
        newSyntax = numbers(newSyntax)
    }
    return newSyntax
}
