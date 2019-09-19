public struct Candidate: Codable {
  let identifier: String
  let name: String

  public init(named name: String) {
    self.identifier = ""
    self.name = name
  }
}
