import Foundation

public struct Vote {
  public struct CodingData: Decodable {
    let ballot: UUID
    let candidates: [UUID]
  }

  let election: Election
  let franchise: Franchise

  let ballot: Ballot
  let candidates: [Candidate]

  public init?(with data: CodingData, franchise: Franchise) {
    guard data.candidates.count == Set(data.candidates).count else {
      return nil
    }

    self.franchise = franchise
    self.election = franchise.election

    let ballotMap = election.ballotMap
    let candidateMap = election.candidateMap

    if let ballot = ballotMap[data.ballot] {
      self.ballot = ballot
    } else {
      return nil
    }

    self.candidates = data.candidates.compactMap { candidateMap[$0] }

    if self.candidates.count != data.candidates.count {
      return nil
    }
  }
}
