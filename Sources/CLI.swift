import ArgumentParser
import Kea
import Foundation
import SwiftParser

@main
struct Kakapo: ParsableCommand {
    @Argument(help: "The files to process.")
    var files: [String]

    @Flag(
        name: .shortAndLong,
        help: "Prints the formatted code to the standard output, instead of overwriting the source files."
    )
    var dryRun: Bool = false

    func run() throws {
        for file in files {
            let source = try String(contentsOfFile: file)
            let ast = Parser.parse(source: source)
            let formattedFile = format(ast)
            if dryRun {
                print(formattedFile)
            } else {
                try formattedFile.write(toFile: file, atomically: true, encoding: .utf8)
            }
        }
    }
}
