import Foundation

public struct Ballot: Codable {
  let name: String
  let identifier = UUID()

  let candidates: [Candidate]
}

public extension Ballot {

  struct ListData: Encodable {
    let name: String
    let identifier: UUID
  }

  var listData: ListData {
    return ListData(name: name, identifier: identifier)
  }

}

public extension Election {

  var ballotMap: [UUID:Ballot] {
    return Dictionary(uniqueKeysWithValues: ballots.lazy.map { ($0.identifier, $0) })
  }

  var ballotNames: [Ballot.ListData] {
    ballots
      .map { $0.listData }
  }

}
