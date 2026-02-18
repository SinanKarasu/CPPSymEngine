import Testing
@testable import CPPSymEngine

@Test func smoke() throws {
    let x = try Basic.symbol("x")
    let one = try Basic.integer(1)
    let expr = try x + one
    #expect(expr.description == "1 + x" || expr.description == "x + 1")
}
