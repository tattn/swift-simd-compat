// Every declaration is `@inlinable`: generic functions called across modules are not specialized
// otherwise, which makes vector math far slower than Apple's `simd`.

public typealias simd_float2 = SIMD2<Float>
public typealias simd_float3 = SIMD3<Float>
public typealias simd_float4 = SIMD4<Float>

@inlinable
public func simd_dot<V: SIMD>(_ a: V, _ b: V) -> V.Scalar where V.Scalar: FloatingPoint {
    (a * b).sum()
}

@inlinable
public func simd_length_squared<V: SIMD>(_ v: V) -> V.Scalar where V.Scalar: FloatingPoint {
    simd_dot(v, v)
}

@inlinable
public func simd_length<V: SIMD>(_ v: V) -> V.Scalar where V.Scalar: FloatingPoint {
    simd_length_squared(v).squareRoot()
}

@inlinable
public func simd_distance_squared<V: SIMD>(_ a: V, _ b: V) -> V.Scalar where V.Scalar: FloatingPoint {
    simd_length_squared(a - b)
}

@inlinable
public func simd_distance<V: SIMD>(_ a: V, _ b: V) -> V.Scalar where V.Scalar: FloatingPoint {
    simd_length(a - b)
}

@inlinable
public func simd_normalize<V: SIMD>(_ v: V) -> V where V.Scalar: FloatingPoint {
    v / simd_length(v)
}

@inlinable
public func simd_cross<Scalar: SIMDScalar & FloatingPoint>(_ a: SIMD3<Scalar>, _ b: SIMD3<Scalar>) -> SIMD3<Scalar> {
    SIMD3(
        a.y * b.z - a.z * b.y,
        a.z * b.x - a.x * b.z,
        a.x * b.y - a.y * b.x
    )
}

@inlinable
public func simd_abs<V: SIMD>(_ v: V) -> V where V.Scalar: FloatingPoint {
    var result = v
    for index in result.indices {
        result[index] = abs(result[index])
    }
    return result
}

@inlinable
public func simd_min<V: SIMD>(_ a: V, _ b: V) -> V where V.Scalar: FloatingPoint {
    pointwiseMin(a, b)
}

@inlinable
public func simd_max<V: SIMD>(_ a: V, _ b: V) -> V where V.Scalar: FloatingPoint {
    pointwiseMax(a, b)
}

@inlinable
public func simd_clamp<V: SIMD>(_ v: V, _ low: V, _ high: V) -> V where V.Scalar: FloatingPoint {
    simd_min(simd_max(v, low), high)
}

@inlinable
public func simd_clamp<Scalar: FloatingPoint>(_ value: Scalar, _ low: Scalar, _ high: Scalar) -> Scalar {
    Scalar.minimum(Scalar.maximum(value, low), high)
}

@inlinable
public func simd_mix<V: SIMD>(_ a: V, _ b: V, _ t: V) -> V where V.Scalar: FloatingPoint {
    a + t * (b - a)
}

@inlinable
public func simd_mix<Scalar: FloatingPoint>(_ a: Scalar, _ b: Scalar, _ t: Scalar) -> Scalar {
    a + t * (b - a)
}

@inlinable
public func simd_reduce_max<V: SIMD>(_ v: V) -> V.Scalar where V.Scalar: FloatingPoint {
    v.max()
}

@inlinable
public func simd_reduce_min<V: SIMD>(_ v: V) -> V.Scalar where V.Scalar: FloatingPoint {
    v.min()
}

// The unprefixed names Apple's `simd` module adds for Swift.

@inlinable
public func dot<V: SIMD>(_ a: V, _ b: V) -> V.Scalar where V.Scalar: FloatingPoint {
    simd_dot(a, b)
}

@inlinable
public func length_squared<V: SIMD>(_ v: V) -> V.Scalar where V.Scalar: FloatingPoint {
    simd_length_squared(v)
}

@inlinable
public func length<V: SIMD>(_ v: V) -> V.Scalar where V.Scalar: FloatingPoint {
    simd_length(v)
}

@inlinable
public func distance_squared<V: SIMD>(_ a: V, _ b: V) -> V.Scalar where V.Scalar: FloatingPoint {
    simd_distance_squared(a, b)
}

@inlinable
public func distance<V: SIMD>(_ a: V, _ b: V) -> V.Scalar where V.Scalar: FloatingPoint {
    simd_distance(a, b)
}

@inlinable
public func normalize<V: SIMD>(_ v: V) -> V where V.Scalar: FloatingPoint {
    simd_normalize(v)
}

@inlinable
public func cross<Scalar: SIMDScalar & FloatingPoint>(_ a: SIMD3<Scalar>, _ b: SIMD3<Scalar>) -> SIMD3<Scalar> {
    simd_cross(a, b)
}

@inlinable
public func mix<V: SIMD>(_ x: V, _ y: V, t: V) -> V where V.Scalar: FloatingPoint {
    simd_mix(x, y, t)
}

@inlinable
public func mix<V: SIMD>(_ x: V, _ y: V, t: V.Scalar) -> V where V.Scalar: FloatingPoint {
    x + t * (y - x)
}
