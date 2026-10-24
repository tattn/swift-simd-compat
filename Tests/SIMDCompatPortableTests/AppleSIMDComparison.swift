#if canImport(simd)
import simd
import SIMDCompatPortable

/// Deterministic inputs, so that a failure reproduces.
struct SplitMix64: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state &+= 0x9E37_79B9_7F4A_7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58_476D_1CE4_E5B9
        z = (z ^ (z >> 27)) &* 0x94D0_49BB_1331_11EB
        return z ^ (z >> 31)
    }
}

/// Inputs and conversions shared by the comparisons with Apple's `simd`.
struct AppleSIMDComparison {
    static let sampleCount = 200

    var random = SplitMix64(seed: 0x5EED)

    mutating func scalar(in range: ClosedRange<Float> = -2...2) -> Float {
        Float.random(in: range, using: &random)
    }

    mutating func vector3() -> SIMD3<Float> {
        SIMD3(scalar(), scalar(), scalar())
    }

    mutating func vector4() -> SIMD4<Float> {
        SIMD4(scalar(), scalar(), scalar(), scalar())
    }

    mutating func unitVector() -> SIMD3<Float> {
        while true {
            let vector = vector3()
            let length = simd.simd_length(vector)
            if length > 0.1 { return vector / length }
        }
    }

    mutating func rotation() -> simd.simd_quatf {
        simd.simd_quatf(angle: scalar(in: -.pi ... .pi), axis: unitVector())
    }

    /// A rotation, a non-uniform scale and a translation, so that the inverse is well defined.
    mutating func transform() -> simd.simd_float4x4 {
        let rotation = simd.simd_float4x4(self.rotation())
        let scale = simd.simd_float4x4(diagonal: SIMD4(scalar(in: 0.5...2), scalar(in: 0.5...2), scalar(in: 0.5...2), 1))
        var transform = rotation * scale
        transform.columns.3 = SIMD4(vector3(), 1)
        return transform
    }

    mutating func matrix3x3() -> simd.simd_float3x3 {
        let transform = self.transform()
        return simd.simd_float3x3(
            SIMD3(transform.columns.0.x, transform.columns.0.y, transform.columns.0.z),
            SIMD3(transform.columns.1.x, transform.columns.1.y, transform.columns.1.z),
            SIMD3(transform.columns.2.x, transform.columns.2.y, transform.columns.2.z)
        )
    }
}

func portable(_ quaternion: simd.simd_quatf) -> SIMDCompatPortable.simd_quatf {
    SIMDCompatPortable.simd_quatf(vector: quaternion.vector)
}

func portable(_ matrix: simd.simd_float3x3) -> SIMDCompatPortable.simd_float3x3 {
    SIMDCompatPortable.simd_float3x3(matrix.columns.0, matrix.columns.1, matrix.columns.2)
}

func portable(_ matrix: simd.simd_float4x4) -> SIMDCompatPortable.simd_float4x4 {
    SIMDCompatPortable.simd_float4x4(matrix.columns.0, matrix.columns.1, matrix.columns.2, matrix.columns.3)
}

func isClose<V: SIMD>(_ lhs: V, _ rhs: V, tolerance: Float = 1e-4) -> Bool where V.Scalar == Float {
    var scale = Float(1)
    var difference = Float(0)
    for index in lhs.indices {
        scale = max(scale, abs(lhs[index]), abs(rhs[index]))
        difference = max(difference, abs(lhs[index] - rhs[index]))
    }
    return difference <= tolerance * scale
}

func isClose(_ lhs: Float, _ rhs: Float, tolerance: Float = 1e-4) -> Bool {
    isClose(SIMD2(lhs, 0), SIMD2(rhs, 0), tolerance: tolerance)
}

func isClose(_ lhs: SIMDCompatPortable.simd_float3x3, _ rhs: simd.simd_float3x3, tolerance: Float = 1e-4) -> Bool {
    isClose(lhs.columns.0, rhs.columns.0, tolerance: tolerance)
        && isClose(lhs.columns.1, rhs.columns.1, tolerance: tolerance)
        && isClose(lhs.columns.2, rhs.columns.2, tolerance: tolerance)
}

func isClose(_ lhs: SIMDCompatPortable.simd_float4x4, _ rhs: simd.simd_float4x4, tolerance: Float = 1e-4) -> Bool {
    isClose(lhs.columns.0, rhs.columns.0, tolerance: tolerance)
        && isClose(lhs.columns.1, rhs.columns.1, tolerance: tolerance)
        && isClose(lhs.columns.2, rhs.columns.2, tolerance: tolerance)
        && isClose(lhs.columns.3, rhs.columns.3, tolerance: tolerance)
}

/// Equal as rotations: `q` and `-q` describe the same one.
func isSameRotation(_ lhs: SIMDCompatPortable.simd_quatf, _ rhs: simd.simd_quatf, tolerance: Float = 1e-4) -> Bool {
    isClose(lhs.vector, rhs.vector, tolerance: tolerance) || isClose(-lhs.vector, rhs.vector, tolerance: tolerance)
}
#endif
