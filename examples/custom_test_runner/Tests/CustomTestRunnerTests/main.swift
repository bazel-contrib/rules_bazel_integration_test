#if os(Linux)
    import XCTest

    XCTMain([
        testCase(CustomTestRunnerTests.allTests),
    ])
#endif
