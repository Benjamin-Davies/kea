struct Token {
    let text: String

    /// UInt.max means it will never be split
    var stickiness: UInt = UInt.max

    var attachLeft: Bool = false
    var attachRight: Bool = false

    var startIndent: Bool = false
    var endIndent: Bool = false

    var doubleNewline: Bool = false
    var omitIfNotLastOnLine: Bool = false

    init(_ text: String) {
        self.text = text
    }
}
