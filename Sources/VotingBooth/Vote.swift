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

public extension Election {

  enum Returns: String {
    case voteCast
    case voteUpdated
    case pollsClosed = "POLLS_CLOSED"
    case updatesForbidden = "UPDATES_FORBIDDEN"
  }

  func hasVoted(_ franchise: Franchise) -> Bool {
    return (self.votes[franchise.identifier] != nil)
  }

  func castVote(_ vote: Vote) -> (Bool, Returns) {
    guard self.isOpen else {
      return (false, .pollsClosed)
    }

    let isUpdate = hasVoted(vote.franchise)

    guard !isUpdate || self.canUpdate else {
      return (false, .updatesForbidden)
    }

    self.votes[vote.franchise.identifier] = vote

    if (isUpdate) {
      return (true, .voteUpdated)
    } else {
      return (true, .voteCast)
    }
  }

}
