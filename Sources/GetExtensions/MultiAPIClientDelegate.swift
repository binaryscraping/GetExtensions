import Foundation
import Get

/// An ``APIClientDelegate`` that forward calls to multiple delegates in order.
public struct MultiAPIClientDelegate: APIClientDelegate {
  let delegates: [APIClientDelegate]

  public init(_ delegates: [APIClientDelegate]) {
    self.delegates = delegates
  }

  public func client(_ client: APIClient, willSendRequest request: inout URLRequest) async throws {
    for delegate in delegates {
      try await delegate.client(client, willSendRequest: &request)
    }
  }

  public func client(
    _ client: APIClient,
    shouldRetry task: URLSessionTask,
    error: Error,
    attempts: Int
  ) async throws -> Bool {
    for delegate in delegates {
      if try await delegate.client(client, shouldRetry: task, error: error, attempts: attempts) {
        return true
      }
    }
    return false
  }

  public func client(
    _ client: APIClient,
    validateResponse response: HTTPURLResponse,
    data: Data,
    task: URLSessionTask
  ) throws {
    for delegate in delegates {
      try delegate.client(client, validateResponse: response, data: data, task: task)
    }
  }

  public func client<T>(_ client: APIClient, makeURLForRequest request: Request<T>) throws -> URL? {
    for delegate in delegates {
      if let url = try delegate.client(client, makeURLForRequest: request) {
        return url
      }
    }
    return nil
  }
}
