// The C math functions are called from `@inlinable` code, so they are imported publicly.
#if canImport(Darwin)
public import Darwin
#elseif canImport(Android)
public import Android
#elseif canImport(Glibc)
public import Glibc
#endif

/// A quaternion of `Float`. Like Apple's `simd_quatf`, `vector` holds the imaginary part in `x`, `y`, `z`
/// and the real part in `w`.
public struct simd_quatf: Equatable, Sendable {
    public var vector: SIMD4<Float>

    @inlinable
    public init(vector: SIMD4<Float>) {
        self.vector = vector
    }

    @inlinable
    public init(ix: Float, iy: Float, iz: Float, r: Float) {
        vector = SIMD4(ix, iy, iz, r)
    }

    @inlinable
    public init(real: Float, imag: SIMD3<Float>) {
        vector = SIMD4(imag, real)
    }

    /// The rotation by `angle` radians around `axis`, which must be a unit vector.
    @inlinable
    public init(angle: Float, axis: SIMD3<Float>) {
        let half = angle / 2
        vector = SIMD4(axis * sin(half), cos(half))
    }

    /// The shortest rotation that turns the unit vector `from` into the unit vector `to`.
    @inlinable
    public init(from: SIMD3<Float>, to: SIMD3<Float>) {
        let cosine = simd_dot(from, to)
        guard cosine > -1 + 1e-6 else {
            // Opposite vectors: turn half a revolution around any axis perpendicular to `from`.
            var axis = simd_cross(SIMD3(1, 0, 0), from)
            if simd_length_squared(axis) < 1e-6 {
                axis = simd_cross(SIMD3(0, 1, 0), from)
            }
            self.init(angle: .pi, axis: simd_normalize(axis))
            return
        }
        self.init(vector: simd_normalize(SIMD4(simd_cross(from, to), 1 + cosine)))
    }

    /// The rotation a rotation matrix describes.
    @inlinable
    public init(_ rotation: simd_float3x3) {
        let (x, y, z) = rotation.columns
        let trace = x.x + y.y + z.z
        if trace > 0 {
            let s = (trace + 1).squareRoot() * 2
            self.init(ix: (y.z - z.y) / s, iy: (z.x - x.z) / s, iz: (x.y - y.x) / s, r: s / 4)
        } else if x.x > y.y, x.x > z.z {
            let s = (1 + x.x - y.y - z.z).squareRoot() * 2
            self.init(ix: s / 4, iy: (y.x + x.y) / s, iz: (z.x + x.z) / s, r: (y.z - z.y) / s)
        } else if y.y > z.z {
            let s = (1 + y.y - x.x - z.z).squareRoot() * 2
            self.init(ix: (y.x + x.y) / s, iy: s / 4, iz: (z.y + y.z) / s, r: (z.x - x.z) / s)
        } else {
            let s = (1 + z.z - x.x - y.y).squareRoot() * 2
            self.init(ix: (z.x + x.z) / s, iy: (z.y + y.z) / s, iz: s / 4, r: (x.y - y.x) / s)
        }
    }

    /// The rotation the upper-left 3x3 part of `transform` describes.
    @inlinable
    public init(_ transform: simd_float4x4) {
        let (x, y, z, _) = transform.columns
        self.init(
            simd_float3x3(
                SIMD3(x.x, x.y, x.z),
                SIMD3(y.x, y.y, y.z),
                SIMD3(z.x, z.y, z.z)
            )
        )
    }

    @inlinable
    public var real: Float {
        get { vector.w }
        set { vector.w = newValue }
    }

    @inlinable
    public var imag: SIMD3<Float> {
        get { SIMD3(vector.x, vector.y, vector.z) }
        set { vector = SIMD4(newValue, vector.w) }
    }

    @inlinable
    public var length: Float {
        simd_length(vector)
    }

    @inlinable
    public var normalized: simd_quatf {
        simd_quatf(vector: simd_normalize(vector))
    }

    @inlinable
    public var conjugate: simd_quatf {
        simd_quatf(real: real, imag: -imag)
    }

