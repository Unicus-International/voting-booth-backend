import Foundation

import VotingBooth

var sessions: [UUID:Session] = [:]

class Session: Codable {
  let identifier: UUID = UUID()
  var parameters: [String:String] = [:]

  func value(for key: String) -> String? {
    return self.parameters[key]
  }

  func set(_ value: String, for key: String) {
    self.parameters[key] = value
  }

  init() {
    sessions[self.identifier] = self
  }

  func destroy() {
    sessions[self.identifier] = nil
  }

  static func destroy(_ key: UUID) {
    find(key)?.destroy()
  }

  static func find(_ key: UUID) -> Session? {
    return sessions[key]
  }
}

extension Session {
  var user: User? {
    parameters["USER_IDENTIFIER"].flatMap { User.fetch(emailAddress: $0) }
  }
}
