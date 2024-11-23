# Kea

*Prettier and a little less impulsive than your average Swift, but still plenty curious.*

Kea is a formatter for Swift that makes all of your formatting decisions for you. It aims to follow the same conventions as the Swift book[^tspl] and to be opinionated like gofmt and rustfmt.

You choose:

- The logic
- The syntax
- The comments
- The location of blank lines
- The type of indentation (tabbed, 2-spaced or 4-spaced)

Kea chooses:

- The indentation level of each line
- Where to split long lines
- Which brackets go on a new line (opening brackets never should)
- Whether to use semicolons (we don't ever use them)
- Which blocks can stay on a single line

In fact, one of the key goals of Kea is to always produce a canonical formatting, i.e the same AST should always produce the same formatted code (ignoring all trivia[^trivia] except for comments and blank lines).

[^tspl]: "The Swift Programming Language", avaliable at: https://docs.swift.org/swift-book/documentation/the-swift-programming-language
[^trivia]: E.g. comments and whitespace, see: https://swiftpackageindex.com/swiftlang/swift-syntax/600.0.1/documentation/swiftsyntax/trivia
