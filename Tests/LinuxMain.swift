import XCTest
@testable import GUSimpleWhiteboardTests

XCTMain([
    testCase(WhiteboardTests.allTests),
    testCase(GenericWhiteboardTests.allTests)
])
