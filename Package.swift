// swift-tools-version: 6.0

import PackageDescription

/// Platforms without Apple's `simd` module, where `SIMDCompat` provides it instead.
let portablePlatforms: [Platform] = [.linux, .android, .windows, .wasi, .openbsd]

let package = Package(
    name: "swift-simd-compat",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
        .tvOS(.v15),
        .watchOS(.v8),
        .visionOS(.v1),
    ],
    products: [
        .library(
            name: "SIMDCompat",
            targets: ["SIMDCompat"]
        ),
    ],
    targets: [
        .target(
            name: "SIMDCompat",
            dependencies: [
                .target(name: "SIMDCompatPortable", condition: .when(platforms: portablePlatforms)),
            ]
        ),
        // Built on every platform so that it can be tested against Apple's `simd`.
        .target(
            name: "SIMDCompatPortable"
        ),
        .testTarget(
            name: "SIMDCompatTests",
            dependencies: ["SIMDCompat"]
        ),
        .testTarget(
            name: "SIMDCompatPortableTests",
            dependencies: ["SIMDCompatPortable"]
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets {
    target.swiftSettings =
        (target.swiftSettings ?? []) + [
            .enableUpcomingFeature("ExistentialAny"),
            .enableUpcomingFeature("MemberImportVisibility"),
            .enableUpcomingFeature("InternalImportsByDefault"),
        ]
}
