import SwiftSyntax

let MAX_LINE_LENGTH = 100

public func format(_ syntax: SourceFileSyntax) -> String {
    let indentType = detectIndentType(syntax)
    let exceptions = markExceptions(syntax)

    let tokens = tokens(syntax, exceptions: exceptions)
    let lines = Line(tokens: tokens, indentType: indentType).split()

    var output = ""
    for line in lines {
        line.write(to: &output)
        output.append("\n")
    }

    return output
}
