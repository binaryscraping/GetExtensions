import Foundation
import Get
import XCTest

@testable import GetExtensions

final class MultiAPIClientDelegateTests: XCTestCase {
  let client = APIClient(baseURL: nil)

  func testWillSendRequest() async throws {
    let delegate1 = DelegateMock()
    let delegate2 = DelegateMock()
    let sut = MultiAPIClientDelegate([delegate1, delegate2])

    var request = URLRequest(url: URL(string: "https://binaryscraping.co")!)
    try await sut.client(client, willSendRequest: &request)
    XCTAssertTrue(delegate1.willSendRequestCalled)
    XCTAssertTrue(delegate2.willSendRequestCalled)
  }

  func testShouldRetry() async throws {
    let delegate1 = DelegateMock()
    let delegate2 = DelegateMock()
    let sut = MultiAPIClientDelegate([delegate1, delegate2])

    let request = URLRequest(url: URL(string: "https://binaryscraping.co")!)

    let shouldRetry = try await sut.client(
      client,
      shouldRetry: URLSession.shared.dataTask(with: request),
      error: URLError(.badURL),
      attempts: 1
    )
    XCTAssertFalse(shouldRetry)
    XCTAssertTrue(delegate1.shouldRetryCalled)
    XCTAssertTrue(delegate2.shouldRetryCalled)
  }

  func testShouldRetry_whenADelegateReturnsTrue() async throws {
    let delegate1 = DelegateMock()
    let delegate2 = DelegateMock()
    let sut = MultiAPIClientDelegate([delegate1, delegate2])

    let request = URLRequest(url: URL(string: "https://binaryscraping.co")!)
    delegate1.shouldRetryResult = true

    let shouldRetry = try await sut.client(
      client,
      shouldRetry: URLSession.shared.dataTask(with: request),
      error: URLError(.badURL),
      attempts: 1
    )
    XCTAssertTrue(shouldRetry)
    XCTAssertTrue(delegate1.shouldRetryCalled)
    XCTAssertFalse(delegate2.shouldRetryCalled)
  }

  func testValidateResponse() throws {
    let delegate1 = DelegateMock()
    let delegate2 = DelegateMock()
    let sut = MultiAPIClientDelegate([delegate1, delegate2])

    let request = URLRequest(url: URL(string: "https://binaryscraping.co")!)
    try sut.client(
      client,
      validateResponse: HTTPURLResponse(),
      data: Data(),
      task: URLSession.shared.dataTask(with: request)
    )
    XCTAssertTrue(delegate1.validateResponseCalled)
    XCTAssertTrue(delegate2.validateResponseCalled)
  }

  func testMakeURLForRequest() throws {
    let delegate1 = DelegateMock()
    let delegate2 = DelegateMock()
    let sut = MultiAPIClientDelegate([delegate1, delegate2])

    let request = Request<Void>(url: URL(string: "https://binaryscraping.co")!)
    let url = try sut.client(client, makeURLForRequest: request)

    XCTAssertNil(url)
    XCTAssertTrue(delegate1.makeURLForRequestCalled)
    XCTAssertTrue(delegate2.makeURLForRequestCalled)
  }

  func testMakeURLForRequest_whenADelegateReturnsAURL() throws {
    let delegate1 = DelegateMock()
    let delegate2 = DelegateMock()
    let sut = MultiAPIClientDelegate([delegate1, delegate2])

    let request = Request<Void>(url: URL(string: "https://binaryscraping.co")!)
    let customURL = request.url?.appendingPathComponent("api/v1")
    delegate1.makeURLForRequestReturn = customURL

    let url = try sut.client(client, makeURLForRequest: request)

    XCTAssertEqual(url, customURL)
    XCTAssertTrue(delegate1.makeURLForRequestCalled)
    XCTAssertFalse(delegate2.makeURLForRequestCalled)
  }
}

final class DelegateMock: APIClientDelegate {
  var willSendRequestCalled = false
  func client(_: APIClient, willSendRequest _: inout URLRequest) async throws {
    willSendRequestCalled = true
  }

  var shouldRetryCalled = false
  var shouldRetryResult = false
  func client(
    _: APIClient,
    shouldRetry _: URLSessionTask,
    error _: Error,
    attempts _: Int
  ) async throws -> Bool {
    shouldRetryCalled = true
    return shouldRetryResult
  }

  var validateResponseCalled = false
  func client(
    _: APIClient,
    validateResponse _: HTTPURLResponse,
    data _: Data,
    task _: URLSessionTask
  ) throws {
    validateResponseCalled = true
  }

  var makeURLForRequestCalled = false
  var makeURLForRequestReturn: URL?
  func client<T>(_: APIClient, makeURLForRequest _: Request<T>) throws -> URL? {
    makeURLForRequestCalled = true
    return makeURLForRequestReturn
  }
}
