/// A 4x4 matrix of `Float`, stored as columns like Apple's `simd_float4x4`.
public struct simd_float4x4: Equatable, Sendable {
    public var columns: (SIMD4<Float>, SIMD4<Float>, SIMD4<Float>, SIMD4<Float>)

    @inlinable
    public init(columns: (SIMD4<Float>, SIMD4<Float>, SIMD4<Float>, SIMD4<Float>)) {
        self.columns = columns
    }

    @inlinable
    public init(_ col0: SIMD4<Float>, _ col1: SIMD4<Float>, _ col2: SIMD4<Float>, _ col3: SIMD4<Float>) {
        columns = (col0, col1, col2, col3)
    }

    @inlinable
    public init(_ columns: [SIMD4<Float>]) {
        precondition(columns.count == 4, "simd_float4x4 needs 4 columns")
        self.init(columns[0], columns[1], columns[2], columns[3])
    }

    @inlinable
    public init(diagonal: SIMD4<Float>) {
        self.init(
            SIMD4(diagonal.x, 0, 0, 0),
            SIMD4(0, diagonal.y, 0, 0),
            SIMD4(0, 0, diagonal.z, 0),
            SIMD4(0, 0, 0, diagonal.w)
        )
    }

    /// The rotation `quaternion` describes.
    @inlinable
    public init(_ quaternion: simd_quatf) {
        let rotation = simd_float3x3(quaternion)
        self.init(
            SIMD4(rotation.columns.0, 0),
            SIMD4(rotation.columns.1, 0),
            SIMD4(rotation.columns.2, 0),
            SIMD4(0, 0, 0, 1)
        )
    }

    @inlinable
    public subscript(column: Int) -> SIMD4<Float> {
        get {
            switch column {
            case 0: columns.0
            case 1: columns.1
            case 2: columns.2
            case 3: columns.3
            default: preconditionFailure("Column index out of range")
            }
        }
        set {
            switch column {
            case 0: columns.0 = newValue
            case 1: columns.1 = newValue
            case 2: columns.2 = newValue
            case 3: columns.3 = newValue
            default: preconditionFailure("Column index out of range")
            }
        }
    }

    @inlinable
    public subscript(column: Int, row: Int) -> Float {
        get { self[column][row] }
        set { self[column][row] = newValue }
    }

    @inlinable
    public var transpose: simd_float4x4 {
        let (a, b, c, d) = columns
        return simd_float4x4(
            SIMD4(a.x, b.x, c.x, d.x),
            SIMD4(a.y, b.y, c.y, d.y),
            SIMD4(a.z, b.z, c.z, d.z),
            SIMD4(a.w, b.w, c.w, d.w)
        )
    }

    @inlinable
    public var determinant: Float {
        Minors(self).determinant
    }

    @inlinable
    public var inverse: simd_float4x4 {
        let (a, b, c, d) = columns
        let m = Minors(self)
        let scale = 1 / m.determinant
        return simd_float4x4(
            SIMD4(
                b.y * m.b11 - b.z * m.b10 + b.w * m.b09,
                a.z * m.b10 - a.y * m.b11 - a.w * m.b09,
                d.y * m.b05 - d.z * m.b04 + d.w * m.b03,
                c.z * m.b04 - c.y * m.b05 - c.w * m.b03
            ) * scale,
            SIMD4(
                b.z * m.b08 - b.x * m.b11 - b.w * m.b07,
                a.x * m.b11 - a.z * m.b08 + a.w * m.b07,
                d.z * m.b02 - d.x * m.b05 - d.w * m.b01,
                c.x * m.b05 - c.z * m.b02 + c.w * m.b01
            ) * scale,
            SIMD4(
                b.x * m.b10 - b.y * m.b08 + b.w * m.b06,
                a.y * m.b08 - a.x * m.b10 - a.w * m.b06,
                d.x * m.b04 - d.y * m.b02 + d.w * m.b00,
                c.y * m.b02 - c.x * m.b04 - c.w * m.b00
            ) * scale,
            SIMD4(
                b.y * m.b07 - b.x * m.b09 - b.z * m.b06,
                a.x * m.b09 - a.y * m.b07 + a.z * m.b06,
                d.y * m.b01 - d.x * m.b03 - d.z * m.b00,
                c.x * m.b03 - c.y * m.b01 + c.z * m.b00
            ) * scale
        )
    }

