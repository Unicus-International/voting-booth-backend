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
    ListData(name: name, identifier: identifier)
  }

}

public extension Election {

  var ballotMap: [UUID:Ballot] {
    Dictionary(uniqueKeysWithValues: ballots.lazy.map { ($0.identifier, $0) })
  }

  var ballotNames: [Ballot.ListData] {
    ballots.lazy.map { $0.listData }
  }

}

public extension Ballot {

  struct DecodingData: Decodable {
    let name: String
    let candidates: [String]
  }

  init(decoding data: DecodingData) {
    self.init(
      name: data.name,
      candidates: data.candidates.map { Candidate(named: $0) }
    )
  }

}
