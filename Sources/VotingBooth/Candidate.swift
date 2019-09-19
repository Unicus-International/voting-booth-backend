import Foundation

public struct Candidate: Codable {
  let name: String
  let identifier = UUID()

  public init(named name: String) {
    self.name = name
  }
}

public extension Election {

  var candidateMap: [UUID:Candidate] {
    return Dictionary(uniqueKeysWithValues: candidates.lazy.map { ($0.identifier, $0) })
  }

}
