func main() {
    print("Hello, world!")
}

func foo(a: UInt, b: UInt) -> UInt { 2 * a + b }

struct Bar {
    var a: UInt
    var b: UInt { 2 * a }
}
