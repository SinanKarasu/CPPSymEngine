import Foundation

#if canImport(CSymEngineBridge)
import CSymEngineBridge

public enum SymEngineError: Error, CustomStringConvertible {
    case code(Int32)
    case allocationFailed
    case invalidUTF8
    case nonNumericResult(String)
    case unsupportedPlatform

    public var description: String {
        switch self {
        case .code(let code):
            return "SymEngine C API returned error code \(code)"
        case .allocationFailed:
            return "SymEngine allocation failed"
        case .invalidUTF8:
            return "SymEngine returned invalid UTF-8"
        case .nonNumericResult(let value):
            return "Expected a numeric result, got \(value)"
        case .unsupportedPlatform:
            return "SymEngine is unavailable on this platform"
        }
    }
}

public final class Basic: CustomStringConvertible, Equatable {
    private let handle: se_basic_t

    public init() throws {
        guard let ptr = se_basic_new() else {
            throw SymEngineError.allocationFailed
        }
        self.handle = ptr
    }

    deinit {
        se_basic_free(handle)
    }

    private init(taking handle: se_basic_t) {
        self.handle = handle
    }

    public static func integer(_ value: Int) throws -> Basic {
        let basic = try Basic()
        try basic.check(se_integer_set_si(basic.handle, Int(value)))
        return basic
    }

    public static func rational(_ numerator: Int, _ denominator: Int) throws -> Basic {
        let basic = try Basic()
        try basic.check(se_rational_set_si(basic.handle, Int(numerator), Int(denominator)))
        return basic
    }

    public static func realDouble(_ value: Double) throws -> Basic {
        let basic = try Basic()
        try basic.check(se_real_double_set_d(basic.handle, value))
        return basic
    }

    public static func symbol(_ name: String) throws -> Basic {
        let basic = try Basic()
        try name.withCString { cName in
            try basic.check(se_symbol_set(basic.handle, cName))
        }
        return basic
    }

    public static func parse(_ expression: String) throws -> Basic {
        let basic = try Basic()
        try expression.withCString { cExpression in
            try basic.check(se_basic_parse(basic.handle, cExpression))
        }
        return basic
    }

    public var description: String {
        guard let raw = se_basic_str(handle) else {
            return "<null>"
        }
        defer { se_string_free(raw) }
        guard let text = String(validatingCString: raw) else {
            return "<invalid-utf8>"
        }
        return text
    }

    public func clone() throws -> Basic {
        guard let ptr = se_basic_new() else {
            throw SymEngineError.allocationFailed
        }
        let value = Basic(taking: ptr)
        try value.check(se_basic_assign(value.handle, handle))
        return value
    }

    public func differentiated(by symbol: Basic) throws -> Basic {
        try Self.binaryOp(self, symbol, se_basic_diff)
    }

    public func differentiated(by symbolName: String) throws -> Basic {
        let symbol = try Self.symbol(symbolName)
        return try differentiated(by: symbol)
    }

    public func expanded() throws -> Basic {
        try Self.unaryOp(self, se_basic_expand)
    }

    public func negated() throws -> Basic {
        try Self.unaryOp(self, se_basic_neg)
    }

    public func evaluated(bits: UInt = 53, real: Bool = true) throws -> Basic {
        let result = try Self()
        try result.check(se_basic_evalf(result.handle, handle, bits, real ? 1 : 0))
        return result
    }

    public func asDouble(bits: UInt = 53) throws -> Double {
        let numeric = try evaluated(bits: bits, real: true)
        if se_basic_is_real_double(numeric.handle) != 0 {
            return se_real_double_get_d(numeric.handle)
        }
        if se_basic_is_integer(numeric.handle) != 0 {
            return Double(se_integer_get_si(numeric.handle))
        }
        let text = numeric.description
        if let value = Double(text) {
            return value
        }
        throw SymEngineError.nonNumericResult(text)
    }

    public func substituting(_ substitutions: [String: Basic]) throws -> Basic {
        guard let rawMap = se_basic_map_new() else {
            throw SymEngineError.allocationFailed
        }
        defer { se_basic_map_free(rawMap) }

        for (name, value) in substitutions {
            let symbol = try Self.symbol(name)
            se_basic_map_insert(rawMap, symbol.handle, value.handle)
        }

        let result = try Self()
        try result.check(se_basic_subs_map(result.handle, handle, rawMap))
        return result
    }

    public func substituting(_ substitutions: [String: Double]) throws -> Basic {
        var basics: [String: Basic] = [:]
        basics.reserveCapacity(substitutions.count)
        for (name, value) in substitutions {
            basics[name] = try Self.realDouble(value)
        }
        return try substituting(basics)
    }

