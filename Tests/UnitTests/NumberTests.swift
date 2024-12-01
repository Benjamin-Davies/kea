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
}
