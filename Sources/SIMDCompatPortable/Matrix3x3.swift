/// A 3x3 matrix of `Float`, stored as columns like Apple's `simd_float3x3`.
public struct simd_float3x3: Equatable, Sendable {
    public var columns: (SIMD3<Float>, SIMD3<Float>, SIMD3<Float>)

    @inlinable
    public init(columns: (SIMD3<Float>, SIMD3<Float>, SIMD3<Float>)) {
        self.columns = columns
    }

    @inlinable
    public init(_ col0: SIMD3<Float>, _ col1: SIMD3<Float>, _ col2: SIMD3<Float>) {
        columns = (col0, col1, col2)
    }

    @inlinable
    public init(_ columns: [SIMD3<Float>]) {
        precondition(columns.count == 3, "simd_float3x3 needs 3 columns")
        self.init(columns[0], columns[1], columns[2])
    }

    @inlinable
    public init(diagonal: SIMD3<Float>) {
        self.init(
            SIMD3(diagonal.x, 0, 0),
            SIMD3(0, diagonal.y, 0),
            SIMD3(0, 0, diagonal.z)
        )
    }

    /// The rotation `quaternion` describes.
    @inlinable
    public init(_ quaternion: simd_quatf) {
        self.init(
            quaternion.act(SIMD3(1, 0, 0)),
            quaternion.act(SIMD3(0, 1, 0)),
            quaternion.act(SIMD3(0, 0, 1))
        )
    }

    @inlinable
    public subscript(column: Int) -> SIMD3<Float> {
        get {
            switch column {
            case 0: columns.0
            case 1: columns.1
            case 2: columns.2
            default: preconditionFailure("Column index out of range")
            }
        }
        set {
            switch column {
            case 0: columns.0 = newValue
            case 1: columns.1 = newValue
            case 2: columns.2 = newValue
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
    public var transpose: simd_float3x3 {
        let (a, b, c) = columns
        return simd_float3x3(SIMD3(a.x, b.x, c.x), SIMD3(a.y, b.y, c.y), SIMD3(a.z, b.z, c.z))
    }

    @inlinable
    public var determinant: Float {
        simd_dot(columns.0, simd_cross(columns.1, columns.2))
    }

    @inlinable
    public var inverse: simd_float3x3 {
        let (a, b, c) = columns
        // The rows of the inverse are the cross products of the other two columns.
        let row0 = simd_cross(b, c)
        let row1 = simd_cross(c, a)
        let row2 = simd_cross(a, b)
        return simd_float3x3(row0, row1, row2).transpose * (1 / simd_dot(a, row0))
    }

    @inlinable
    public static func == (lhs: simd_float3x3, rhs: simd_float3x3) -> Bool {
        lhs.columns.0 == rhs.columns.0 && lhs.columns.1 == rhs.columns.1 && lhs.columns.2 == rhs.columns.2
    }

    @inlinable
    public static func + (lhs: simd_float3x3, rhs: simd_float3x3) -> simd_float3x3 {
        simd_float3x3(lhs.columns.0 + rhs.columns.0, lhs.columns.1 + rhs.columns.1, lhs.columns.2 + rhs.columns.2)
    }

    @inlinable
    public static func - (lhs: simd_float3x3, rhs: simd_float3x3) -> simd_float3x3 {
        simd_float3x3(lhs.columns.0 - rhs.columns.0, lhs.columns.1 - rhs.columns.1, lhs.columns.2 - rhs.columns.2)
    }

    @inlinable
    public static func * (matrix: simd_float3x3, scalar: Float) -> simd_float3x3 {
        simd_float3x3(matrix.columns.0 * scalar, matrix.columns.1 * scalar, matrix.columns.2 * scalar)
    }

    @inlinable
    public static func * (scalar: Float, matrix: simd_float3x3) -> simd_float3x3 {
        matrix * scalar
    }

    @inlinable
    public static func * (matrix: simd_float3x3, vector: SIMD3<Float>) -> SIMD3<Float> {
        matrix.columns.0 * vector.x + matrix.columns.1 * vector.y + matrix.columns.2 * vector.z
    }

    @inlinable
    public static func * (lhs: simd_float3x3, rhs: simd_float3x3) -> simd_float3x3 {
        simd_float3x3(lhs * rhs.columns.0, lhs * rhs.columns.1, lhs * rhs.columns.2)
    }
}

public typealias float3x3 = simd_float3x3

@inlinable
public var matrix_identity_float3x3: simd_float3x3 {
    simd_float3x3(diagonal: SIMD3(repeating: 1))
}

@inlinable
public func simd_mul(_ lhs: simd_float3x3, _ rhs: simd_float3x3) -> simd_float3x3 {
    lhs * rhs
}

@inlinable
public func simd_mul(_ matrix: simd_float3x3, _ vector: SIMD3<Float>) -> SIMD3<Float> {
    matrix * vector
}

@inlinable
public func simd_transpose(_ matrix: simd_float3x3) -> simd_float3x3 {
    matrix.transpose
}

@inlinable
public func simd_inverse(_ matrix: simd_float3x3) -> simd_float3x3 {
    matrix.inverse
}

@inlinable
public func simd_determinant(_ matrix: simd_float3x3) -> Float {
    matrix.determinant
}
