// The Swift Programming Language
// https://docs.swift.org/swift-book
// 
// Swift Argument Parser
// https://swiftpackageindex.com/apple/swift-argument-parser/documentation

import ArgumentParser
import Foundation
import SwiftParser
import SwiftSyntax

@main
struct Kakapo: ParsableCommand {
    @Argument(help: "The files to process.")
    var files: [String]

    func run() throws {
        for file in files {
            let source = try String(contentsOfFile: file)
            let file = Parser.parse(source: source)
            let formattedFile = format(file)
            print(formattedFile)
        }
    }
}

func format(_ syntax: SourceFileSyntax) -> SourceFileSyntax {
    rewrite(syntax, with: Shrink(), Pad(), Indent())
}

func rewrite(_ syntax: SourceFileSyntax, with rewriters: SyntaxRewriter...) -> SourceFileSyntax {
    rewriters.reduce(syntax) { syntax, rewriter in
        rewriter.visit(syntax)
    }
}
