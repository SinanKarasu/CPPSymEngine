import CSymEngineBridge
import Foundation

public enum SymEngineError: Error {
    case code(Int32)
    case allocationFailed
    case invalidUTF8
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

    public static func pi() throws -> Basic {
        let value = try Basic()
        se_basic_const_pi(value.handle)
        return value
    }

    public static func e() throws -> Basic {
        let value = try Basic()
        se_basic_const_e(value.handle)
        return value
    }

    private typealias BinaryOp = @convention(c) (se_basic_t?, se_basic_t?, se_basic_t?) -> Int32

    private static func binaryOp(
        _ lhs: Basic,
        _ rhs: Basic,
        _ op: BinaryOp
    ) throws -> Basic {
        let result = try Basic()
        try result.check(op(result.handle, lhs.handle, rhs.handle))
        return result
    }

    private func check(_ code: Int32) throws {
        if code != 0 {
            throw SymEngineError.code(code)
        }
    }
}