    @inlinable
    public static func == (lhs: simd_float4x4, rhs: simd_float4x4) -> Bool {
        lhs.columns.0 == rhs.columns.0 && lhs.columns.1 == rhs.columns.1
            && lhs.columns.2 == rhs.columns.2 && lhs.columns.3 == rhs.columns.3
    }

    @inlinable
    public static func + (lhs: simd_float4x4, rhs: simd_float4x4) -> simd_float4x4 {
        simd_float4x4(
            lhs.columns.0 + rhs.columns.0,
            lhs.columns.1 + rhs.columns.1,
            lhs.columns.2 + rhs.columns.2,
            lhs.columns.3 + rhs.columns.3
        )
    }

    @inlinable
    public static func - (lhs: simd_float4x4, rhs: simd_float4x4) -> simd_float4x4 {
        simd_float4x4(
            lhs.columns.0 - rhs.columns.0,
            lhs.columns.1 - rhs.columns.1,
            lhs.columns.2 - rhs.columns.2,
            lhs.columns.3 - rhs.columns.3
        )
    }

    @inlinable
    public static func * (matrix: simd_float4x4, scalar: Float) -> simd_float4x4 {
        simd_float4x4(
            matrix.columns.0 * scalar,
            matrix.columns.1 * scalar,
            matrix.columns.2 * scalar,
            matrix.columns.3 * scalar
        )
    }

    @inlinable
    public static func * (scalar: Float, matrix: simd_float4x4) -> simd_float4x4 {
        matrix * scalar
    }

    @inlinable
    public static func * (matrix: simd_float4x4, vector: SIMD4<Float>) -> SIMD4<Float> {
        matrix.columns.0 * vector.x + matrix.columns.1 * vector.y + matrix.columns.2 * vector.z
            + matrix.columns.3 * vector.w
    }

    @inlinable
    public static func * (lhs: simd_float4x4, rhs: simd_float4x4) -> simd_float4x4 {
        simd_float4x4(lhs * rhs.columns.0, lhs * rhs.columns.1, lhs * rhs.columns.2, lhs * rhs.columns.3)
    }
}

extension simd_float4x4 {
    /// The 2x2 minors that the determinant and the inverse share: `b00`...`b05` from the first two
    /// columns and `b06`...`b11` from the last two, over each pair of rows.
    @usableFromInline
    struct Minors {
        @usableFromInline let b00, b01, b02, b03, b04, b05: Float
        @usableFromInline let b06, b07, b08, b09, b10, b11: Float

        @inlinable
        init(_ matrix: simd_float4x4) {
            let (a, b, c, d) = matrix.columns
            b00 = a.x * b.y - a.y * b.x
            b01 = a.x * b.z - a.z * b.x
            b02 = a.x * b.w - a.w * b.x
            b03 = a.y * b.z - a.z * b.y
            b04 = a.y * b.w - a.w * b.y
            b05 = a.z * b.w - a.w * b.z
            b06 = c.x * d.y - c.y * d.x
            b07 = c.x * d.z - c.z * d.x
            b08 = c.x * d.w - c.w * d.x
            b09 = c.y * d.z - c.z * d.y
            b10 = c.y * d.w - c.w * d.y
            b11 = c.z * d.w - c.w * d.z
        }

        @inlinable
        var determinant: Float {
            b00 * b11 - b01 * b10 + b02 * b09 + b03 * b08 - b04 * b07 + b05 * b06
        }
    }
}

public typealias float4x4 = simd_float4x4

@inlinable
public var matrix_identity_float4x4: simd_float4x4 {
    simd_float4x4(diagonal: SIMD4(repeating: 1))
}

@inlinable
public func simd_mul(_ lhs: simd_float4x4, _ rhs: simd_float4x4) -> simd_float4x4 {
    lhs * rhs
}

@inlinable
public func simd_mul(_ matrix: simd_float4x4, _ vector: SIMD4<Float>) -> SIMD4<Float> {
    matrix * vector
}

@inlinable
public func simd_transpose(_ matrix: simd_float4x4) -> simd_float4x4 {
    matrix.transpose
}

@inlinable
public func simd_inverse(_ matrix: simd_float4x4) -> simd_float4x4 {
    matrix.inverse
}

@inlinable
public func simd_determinant(_ matrix: simd_float4x4) -> Float {
    matrix.determinant
}
