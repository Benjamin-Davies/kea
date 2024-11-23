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

In fact, one of the key goals of Kea is to always produce a canonical formatting, i.e the same AST should always produce the same formatted code (ignoring all trivia[^trivia] except for comments and blank lines).

[^tspl]: "The Swift Programming Language", avaliable at: https://docs.swift.org/swift-book/documentation/the-swift-programming-language
[^trivia]: E.g. comments and whitespace, see: https://swiftpackageindex.com/swiftlang/swift-syntax/600.0.1/documentation/swiftsyntax/trivia

# Roadmap

The following are features that I plan to add to Kea in the future:

- [ ] Reproduce the formatting of the Language Guide and Language Reference sections
- [ ] Support shebangs (e.g. `#!/usr/bin/swift`)
- [ ] Ensure that consecutive blocks are either all single-line or all multi-line
- [ ] Support trimming extra zeroes and adding digit separators to numeric literals (disable with the `--no-rearrange` or `--no-simplify-numbers` flags)
  - Number representations are canonical, except that base prefixes and decimal points are preserved
  - Leading plus signs are removed
  - Decimal numbers never zero-pad and place the digit separator every three digits
  - Binary numbers always zero-pad to 4 digits or a multiple of 8 digits and have a digit separator every four digits
  - Octal numbers always zero-pad to 1 digit or a multiple of 3 digits and have a digit separator every three digits
  - Hexadecimal numbers always zero-pad to 1 digit, 2 digits or a multiple of 4 digits and have a digit separator every four digits
  - Fractional parts and exponents follow the rules above
  - Decimal floats with an absolute value less than 1 billion and greater than or equal to 0.001 are represented without an exponent
  - All other decimal floats are represented in exponential form with a single non-zero digit before the decimal point
  - Hexadecimal floats never have a fraction part
  - Hexadecimal floats that are whole numbers and have fewer than 8 trailing digits are represented with an exponent of 0
  - All other hexadecimal floats are represented with an odd significand
  - Number literals may follow similar consistency rules to blocks (see above)
- [ ] Support import sorting (disable with the `--no-rearrange` flag)
- [ ] Add blank lines after shebangs, header comments and imports
