// swift-tools-version:4.0

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
        .package(url: "ssh://git.mipal.net/git/CGUSimpleWhiteboard", .branch("master")),
        .package(url: "ssh://git.mipal.net/git/SwiftWBUtils.git", .branch("master"))
    ],
    targets: [
        .target(name: "GUSimpleWhiteboard", dependencies: ["SwiftWBUtils"]),
        .testTarget(name: "GUSimpleWhiteboardTests", dependencies: ["GUSimpleWhiteboard"])
    ]
)
