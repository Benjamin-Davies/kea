import SwiftSyntax

let MAX_LINE_LENGTH = 100

public func format(_ syntax: SourceFileSyntax) -> String {
    let indentType = detectIndentType(syntax)
    print(indentType)

    let tokens = syntax.tokens
    for token in tokens {
        print(token)
    }

    let lines = Line(tokens: tokens, indentType: indentType).split()

    var output = ""
    for line in lines {
        line.write(to: &output)
        output.append("\n")
    }

    return output
}
