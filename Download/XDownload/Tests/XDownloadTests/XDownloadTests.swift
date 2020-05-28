import XCTest
@testable import XDownload

final class XDownloadTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(XDownload().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
