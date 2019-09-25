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
}

public extension Election {

  enum Returns: String {
    case voteCast
    case voteUpdated
    case pollsClosed = "POLLS_CLOSED"
    case updatesForbidden = "UPDATES_FORBIDDEN"
    case invalidVote = "INVALID_VOTE"
  }

  func hasVoted(_ franchise: Franchise) -> Bool {
    return (self.votes[franchise.identifier] != nil)
  }

  func castVote(_ franchise: UUID, on ballot: UUID, for candidates: [UUID]) -> (Bool, Returns) {
    guard self.isOpen else {
      return (false, .pollsClosed)
    }

    let candidateCount = candidates.count
    let candidates = Array(Set(candidates).compactMap({ self.candidateMap[$0] }))
    guard
      let franchise = self.franchiseMap[franchise],
      let ballot = self.ballotMap[ballot],
      candidates.count == candidateCount
    else {
      return (false, .invalidVote)
    }

    let isUpdate = hasVoted(franchise)

    guard !isUpdate || self.canUpdate else {
      return (false, .updatesForbidden)
    }

    self.votes[franchise.identifier] = Vote(
      election: self,
      franchise: franchise,
      ballot: ballot,
      candidates: candidates
    )

    if (isUpdate) {
      return (true, .voteUpdated)
    } else {
      return (true, .voteCast)
    }
  }

  func castVote(_ franchise: Franchise, on ballot: Ballot, for candidates: [Candidate]) -> (Bool, Returns) {
    return castVote(franchise.identifier, on: ballot.identifier, for: candidates.map { $0.identifier })
  }

  func castVote(_ franchise: Franchise, on ballot: Ballot, for candidates: Candidate...) -> (Bool, Returns) {
    return castVote(franchise, on: ballot, for: candidates)
  }

  func firstChoiceVotes(for candidate: Candidate) -> Int {
    return votes
      .filter { $0.value.candidates.first! == candidate }
      .count
  }

}

public extension Franchise {

  func castVote(data: Vote.CodingData) -> (Bool, Election.Returns) {
    return castVote(on: data.ballot, for: data.candidates)
  }

  func castVote(on ballot: UUID, for candidates: [UUID]) -> (Bool, Election.Returns) {
    return election.castVote(self.identifier, on: ballot, for: candidates)
  }

  func castVote(on ballot: Ballot, for candidates: [Candidate]) -> (Bool, Election.Returns) {
    return election.castVote(self, on: ballot, for: candidates)
  }

  func castVote(on ballot: Ballot, for candidates: Candidate...) -> (Bool, Election.Returns) {
    return castVote(on: ballot, for: candidates)
  }

}
