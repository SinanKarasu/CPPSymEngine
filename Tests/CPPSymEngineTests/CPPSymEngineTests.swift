import Testing
@testable import CPPSymEngine

@Test func smoke() throws {
    let x = try Basic.symbol("x")
    let one = try Basic.integer(1)
    let expr = try x + one
    #expect(expr.description == "1 + x" || expr.description == "x + 1")
}

@Test func differentiateAndEvaluate() throws {
    let x = try Basic.symbol("x")
    let a = try Basic.symbol("a")
    let b = try Basic.symbol("b")
    let expr = try ((try a * x) + b).expanded()

    let derivative = try expr.differentiated(by: "x").expanded()
    #expect(derivative.description == "a")

    let substituted = try expr.substituting([
        "x": 4.0,
        "a": 2.0,
        "b": 3.0,
    ])
    let value = try substituted.asDouble()
    #expect(abs(value - 11.0) < 1e-9)
}

@Test func freeSymbolsAreDiscoverable() throws {
    let expr = try Basic.parse("a*x + b")
    let symbols = try expr.freeSymbolNames()
    #expect(symbols == ["a", "b", "x"])
}
