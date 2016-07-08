import XCTest
@testable import letswift-api

class letswift-apiTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        XCTAssertEqual(letswift-api().text, "Hello, World!")
    }


    static var allTests : [(String, (letswift-apiTests) -> () throws -> Void)] {
        return [
            ("testExample", testExample),
        ]
    }
}
