// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "GUSimpleWhiteboard",
    products: [
        .library(
            name: "GUSimpleWhiteboard",
            targets: ["GUSimpleWhiteboard"]
        )
    ],
    dependencies: [
        .package(url: "ssh://git.mipal.net/git/SwiftWBUtils.git", .branch("master"))
    ],
    targets: [
        .systemLibrary(name: "CGUSimpleWhiteboard", pkgConfig: "libgusimplewhiteboard"),
        .target(name: "GUSimpleWhiteboard", dependencies: ["SwiftWBUtils", "CGUSimpleWhiteboard"]),
        .testTarget(name: "GUSimpleWhiteboardTests", dependencies: ["GUSimpleWhiteboard"])
    ]
)