    public func substituting(symbol symbolName: String, with replacement: Basic) throws -> Basic {
        let symbol = try Self.symbol(symbolName)
        return try Self.binaryOp(self, symbol, replacement, se_basic_subs_pair)
    }

    public func freeSymbols() throws -> [Basic] {
        guard let rawSet = se_basic_set_new() else {
            throw SymEngineError.allocationFailed
        }
        defer { se_basic_set_free(rawSet) }

        try check(se_basic_free_symbols(handle, rawSet))
        let count = Int(se_basic_set_size(rawSet))
        var values: [Basic] = []
        values.reserveCapacity(count)
        for index in 0..<count {
            let item = try Self()
            try item.check(se_basic_set_get(rawSet, Int32(index), item.handle))
            values.append(item)
        }
        return values
    }

    public func freeSymbolNames() throws -> [String] {
        try freeSymbols().map(\.description).sorted()
    }

    public static func == (lhs: Basic, rhs: Basic) -> Bool {
        se_basic_eq(lhs.handle, rhs.handle) != 0
    }

    public static func + (lhs: Basic, rhs: Basic) throws -> Basic {
        try binaryOp(lhs, rhs, se_basic_add)
    }

    public static func - (lhs: Basic, rhs: Basic) throws -> Basic {
        try binaryOp(lhs, rhs, se_basic_sub)
    }

    public static func * (lhs: Basic, rhs: Basic) throws -> Basic {
        try binaryOp(lhs, rhs, se_basic_mul)
    }

    public static func / (lhs: Basic, rhs: Basic) throws -> Basic {
        try binaryOp(lhs, rhs, se_basic_div)
    }

    public func pow(_ exponent: Basic) throws -> Basic {
        try Self.binaryOp(self, exponent, se_basic_pow)
    }

    public static func abs(_ value: Basic) throws -> Basic {
        try unaryOp(value, se_basic_abs)
    }

    public static func sin(_ value: Basic) throws -> Basic {
        try unaryOp(value, se_basic_sin)
    }

    public static func cos(_ value: Basic) throws -> Basic {
        try unaryOp(value, se_basic_cos)
    }

    public static func tan(_ value: Basic) throws -> Basic {
        try unaryOp(value, se_basic_tan)
    }

    public static func asin(_ value: Basic) throws -> Basic {
        try unaryOp(value, se_basic_asin)
    }

    public static func acos(_ value: Basic) throws -> Basic {
        try unaryOp(value, se_basic_acos)
    }

    public static func atan(_ value: Basic) throws -> Basic {
        try unaryOp(value, se_basic_atan)
    }

    public static func sinh(_ value: Basic) throws -> Basic {
        try unaryOp(value, se_basic_sinh)
    }

    public static func cosh(_ value: Basic) throws -> Basic {
        try unaryOp(value, se_basic_cosh)
    }

    public static func tanh(_ value: Basic) throws -> Basic {
        try unaryOp(value, se_basic_tanh)
    }

    public static func exp(_ value: Basic) throws -> Basic {
        try unaryOp(value, se_basic_exp)
    }

    public static func log(_ value: Basic) throws -> Basic {
        try unaryOp(value, se_basic_log)
    }

    public static func sqrt(_ value: Basic) throws -> Basic {
        try unaryOp(value, se_basic_sqrt)
    }

    public static func pi() throws -> Basic {
        let value = try Self()
        se_basic_const_pi(value.handle)
        return value
    }

    public static func e() throws -> Basic {
        let value = try Self()
        se_basic_const_e(value.handle)
        return value
    }

    private typealias UnaryOp = @convention(c) (se_basic_t?, se_basic_t?) -> Int32
    private typealias BinaryOp = @convention(c) (se_basic_t?, se_basic_t?, se_basic_t?) -> Int32
    private typealias TernaryOp = @convention(c) (se_basic_t?, se_basic_t?, se_basic_t?, se_basic_t?) -> Int32

    private static func unaryOp(
        _ value: Basic,
        _ op: UnaryOp
    ) throws -> Basic {
        let result = try Self()
        try result.check(op(result.handle, value.handle))
        return result
    }

    private static func binaryOp(
        _ lhs: Basic,
        _ rhs: Basic,
        _ op: BinaryOp
    ) throws -> Basic {
        let result = try Self()
        try result.check(op(result.handle, lhs.handle, rhs.handle))
        return result
    }

    private static func binaryOp(
        _ first: Basic,
        _ second: Basic,
        _ third: Basic,
        _ op: TernaryOp
    ) throws -> Basic {
        let result = try Self()
        try result.check(op(result.handle, first.handle, second.handle, third.handle))
        return result
    }

    private func check(_ code: Int32) throws {
        if code != 0 {
            throw SymEngineError.code(code)
        }
    }
}

