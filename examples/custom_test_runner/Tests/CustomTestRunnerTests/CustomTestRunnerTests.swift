@testable import CustomTestRunnerLib
import Foundation
import XCTest

class CustomTestRunnerTests: XCTestCase {
    func test_init() throws {
        _ = CustomTestRunner()
    }

    static var allTests = [
        ("test_init", test_init),
    ]
}
