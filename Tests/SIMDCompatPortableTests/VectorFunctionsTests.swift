#if canImport(simd)
import simd
import SIMDCompatPortable
import Testing

@Suite
struct VectorFunctionsTests {
    @Test func matchesAppleSIMD() {
        var inputs = AppleSIMDComparison()
        for _ in 0..<AppleSIMDComparison.sampleCount {
            let a = inputs.vector3()
            let b = inputs.vector3()
            let t = inputs.vector3()
            #expect(isClose(SIMDCompatPortable.simd_dot(a, b), simd.simd_dot(a, b)))
            #expect(isClose(SIMDCompatPortable.simd_length(a), simd.simd_length(a)))
            #expect(isClose(SIMDCompatPortable.simd_length_squared(a), simd.simd_length_squared(a)))
            #expect(isClose(SIMDCompatPortable.simd_distance(a, b), simd.simd_distance(a, b)))
            #expect(isClose(SIMDCompatPortable.simd_distance_squared(a, b), simd.simd_distance_squared(a, b)))
            #expect(isClose(SIMDCompatPortable.simd_normalize(a), simd.simd_normalize(a)))
            #expect(isClose(SIMDCompatPortable.simd_cross(a, b), simd.simd_cross(a, b)))
            #expect(SIMDCompatPortable.simd_abs(a) == simd.simd_abs(a))
            #expect(SIMDCompatPortable.simd_min(a, b) == simd.simd_min(a, b))
            #expect(SIMDCompatPortable.simd_max(a, b) == simd.simd_max(a, b))
            #expect(SIMDCompatPortable.simd_clamp(a, -abs(b), abs(b)) == simd.simd_clamp(a, -abs(b), abs(b)))
            #expect(isClose(SIMDCompatPortable.simd_mix(a, b, t), simd.simd_mix(a, b, t)))
            #expect(SIMDCompatPortable.simd_reduce_max(a) == simd.simd_reduce_max(a))
            #expect(SIMDCompatPortable.simd_reduce_min(a) == simd.simd_reduce_min(a))

            let x = inputs.scalar()
            let low = inputs.scalar(in: -2...0)
            let high = inputs.scalar(in: 0...2)
            #expect(SIMDCompatPortable.simd_clamp(x, low, high) == simd.simd_clamp(x, low, high))
            #expect(isClose(SIMDCompatPortable.simd_mix(x, low, high), simd.simd_mix(x, low, high)))
        }
    }

    @Test func unprefixedNamesMatchAppleSIMD() {
        var inputs = AppleSIMDComparison()
        for _ in 0..<AppleSIMDComparison.sampleCount {
            let a = inputs.vector4()
            let b = inputs.vector4()
            #expect(isClose(SIMDCompatPortable.dot(a, b), simd.dot(a, b)))
            #expect(isClose(SIMDCompatPortable.length(a), simd.length(a)))
            #expect(isClose(SIMDCompatPortable.length_squared(a), simd.length_squared(a)))
            #expect(isClose(SIMDCompatPortable.distance(a, b), simd.distance(a, b)))
            #expect(isClose(SIMDCompatPortable.distance_squared(a, b), simd.distance_squared(a, b)))
            #expect(isClose(SIMDCompatPortable.normalize(a), simd.normalize(a)))
            let c = SIMD3(a.x, a.y, a.z)
            let d = SIMD3(b.x, b.y, b.z)
            #expect(isClose(SIMDCompatPortable.cross(c, d), simd.cross(c, d)))
            let t = inputs.vector4()
            let s = inputs.scalar()
            #expect(isClose(SIMDCompatPortable.mix(a, b, t: t), simd.mix(a, b, t: t)))
            #expect(isClose(SIMDCompatPortable.mix(c, d, t: s), simd.mix(c, d, t: s)))
        }
    }

    @Test func absClearsTheSignOfZero() {
        let vector = SIMD3<Float>(-0.0, -1, 2)
        #expect(SIMDCompatPortable.simd_abs(vector).x.sign == simd.simd_abs(vector).x.sign)
    }
}
#endif
