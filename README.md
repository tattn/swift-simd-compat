# swift-simd-compat

Apple's `simd` module, on platforms that do not have it.

Code that uses `simd_quatf`, `simd_float4x4`, `simd_normalize` and the like only builds on Apple platforms. Import `SIMDCompat` instead of `simd`, and the same code builds and behaves the same on Linux and Android:

- On Apple platforms, `SIMDCompat` is `simd` itself. Nothing changes, and nothing is reimplemented
- Elsewhere, it provides the same names on top of the standard library's `SIMD` types. Every declaration is `@inlinable`, so that generic vector math is specialized in your code instead of going through protocol witnesses
- Like `simd`, it also exports the platform's C math functions (`sin`, `atan2`, `pow`, ...)

## Usage

```swift
.package(url: "https://github.com/tattn/swift-simd-compat.git", from: "x.x.x")
```

```swift
.target(name: "MyTarget", dependencies: [.product(name: "SIMDCompat", package: "swift-simd-compat")])
```

```swift
import SIMDCompat

let rotation = simd_quatf(angle: .pi / 2, axis: SIMD3(0, 1, 0))
let turned = rotation.act(SIMD3(1, 0, 0))
```

## Supported API

A part of `simd` for `Float`, added as code that depends on this package needs it:

- Vectors (`SIMD2`/`SIMD3`/`SIMD4` and any other `SIMD` of floating-point scalars): `simd_dot`, `simd_length`, `simd_length_squared`, `simd_distance`, `simd_distance_squared`, `simd_normalize`, `simd_cross`, `simd_abs`, `simd_min`, `simd_max`, `simd_clamp`, `simd_mix`, `simd_smoothstep`, `simd_reduce_min`, `simd_reduce_max`, and the unprefixed `dot`, `length`, `length_squared`, `distance`, `distance_squared`, `normalize`, `cross`
- `simd_float3x3` and `simd_float4x4` (`float3x3`, `float4x4`): construction from columns, a diagonal or a quaternion (and from rows for `simd_float3x3`), subscripts, `transpose`, `inverse`, `determinant`, `+`, `-`, `*` (and `+=`, `-=` for `simd_float3x3`), `matrix_identity_float3x3`, `matrix_identity_float4x4`, `simd_mul`, `simd_transpose`, `simd_inverse`, `simd_determinant`
- `simd_quatf`: construction from components, an angle and axis, two vectors, or a rotation matrix, `real`, `imag`, `length`, `normalized`, `conjugate`, `inverse`, `angle`, `axis`, `act(_:)`, `+`, `-`, `*`, `/`, `simd_slerp`, `simd_mul`, `simd_act`, `simd_inverse`, `simd_conjugate`, `simd_normalize`, `simd_length`, `simd_dot`, `simd_angle`, `simd_axis`
- `simd_float2`, `simd_float3`, `simd_float4`

Anything else in `simd` is not provided yet. Contributions are welcome; see [CONTRIBUTING.md](./CONTRIBUTING.md).

## Requirements

- Swift 6.0+
- iOS 15.0+ / macOS 12.0+ / tvOS 15.0+ / watchOS 8.0+ / visionOS 1.0+, Linux, Android

## License

swift-simd-compat is available under the MIT license. See the [LICENSE](./LICENSE) file for more info.
