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
    syntax.with(\.statements, format(syntax.statements))
}

func format(_ syntax: CodeBlockItemListSyntax) -> CodeBlockItemListSyntax {
    CodeBlockItemListSyntax(syntax.map(format))
}

func format(_ syntax: CodeBlockItemSyntax) -> CodeBlockItemSyntax {
    CodeBlockItemSyntax(item: format(syntax.item))
}

func format(_ syntax: CodeBlockItemSyntax.Item) -> CodeBlockItemSyntax.Item {
    switch syntax {
    case .decl(let decl):
        return .decl(format(decl))
    default:
        fatalError("TODO")
    }
}

func format(_ syntax: DeclSyntax) -> DeclSyntax {
    if let syntax = syntax.as(ImportDeclSyntax.self) {
        return DeclSyntax(format(syntax))
    }
    if let syntax = syntax.as(VariableDeclSyntax.self) {
        return DeclSyntax(format(syntax))
    }
    fatalError("TODO")
}

func format(_ syntax: ImportDeclSyntax) -> ImportDeclSyntax {
    syntax
        .with(\.importKeyword, format(syntax.importKeyword).with(\.trailingTrivia, .space))
        .with(\.path, format(syntax.path))
        .with(\.trailingTrivia, .newline)
}

func format(_ syntax: ImportPathComponentListSyntax) -> ImportPathComponentListSyntax {
    ImportPathComponentListSyntax(syntax.map(format))
}

func format(_ syntax: ImportPathComponentSyntax) -> ImportPathComponentSyntax {
    syntax.with(\.name, format(syntax.name))
}

func format(_ syntax: VariableDeclSyntax) -> VariableDeclSyntax {
    syntax
        .with(\.bindingSpecifier, format(syntax.bindingSpecifier).with(\.trailingTrivia, .space))
        .with(\.bindings, format(syntax.bindings))
}

func format(_ syntax: PatternBindingListSyntax) -> PatternBindingListSyntax {
    PatternBindingListSyntax(syntax.map(format))
}

func format(_ syntax: PatternBindingSyntax) -> PatternBindingSyntax {
    var syntax = syntax
    syntax.pattern = format(syntax.pattern)
    if let initializer = syntax.initializer {
        syntax.initializer = format(initializer)
    }
    return syntax
}

func format(_ syntax: PatternSyntax) -> PatternSyntax {
    if let syntax = syntax.as(IdentifierPatternSyntax.self) {
        return PatternSyntax(format(syntax))
    }
    fatalError("TODO")
}

func format(_ syntax: IdentifierPatternSyntax) -> IdentifierPatternSyntax {
    syntax
        .with(\.identifier, format(syntax.identifier))
}

func format(_ syntax: InitializerClauseSyntax) -> InitializerClauseSyntax {
    return syntax
        .with(\.equal, format(syntax.equal))
        .with(\.value, format(syntax.value))
}

func format(_ syntax: ExprSyntax) -> ExprSyntax {
    if let syntax = syntax.as(ArrayExprSyntax.self) {
        return ExprSyntax(format(syntax))
    }
    if let syntax = syntax.as(DeclReferenceExprSyntax.self) {
        return ExprSyntax(format(syntax))
    }
    if let syntax = syntax.as(FunctionCallExprSyntax.self) {
        return ExprSyntax(format(syntax))
    }
    if let syntax = syntax.as(MemberAccessExprSyntax.self) {
        return ExprSyntax(format(syntax))
    }
    if let syntax = syntax.as(StringLiteralExprSyntax.self) {
        return ExprSyntax(format(syntax))
    }
    fatalError("TODO")
}

func format(_ syntax: ArrayExprSyntax) -> ArrayExprSyntax {
    syntax
        .with(\.leftSquare, format(syntax.leftSquare))
        .with(\.elements, format(syntax.elements))
        .with(\.rightSquare, format(syntax.rightSquare))
}

func format(_ syntax: ArrayElementListSyntax) -> ArrayElementListSyntax {
    ArrayElementListSyntax(syntax.enumerated().map { (index, element) in
        format(element, last: index == syntax.count - 1)
    })
}

func format(_ syntax: ArrayElementSyntax, last: Bool) -> ArrayElementSyntax {
    var syntax = syntax
    syntax.expression = format(syntax.expression)
    syntax.trailingComma = last ? nil : .commaToken()
    return syntax
}

func format(_ syntax: DeclReferenceExprSyntax) -> DeclReferenceExprSyntax {
    syntax.with(\.baseName, format(syntax.baseName))
}

func format(_ syntax: FunctionCallExprSyntax) -> FunctionCallExprSyntax {
    var syntax = syntax
    syntax.calledExpression = format(syntax.calledExpression)
    if let leftParen = syntax.leftParen {
        syntax.leftParen = format(leftParen)
    }
    syntax.arguments = format(syntax.arguments)
    if let rightParen = syntax.rightParen {
        syntax.rightParen = format(rightParen)
    }
    return syntax
}

func format(_ syntax: LabeledExprListSyntax) -> LabeledExprListSyntax {
    LabeledExprListSyntax(syntax.enumerated().map { (index, element) in
        format(element, last: index == syntax.count - 1)
    })
}

func format(_ syntax: LabeledExprSyntax, last: Bool) -> LabeledExprSyntax {
    var syntax = syntax
    if let label = syntax.label {
        syntax.label = format(label)
    }
    if let colon = syntax.colon {
        syntax.colon = format(colon)
    }
    syntax.expression = format(syntax.expression)
    syntax.trailingComma = last ? nil : .commaToken()
    return syntax
}

func format(_ syntax: MemberAccessExprSyntax) -> MemberAccessExprSyntax {
    var syntax = syntax
    if let base = syntax.base {
        syntax.base = format(base)
    }
    syntax.period = format(syntax.period)
    syntax.declName = format(syntax.declName)
    return syntax
}

func format(_ syntax: StringLiteralExprSyntax) -> StringLiteralExprSyntax {
    syntax
        .with(\.openingQuote, format(syntax.openingQuote))
        .with(\.segments, format(syntax.segments))
        .with(\.closingQuote, format(syntax.closingQuote))
}

func format(_ syntax: StringLiteralSegmentListSyntax) -> StringLiteralSegmentListSyntax {
    StringLiteralSegmentListSyntax(syntax.map(format))
}

func format(_ syntax: StringLiteralSegmentListSyntax.Element) -> StringLiteralSegmentListSyntax.Element {
    switch syntax {
    case .stringSegment(let syntax):
        return .stringSegment(format(syntax))
    default:
        fatalError("TODO")
    }
}

func format(_ syntax: StringSegmentSyntax) -> StringSegmentSyntax {
    syntax.with(\.content, format(syntax.content))
}

func format(_ syntax: TokenSyntax) -> TokenSyntax {
    return syntax
        .with(\.leadingTrivia, format(syntax.leadingTrivia))
        .with(\.trailingTrivia, format(syntax.trailingTrivia))
}

func format(_ trivia: Trivia) -> Trivia {
    var pieces: [TriviaPiece] = []
    for piece in trivia {
        switch piece {
        case .lineComment(_):
            pieces += [piece] + .newline
        case .spaces(_), .newlines(_):
            continue
        default:
            fatalError("TODO")
        }
    }
    return Trivia(pieces: pieces)
}
