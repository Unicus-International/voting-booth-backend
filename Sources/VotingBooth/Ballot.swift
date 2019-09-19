import Foundation

public struct Ballot: Codable {
  let name: String
  let identifier = UUID()

  let candidates: [Candidate]
}
