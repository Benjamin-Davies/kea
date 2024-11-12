struct Token {
    let text: String

    /// UInt.max means it will never be split
    var stickiness: UInt = .max

    var attachLeft: Bool = false
    var attachRight: Bool = false

    var startIndent: Bool = false
    var endIndent: Bool = false
    var hangingIndent: Bool = false
    var doubleHangingIndent: Bool = false

    var newline: Bool = false
    var doubleNewline: Bool = false
    var omitIfNotLastOnLine: Bool = false

    init(_ text: String) {
        self.text = text
    }
}
