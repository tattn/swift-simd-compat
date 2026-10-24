// Import this instead of `simd` in code that also builds where Apple's `simd` module is unavailable.
// On Apple platforms it is `simd` itself. Elsewhere it provides the same names on top of the standard
// library's `SIMD` types, and the platform's C library, since `simd` also exports the C math functions.
#if canImport(simd)
@_exported public import simd
#else
@_exported public import SIMDCompatPortable
#if canImport(Android)
@_exported public import Android
#elseif canImport(Glibc)
@_exported public import Glibc
#endif
#endif
