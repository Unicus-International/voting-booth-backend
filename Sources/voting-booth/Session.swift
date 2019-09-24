import Foundation

fileprivate var sessions: [UUID:Session] = [:]

struct Session: Codable {
  let identifier: UUID = UUID()
  var parameters: [String:String] = [:]

  func value(for key: String) -> String? {
    return self.parameters[key]
  }

  mutating func set(_ value: String, for key: String) {
    self.parameters[key] = value
  }

  init() {
    sessions[self.identifier] = self
  }

  func destroy() {
    sessions[self.identifier] = nil
  }
}
