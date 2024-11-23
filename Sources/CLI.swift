import ArgumentParser
import Kea
import Foundation
import SwiftParser

@main
struct Kea: ParsableCommand {
    @Argument(help: "The files to process.")
    var files: [String]

    @Flag(
        name: .shortAndLong,
        help: "Prints the formatted code to the standard output, instead of overwriting the source files."
    )
    var dryRun: Bool = false

    @Flag(
        name: .shortAndLong,
        help: "Prohibits Kea from making small modifications to the AST (e.g. sorting imports)."
    )
    var noRearrange: Bool = false

    func run() throws {
        for file in files {
            let source = try String(contentsOfFile: file)
            let ast = Parser.parse(source: source)
            let formattedFile = format(ast, rearrange: !noRearrange)
            if dryRun {
                print(formattedFile)
            } else {
                try formattedFile.write(toFile: file, atomically: true, encoding: .utf8)
            }
        }
    }
}
