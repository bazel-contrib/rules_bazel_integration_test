@testable import CustomTestRunner
import Foundation
import XCTest

class CustomTestRunnerTests: XCTestCase {
    func test_init() throws {
        _ = CustomTestRunner()

        // let bazel = "path/to/bazel"
        // let workspace = "path/to/workspace"

        // // let runner = CustomTestRunner(bazel: bazel, workspace: workspace)

        // ProcessInfo.processInfo.environment["BIT_BAZEL_BINARY"] = bazel
        // ProcessInfo.processInfo.environment["BIT_WORKSPACE_DIR"] = workspace
        // let runner = try CustomTestRunner()
        // XCTAssertEqual(bazel, runner.bazel)
        // XCTAssertEqual(workspace, runner.workspace)
    }
}
