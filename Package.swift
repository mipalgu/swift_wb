// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "GUSimpleWhiteboard",
    dependencies: [
        .package(url: "ssh://git.mipal.net/git/CGUSimpleWhiteboard", .branch("master"))
    ],
    targets: [
        .target(name: "GUSimpleWhiteboard", dependencies: []),
        .testTarget(name: "GUSimpleWhiteboardTests", dependencies: ["GUSimpleWhiteboard"])
    ]
)
