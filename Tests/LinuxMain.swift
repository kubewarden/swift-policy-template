import XCTest

import BusinessLogicTests
import kubewardenSdk
import Logging

LoggingSystem.bootstrap(PolicyLogHandler.init)

var tests = [XCTestCaseEntry]()
tests += BusinessLogicTests.allTests()
XCTMain(tests)
