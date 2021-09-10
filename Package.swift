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
        .package(url: "git@github.com:mipalgu/SwiftWBUtils.git", .branch("main"))
    ],
    targets: [
        .systemLibrary(name: "CGUSimpleWhiteboard", pkgConfig: "libgusimplewhiteboard"),
        .target(name: "GUSimpleWhiteboard", dependencies: ["SwiftWBUtils", "CGUSimpleWhiteboard"]),
        .testTarget(name: "GUSimpleWhiteboardTests", dependencies: ["GUSimpleWhiteboard"])
    ]
)
