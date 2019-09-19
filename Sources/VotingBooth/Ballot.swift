public struct Ballot: Codable {
  let name: String
  let identifier: String = ""

  let candidates: [Candidate]
}
