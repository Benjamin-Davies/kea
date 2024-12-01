import Kea
import Testing

@Suite("Number formatting tests")
struct NumberTests {
    @Test(
        "Format integers",
        arguments: [
            ("0b11", "0b0011"),
            ("0b110011", "0b0011_0011"),
            ("0b1100110011", "0b0000_0011_0011_0011"),
            ("0o7", "0o7"),
            ("0o12", "0o012"),
            ("0o0012345", "0o012_345"),
            ("0", "0"),
            ("42", "42"),
            ("100_00_00", "1_000_000"),
            ("0xff00_ff", "0x00ff_00ff"),
        ])
    func formatIntegers(input: String, expected: String) {
        #expect(formatInteger(input) == expected)
        #expect(formatInteger(expected) == expected)
    }

    @Test(
        "Parse floats",
        arguments: [
            ("3.14", "314", 1),
            ("0.185_289", "185289", 0),
            ("3e8", "3", 9),
            ("1.2e-5", "12", -4),
        ])
    func parseFloats(input: String, expectedSignificand: String, expectedExponent: Int) {
        let float = DecimalFloat(input)
        #expect(float.significand == expectedSignificand)
        #expect(float.exponent == expectedExponent)
    }

    @Test(
        "Format floats",
        arguments: [
            ("314e-2", "3.14"),
            (".1852890", "0.185_289"),
            ("3e+8", "3e8"),
            ("0.000012", "1.2e-5"),
        ])
    func formatFloats(input: String, expected: String) {
        #expect(formatFloat(input) == expected)
        #expect(formatFloat(expected) == expected)
    }

    @Test(
        "Parse hex floats",
        arguments: [
            ("0x2ap0", "10101", 6),
            ("0x15p1", "10101", 6),
            ("0x1.5p5", "10101", 6),
            ("0x0.a8p6", "10101", 6),
        ])
    func parseHexFloats(input: String, expectedSignificand: String, expectedExponent: Int) {
        let expectedBinarySignificand = expectedSignificand.map { $0 == "1" }
        let float = HexFloat(input)
        #expect(float.significand == expectedBinarySignificand)
        #expect(float.exponent == expectedExponent)
    }

    @Test(
        "Format hex floats",
        arguments: [
            ("0x0p3", "0x0p0"),
            ("0x2ap0", "0x1.5000p5"),
            ("0x3.243F6Cp0", "0x1.921f_b600p1"),
        ])
    func formatHexFloats(input: String, expected: String) {
        #expect(formatFloat(input) == expected)
        #expect(formatFloat(expected) == expected)
    }
}
