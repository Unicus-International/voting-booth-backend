import Foundation

public struct Candidate: Codable {
  let name: String
  let identifier = UUID()

  public init(named name: String) {
    self.name = name
  }
}