#else

public enum SymEngineError: Error, CustomStringConvertible {
    case unsupportedPlatform

    public var description: String {
        "SymEngine is unavailable on this platform"
    }
}

public final class Basic: CustomStringConvertible, Equatable {
    private init(uncheckedDescription description: String = "<unsupported-platform>") {
        self.description = description
    }

    public convenience init() throws {
        throw SymEngineError.unsupportedPlatform
    }

    public let description: String

    public static func integer(_ value: Int) throws -> Basic { throw SymEngineError.unsupportedPlatform }
    public static func rational(_ numerator: Int, _ denominator: Int) throws -> Basic { throw SymEngineError.unsupportedPlatform }
    public static func realDouble(_ value: Double) throws -> Basic { throw SymEngineError.unsupportedPlatform }
    public static func symbol(_ name: String) throws -> Basic { throw SymEngineError.unsupportedPlatform }
    public static func parse(_ expression: String) throws -> Basic { throw SymEngineError.unsupportedPlatform }
    public func clone() throws -> Basic { throw SymEngineError.unsupportedPlatform }
    public func differentiated(by symbol: Basic) throws -> Basic { throw SymEngineError.unsupportedPlatform }
    public func differentiated(by symbolName: String) throws -> Basic { throw SymEngineError.unsupportedPlatform }
    public func expanded() throws -> Basic { throw SymEngineError.unsupportedPlatform }
    public func negated() throws -> Basic { throw SymEngineError.unsupportedPlatform }
    public func evaluated(bits: UInt = 53, real: Bool = true) throws -> Basic { throw SymEngineError.unsupportedPlatform }
    public func asDouble(bits: UInt = 53) throws -> Double { throw SymEngineError.unsupportedPlatform }
    public func substituting(_ substitutions: [String: Basic]) throws -> Basic { throw SymEngineError.unsupportedPlatform }
    public func substituting(_ substitutions: [String: Double]) throws -> Basic { throw SymEngineError.unsupportedPlatform }
    public func substituting(symbol symbolName: String, with replacement: Basic) throws -> Basic { throw SymEngineError.unsupportedPlatform }
    public func freeSymbols() throws -> [Basic] { throw SymEngineError.unsupportedPlatform }
    public func freeSymbolNames() throws -> [String] { throw SymEngineError.unsupportedPlatform }

    public static func == (lhs: Basic, rhs: Basic) -> Bool {
        lhs === rhs || lhs.description == rhs.description
    }

    public static func + (lhs: Basic, rhs: Basic) throws -> Basic { throw SymEngineError.unsupportedPlatform }
    public static func - (lhs: Basic, rhs: Basic) throws -> Basic { throw SymEngineError.unsupportedPlatform }
    public static func * (lhs: Basic, rhs: Basic) throws -> Basic { throw SymEngineError.unsupportedPlatform }
    public static func / (lhs: Basic, rhs: Basic) throws -> Basic { throw SymEngineError.unsupportedPlatform }
    public func pow(_ exponent: Basic) throws -> Basic { throw SymEngineError.unsupportedPlatform }
    public static func abs(_ value: Basic) throws -> Basic { throw SymEngineError.unsupportedPlatform }
    public static func sin(_ value: Basic) throws -> Basic { throw SymEngineError.unsupportedPlatform }
    public static func cos(_ value: Basic) throws -> Basic { throw SymEngineError.unsupportedPlatform }
    public static func tan(_ value: Basic) throws -> Basic { throw SymEngineError.unsupportedPlatform }
    public static func asin(_ value: Basic) throws -> Basic { throw SymEngineError.unsupportedPlatform }
    public static func acos(_ value: Basic) throws -> Basic { throw SymEngineError.unsupportedPlatform }
    public static func atan(_ value: Basic) throws -> Basic { throw SymEngineError.unsupportedPlatform }
    public static func sinh(_ value: Basic) throws -> Basic { throw SymEngineError.unsupportedPlatform }
    public static func cosh(_ value: Basic) throws -> Basic { throw SymEngineError.unsupportedPlatform }
    public static func tanh(_ value: Basic) throws -> Basic { throw SymEngineError.unsupportedPlatform }
    public static func exp(_ value: Basic) throws -> Basic { throw SymEngineError.unsupportedPlatform }
    public static func log(_ value: Basic) throws -> Basic { throw SymEngineError.unsupportedPlatform }
    public static func sqrt(_ value: Basic) throws -> Basic { throw SymEngineError.unsupportedPlatform }
    public static func pi() throws -> Basic { throw SymEngineError.unsupportedPlatform }
    public static func e() throws -> Basic { throw SymEngineError.unsupportedPlatform }
}

#endif
