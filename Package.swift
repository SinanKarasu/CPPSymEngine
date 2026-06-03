// swift-tools-version: 6.3
import PackageDescription

let package = Package(
    name: "CPPSymEngine",
    products: [
        .library(name: "CPPSymEngine", targets: ["CPPSymEngine"]),
    ],
    targets: [
        .target(
            name: "SymEngineCore",
            path: "Vendor/symengine/symengine",
            exclude: [
                "CMakeLists.txt",
                "symengine_config.h.in",
                "symengine_config_cling.h.in",
                "tests",
                "utilities/catch",
                "utilities/teuchos",
                "utilities/matchpycpp/autogen_tests",
                "utilities/matchpycpp/tests",
                "parser/parser.yy",
                "parser/tokenizer.re",
                "parser/sbml/sbml_parser.yy",
                "parser/sbml/sbml_tokenizer.re",
                "eval_arb.cpp",
                "eval_mpc.cpp",
                "eval_mpfr.cpp",
                "real_mpfr.cpp",
                "complex_mpc.cpp",
                "llvm_double.cpp",
                "mp_wrapper.cpp",
                "series_flint.cpp",
                "series_piranha.cpp",
                "polys/uintpoly_flint.cpp",
                "polys/uintpoly_piranha.cpp",
                "as_real_imag.cpp"
            ],
            publicHeadersPath: "spm",
            cxxSettings: [
                .headerSearchPath(".."),
                .headerSearchPath("utilities/fast_float/include"),
                .headerSearchPath("utilities/cereal/include"),
                .define("symengine_EXPORTS"),
                .define("SYMENGINE_FORCE_NO_THREADS", .when(platforms: [.visionOS])),
                .define("_LIBCPP_HAS_NO_THREADS", .when(platforms: [.visionOS])),
                .unsafeFlags(["-I/opt/homebrew/include"])
            ]
        ),
        .target(
            name: "CSymEngineBridge",
            dependencies: ["SymEngineCore"],
            path: "Sources/CSymEngineBridge",
            publicHeadersPath: "include",
            cSettings: [
                .headerSearchPath("include"),
                .headerSearchPath("../../Vendor/symengine")
            ]
        ),
        .target(
            name: "CPPSymEngine",
            dependencies: [
                .target(name: "CSymEngineBridge", condition: .when(platforms: [.macOS])),
            ]
        ),
        .testTarget(
            name: "CPPSymEngineTests",
            dependencies: ["CPPSymEngine"]
        ),
    ],
    swiftLanguageModes: [.v6]
)
