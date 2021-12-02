@testable import CustomTestRunner
import XCTest

class CustomTestRunnerTests: XCTestCase {
    func test_init() throws {
        let bazel = "path/to/bazel"
        let workspace = "path/to/workspace"

        let runner = CustomTestRunner(bazel: bazel, workspace: workspace)
        XCTAssertEqual(bazel, runner.bazel)
        XCTAssertEqual(workspace, runner.workspace)
    }
}