    @inlinable
    public var inverse: simd_quatf {
        simd_quatf(vector: conjugate.vector / simd_length_squared(vector))
    }

    /// The rotation angle in radians.
    @inlinable
    public var angle: Float {
        2 * atan2(simd_length(imag), real)
    }

    /// The unit rotation axis.
    @inlinable
    public var axis: SIMD3<Float> {
        simd_normalize(imag)
    }

    /// Rotates `vector` by this unit quaternion.
    @inlinable
    public func act(_ vector: SIMD3<Float>) -> SIMD3<Float> {
        let twice = 2 * simd_cross(imag, vector)
        return vector + real * twice + simd_cross(imag, twice)
    }

    @inlinable
    public static func + (lhs: simd_quatf, rhs: simd_quatf) -> simd_quatf {
        simd_quatf(vector: lhs.vector + rhs.vector)
    }

    @inlinable
    public static func - (lhs: simd_quatf, rhs: simd_quatf) -> simd_quatf {
        simd_quatf(vector: lhs.vector - rhs.vector)
    }

    @inlinable
    public static prefix func - (quaternion: simd_quatf) -> simd_quatf {
        simd_quatf(vector: -quaternion.vector)
    }

    /// The rotation that applies `rhs` first, then `lhs`.
    @inlinable
    public static func * (lhs: simd_quatf, rhs: simd_quatf) -> simd_quatf {
        simd_quatf(
            real: lhs.real * rhs.real - simd_dot(lhs.imag, rhs.imag),
            imag: lhs.real * rhs.imag + rhs.real * lhs.imag + simd_cross(lhs.imag, rhs.imag)
        )
    }

    @inlinable
    public static func * (quaternion: simd_quatf, scalar: Float) -> simd_quatf {
        simd_quatf(vector: quaternion.vector * scalar)
    }

    @inlinable
    public static func * (scalar: Float, quaternion: simd_quatf) -> simd_quatf {
        quaternion * scalar
    }

    @inlinable
    public static func / (quaternion: simd_quatf, scalar: Float) -> simd_quatf {
        simd_quatf(vector: quaternion.vector / scalar)
    }
}

@inlinable
public func simd_dot(_ lhs: simd_quatf, _ rhs: simd_quatf) -> Float {
    simd_dot(lhs.vector, rhs.vector)
}

@inlinable
public func simd_length(_ quaternion: simd_quatf) -> Float {
    quaternion.length
}

@inlinable
public func simd_normalize(_ quaternion: simd_quatf) -> simd_quatf {
    quaternion.normalized
}

@inlinable
public func simd_conjugate(_ quaternion: simd_quatf) -> simd_quatf {
    quaternion.conjugate
}

@inlinable
public func simd_inverse(_ quaternion: simd_quatf) -> simd_quatf {
    quaternion.inverse
}

@inlinable
public func simd_mul(_ lhs: simd_quatf, _ rhs: simd_quatf) -> simd_quatf {
    lhs * rhs
}

@inlinable
public func simd_act(_ quaternion: simd_quatf, _ vector: SIMD3<Float>) -> SIMD3<Float> {
    quaternion.act(vector)
}

@inlinable
public func simd_angle(_ quaternion: simd_quatf) -> Float {
    quaternion.angle
}

@inlinable
public func simd_axis(_ quaternion: simd_quatf) -> SIMD3<Float> {
    quaternion.axis
}

/// Spherical linear interpolation along the shorter arc between two unit quaternions.
@inlinable
public func simd_slerp(_ from: simd_quatf, _ to: simd_quatf, _ t: Float) -> simd_quatf {
    var cosine = simd_dot(from, to)
    var end = to
    if cosine < 0 {
        cosine = -cosine
        end = -to
    }
    // Nearly the same rotation: the sine below vanishes, and a linear blend is as accurate.
    guard cosine < 1 - 1e-6 else {
        return simd_quatf(vector: simd_mix(from.vector, end.vector, SIMD4(repeating: t))).normalized
    }
    let theta = acos(cosine)
    let sine = sin(theta)
    return simd_quatf(vector: from.vector * (sin((1 - t) * theta) / sine) + end.vector * (sin(t * theta) / sine))
}
