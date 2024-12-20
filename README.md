# Kea

*Prettier and a little less impulsive than your average Swift, but still plenty curious.*

Kea is a formatter for Swift that makes all of your formatting decisions for you so that you don't waste time worrying about them. It aims to follow the same conventions as the Swift book[^tspl] and to be opinionated like gofmt and rustfmt.

You choose:

- The logic
- The syntax
- The comments
- The location of blank lines
- The type of indentation (tabbed, 2-spaced or 4-spaced)

Kea chooses:

- The indentation level of each line
- Where to split long lines
- Which expressions span multiple lines
- Which brackets go on a new line (opening brackets never should)
- Whether to use semicolons (we don't ever use them)
- Which blocks can stay on a single line

In fact, one of the key goals of Kea is to always produce a canonical formatting, i.e the same AST[^non-trivia] should always produce the same formatted code (except we preserve comments and blank lines).

[^tspl]: "The Swift Programming Language", avaliable at: https://docs.swift.org/swift-book/documentation/the-swift-programming-language
[^non-trivia]: When casually referring to an AST, we often mean the AST without trivia.[^trivia]
[^trivia]: Trivia refers to comments, whitespace and other text that does not change the semantics of the code. See: https://swiftpackageindex.com/swiftlang/swift-syntax/600.0.1/documentation/swiftsyntax/trivia

# Roadmap

The following are features that I plan to add to Kea in the future:

- [ ] Reproduce the formatting of the Language Guide and Language Reference sections
- [ ] Support shebangs (e.g. `#!/usr/bin/swift`)
- [ ] Ensure that consecutive blocks are either all single-line or all multi-line
- [x] Support trimming extra zeroes and adding digit separators to numeric literals (disable with the `--no-rearrange` flag)
- [ ] Support import sorting (disable with the `--no-rearrange` flag)
- [ ] Add blank lines after shebangs, header comments and imports
