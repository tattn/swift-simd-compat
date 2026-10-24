import SIMDCompat
import Testing

/// Checks what `SIMDCompat` provides on every platform against values worked out by hand: `simd` itself
/// on Apple platforms, the portable implementation elsewhere.
@Suite
struct SIMDCompatTests {
    @Test func quarterTurnAroundUpTurnsRightIntoBack() {
        let rotation = simd_quatf(angle: .pi / 2, axis: SIMD3(0, 1, 0))
        let turned = rotation.act(SIMD3(1, 0, 0))
        #expect(simd_distance(turned, SIMD3(0, 0, -1)) < 1e-6)
        #expect(abs(rotation.angle - .pi / 2) < 1e-6)
    }

    @Test func inverseUndoesATransform() {
        var transform = simd_float4x4(simd_quatf(angle: 0.7, axis: simd_normalize(SIMD3(1, 2, 3))))
        transform.columns.3 = SIMD4(1, -2, 3, 1)
        let point = SIMD4<Float>(0.5, 4, -1, 1)
        let restored = transform.inverse * (transform * point)
        #expect(simd_distance(restored, point) < 1e-5)
        #expect(abs(transform.determinant - 1) < 1e-5)
    }

    @Test func rotationMatrixAndQuaternionAgree() {
        let rotation = simd_quatf(angle: -1.2, axis: simd_normalize(SIMD3(-1, 1, 0.5)))
        let vector = SIMD3<Float>(0.3, -2, 1)
        #expect(simd_distance(simd_float3x3(rotation) * vector, rotation.act(vector)) < 1e-5)
        #expect(abs(abs(simd_dot(simd_quatf(simd_float3x3(rotation)).vector, rotation.vector)) - 1) < 1e-5)
    }

    @Test func slerpHalfwayTurnsHalfTheAngle() {
        let start = simd_quatf(angle: 0, axis: SIMD3(0, 0, 1))
        let end = simd_quatf(angle: 1, axis: SIMD3(0, 0, 1))
        #expect(abs(simd_slerp(start, end, 0.5).angle - 0.5) < 1e-5)
    }

    @Test func mathFunctionsAreAvailable() {
        #expect(abs(atan2(Float(1), Float(1)) - .pi / 4) < 1e-6)
        #expect(abs(pow(Float(2), Float(10)) - 1024) < 1e-3)
    }
}
