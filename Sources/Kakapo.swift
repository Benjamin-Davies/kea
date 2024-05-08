// The Swift Programming Language
// https://docs.swift.org/swift-book
// 
// Swift Argument Parser
// https://swiftpackageindex.com/apple/swift-argument-parser/documentation

import ArgumentParser
import Foundation

@main
struct Kakapo: ParsableCommand {
    @Argument(help: "The files to process.")
    var files: [String]

    func run() throws {
        for file in files {
            print(file)

            let source = try Source(contentsOfFile: file)
            var tokens = Tokens(source)
            while try !tokens.isEOF() {
                let token = try tokens.consume()

                print(token)
            }
        }
    }
}