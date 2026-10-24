#if canImport(simd)
import simd
import SIMDCompatPortable
import Testing

@Suite
struct MatrixTests {
    @Test func float3x3MatchesAppleSIMD() {
        var inputs = AppleSIMDComparison()
        for _ in 0..<AppleSIMDComparison.sampleCount {
            let a = inputs.matrix3x3()
            let b = inputs.matrix3x3()
            let vector = inputs.vector3()
            let scalar = inputs.scalar()
            let rotation = inputs.rotation()
            #expect(isClose(portable(a).transpose, a.transpose))
            #expect(isClose(portable(a).determinant, a.determinant))
            #expect(isClose(portable(a).inverse, a.inverse, tolerance: 1e-3))
            #expect(isClose(portable(a) * vector, a * vector))
            #expect(isClose(portable(a) * portable(b), a * b))
            #expect(isClose(portable(a) + portable(b), a + b))
            #expect(isClose(portable(a) - portable(b), a - b))
            #expect(isClose(portable(a) * scalar, a * scalar))
            #expect(isClose(SIMDCompatPortable.simd_float3x3(portable(rotation)), simd.simd_float3x3(rotation)))
        }
    }

    @Test func float4x4MatchesAppleSIMD() {
        var inputs = AppleSIMDComparison()
        for _ in 0..<AppleSIMDComparison.sampleCount {
            let a = inputs.transform()
            let b = inputs.transform()
            let vector = inputs.vector4()
            let scalar = inputs.scalar()
            let rotation = inputs.rotation()
            #expect(isClose(portable(a).transpose, a.transpose))
            #expect(isClose(portable(a).determinant, a.determinant))
            #expect(isClose(portable(a).inverse, a.inverse, tolerance: 1e-3))
            #expect(isClose(portable(a) * vector, a * vector))
            #expect(isClose(portable(a) * portable(b), a * b))
            #expect(isClose(portable(a) + portable(b), a + b))
            #expect(isClose(portable(a) - portable(b), a - b))
            #expect(isClose(portable(a) * scalar, a * scalar))
            #expect(isClose(SIMDCompatPortable.simd_float4x4(portable(rotation)), simd.simd_float4x4(rotation)))
        }
    }

    @Test func subscriptsReadAndWriteColumnsAndElements() {
        var matrix = SIMDCompatPortable.matrix_identity_float4x4
        matrix[3] = SIMD4(1, 2, 3, 1)
        matrix[0, 1] = 5
        #expect(matrix.columns.3 == SIMD4(1, 2, 3, 1))
        #expect(matrix.columns.0 == SIMD4(1, 5, 0, 0))
        #expect(matrix[2, 2] == 1)

        var apple = simd.matrix_identity_float4x4
        apple[3] = SIMD4(1, 2, 3, 1)
        apple[0, 1] = 5
        #expect(isClose(matrix, apple))
    }

    @Test func identitiesMatchAppleSIMD() {
        #expect(isClose(SIMDCompatPortable.matrix_identity_float3x3, simd.matrix_identity_float3x3))
        #expect(isClose(SIMDCompatPortable.matrix_identity_float4x4, simd.matrix_identity_float4x4))
    }
}
#endif
