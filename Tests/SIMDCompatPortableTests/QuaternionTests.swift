#if canImport(simd)
import simd
import SIMDCompatPortable
import Testing

@Suite
struct QuaternionTests {
    @Test func matchesAppleSIMD() {
        var inputs = AppleSIMDComparison()
        for _ in 0..<AppleSIMDComparison.sampleCount {
            let angle = inputs.scalar(in: -.pi ... .pi)
            let axis = inputs.unitVector()
            let a = inputs.rotation()
            let b = inputs.rotation()
            let vector = inputs.vector3()
            #expect(isClose(SIMDCompatPortable.simd_quatf(angle: angle, axis: axis).vector, simd.simd_quatf(angle: angle, axis: axis).vector))
            #expect(isClose(portable(a).act(vector), a.act(vector)))
            #expect(isClose((portable(a) * portable(b)).vector, (a * b).vector))
            #expect(isClose(portable(a).conjugate.vector, a.conjugate.vector))
            #expect(isClose(portable(a).inverse.vector, a.inverse.vector))
            #expect(isClose(portable(a).angle, a.angle))
            #expect(isClose(portable(a).axis, a.axis, tolerance: 1e-3))
            #expect(isClose(portable(a).length, a.length))

            let unnormalized = simd.simd_quatf(vector: inputs.vector4())
            #expect(isClose(portable(unnormalized).normalized.vector, unnormalized.normalized.vector))
            #expect(isClose(portable(unnormalized).inverse.vector, unnormalized.inverse.vector))
        }
    }

    @Test func rotationBetweenVectorsMatchesAppleSIMD() {
        var inputs = AppleSIMDComparison()
        for _ in 0..<AppleSIMDComparison.sampleCount {
            let from = inputs.unitVector()
            let to = inputs.unitVector()
            let rotation = SIMDCompatPortable.simd_quatf(from: from, to: to)
            #expect(isSameRotation(rotation, simd.simd_quatf(from: from, to: to)))
            #expect(isClose(rotation.act(from), to))
        }
    }

    @Test func rotationBetweenOppositeVectorsTurnsOneIntoTheOther() {
        for from in [SIMD3<Float>(1, 0, 0), SIMD3(0, 1, 0), SIMD3(0, 0, -1), simd.simd_normalize(SIMD3<Float>(1, 2, 3))] {
            let rotation = SIMDCompatPortable.simd_quatf(from: from, to: -from)
            #expect(isClose(rotation.act(from), -from))
            #expect(isClose(rotation.length, 1))
        }
    }

    @Test func rotationFromMatrixMatchesAppleSIMD() {
        var inputs = AppleSIMDComparison()
        for _ in 0..<AppleSIMDComparison.sampleCount {
            let rotation = inputs.rotation()
            let matrix3x3 = simd.simd_float3x3(rotation)
            let matrix4x4 = simd.simd_float4x4(rotation)
            #expect(isSameRotation(SIMDCompatPortable.simd_quatf(portable(matrix3x3)), simd.simd_quatf(matrix3x3)))
            #expect(isSameRotation(SIMDCompatPortable.simd_quatf(portable(matrix4x4)), simd.simd_quatf(matrix4x4)))
        }
    }

    @Test func slerpMatchesAppleSIMD() {
        var inputs = AppleSIMDComparison()
        for _ in 0..<AppleSIMDComparison.sampleCount {
            let a = inputs.rotation()
            let b = inputs.rotation()
            let t = inputs.scalar(in: 0...1)
            #expect(isSameRotation(SIMDCompatPortable.simd_slerp(portable(a), portable(b), t), simd.simd_slerp(a, b, t)))
            // Nearly the same rotation, where the interpolation falls back to a linear blend.
            let close = a * simd.simd_quatf(angle: 1e-5, axis: inputs.unitVector())
            #expect(isSameRotation(SIMDCompatPortable.simd_slerp(portable(a), portable(close), t), simd.simd_slerp(a, close, t)))
        }
    }

    @Test func freeFunctionsMatchTheMembers() {
        var inputs = AppleSIMDComparison()
        let a = portable(inputs.rotation())
        let b = portable(inputs.rotation())
        let vector = inputs.vector3()
        #expect(SIMDCompatPortable.simd_mul(a, b) == a * b)
        #expect(SIMDCompatPortable.simd_act(a, vector) == a.act(vector))
        #expect(SIMDCompatPortable.simd_inverse(a) == a.inverse)
        #expect(SIMDCompatPortable.simd_conjugate(a) == a.conjugate)
        #expect(SIMDCompatPortable.simd_normalize(a) == a.normalized)
        #expect(SIMDCompatPortable.simd_length(a) == a.length)
        #expect(SIMDCompatPortable.simd_angle(a) == a.angle)
        #expect(SIMDCompatPortable.simd_axis(a) == a.axis)
        #expect(SIMDCompatPortable.simd_dot(a, b) == SIMDCompatPortable.simd_dot(a.vector, b.vector))
    }
}
#endif
