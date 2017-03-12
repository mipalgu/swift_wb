import PackageDescription

let package = Package(
    name: "GUSimpleWhiteboard",
    dependencies: [
        .Package(url: "ssh://git.mipal.net/git/CGUSimpleWhiteboard", majorVersion: 1)
    ]
)
