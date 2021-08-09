import XCTest
import class Foundation.Bundle

import kubewardenSdk
import Foundation

@testable import BusinessLogic

final class ValidateTests: XCTestCase {

  func testAcceptBecauseNoNameIsDenied() {
    let deniedNames: Set<String> = [""]
    let settings = Settings(deniedNames: deniedNames)
    let validation_payload = make_validate_payload(
      request: PodRequest,
      settings: settings)

    let response_payload = validate(payload: validation_payload)

    let response : ValidationResponse = try! JSONDecoder().decode(
      ValidationResponse.self, from: Data(response_payload.utf8))

    XCTAssert(response.accepted)
    XCTAssertNil(response.message)
  }

  func testRejectBecauseNameIsOnDenyList() {
    let deniedNames: Set<String> = ["nginx"]
    let settings = Settings(deniedNames: deniedNames)
    let validation_payload = make_validate_payload(
      request: PodRequest,
      settings: settings)

    let response_payload = validate(payload: validation_payload)

    let response : ValidationResponse = try! JSONDecoder().decode(
      ValidationResponse.self, from: Data(response_payload.utf8))

    XCTAssert(!response.accepted)
    XCTAssertEqual("resource name \'nginx\' is not allowed", response.message)
  }

  func testAcceptBecauseNameIsNotDenied() {
    let deniedNames: Set<String> = ["foo"]
    let settings = Settings(deniedNames: deniedNames)
    let validation_payload = make_validate_payload(
      request: PodRequest,
      settings: settings)

    let response_payload = validate(payload: validation_payload)

    let response : ValidationResponse = try! JSONDecoder().decode(
      ValidationResponse.self, from: Data(response_payload.utf8))

    XCTAssert(response.accepted)
    XCTAssertNil(response.message)
  }


  static var allTests = [
    ("testAcceptBecauseNoNameIsDenied", testAcceptBecauseNoNameIsDenied),
    ("testRejectBecauseNameIsOnDenyList", testRejectBecauseNameIsOnDenyList),
    ("testAcceptBecauseNameIsNotDenied", testAcceptBecauseNameIsNotDenied),
  ]
}
