import Foundation

public struct Ballot: Codable {
  let name: String
  let identifier = UUID()

  let candidates: [Candidate]
}

public extension Election {

  var ballotMap: [UUID:Ballot] {
    return Dictionary(uniqueKeysWithValues: ballots.lazy.map { ($0.identifier, $0) })
  }

}
