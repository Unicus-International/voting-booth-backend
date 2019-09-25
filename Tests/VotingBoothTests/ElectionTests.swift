import XCTest
@testable import VotingBooth

final class ElectionTests: XCTestCase {
  func testFranchises() {
    let election = Election("Election!", question: "Question?", from: Date(), to: Date())

    election.generateFranchises(5)

    XCTAssertEqual(election.franchises.count, 5, "The correct number of franchises are generated.")

    election.generateFranchises(5)

    XCTAssertEqual(election.franchises.count, 10, "The correct number of franchises are generated.")
    XCTAssertEqual(election.franchiseMap.count, 10, "Franchises have different keys.")
  }

  func testBallots() {
    let election = Election("Election!", question: "Question?", from: Date(), to: Date())

    election.addBallot(named: "A ballot.", with: [])
    election.addBallot(named: "Another ballot.", with: [])

    XCTAssertEqual(election.ballots.count, 2, "The correct number of ballots are added.")
    XCTAssertEqual(election.ballotMap.count, 2, "Ballots have different keys.")
  }

  func testCandidates() {
    let election = Election("Election!", question: "Question?", from: Date(), to: Date())

    election.addBallot(named: "A ballot.", with: Candidate(named: "A candidate."), Candidate(named: "Another candidate."))
    XCTAssertEqual(election.candidates.count, 2, "The correct number of candidates are found.")

    election.addBallot(named: "Another ballot.", with: Candidate(named: "A candidate."), Candidate(named: "Another candidate."))
    XCTAssertEqual(election.candidates.count, 4, "The correct number of candidates are found.")
    XCTAssertEqual(election.candidateMap.count, 4, "Candidates have different keys.")
  }

  func testElectionClosedNow() {
    let election = Election("Election!", question: "Question?", from: Date(), to: Date())

    XCTAssertFalse(election.isOpen, "An election closing now is already closed.")
  }

  func testElectionClosedSoon() {
    let election = Election("Election!", question: "Question?", from: Date(), to: Date(timeIntervalSinceNow: 60.0))

    XCTAssertTrue(election.isOpen, "An election closing in a minute is open.")
  }

  func testElectionPast() {
    let election = Election(
      "Election!",
      question: "Question?",
      from: Date(timeIntervalSinceNow: -7200.0),
      to: Date(timeIntervalSinceNow: -3600.0)
    )

    XCTAssertFalse(election.isOpen, "An election in the past is closed.")
  }

  func testElectionFuture() {
    let election = Election(
      "Election!",
      question: "Question?",
      from: Date(timeIntervalSinceNow: 3600.0),
      to: Date(timeIntervalSinceNow: 7200.0)
    )

    XCTAssertFalse(election.isOpen, "An election in the future is closed.")
  }

  func testVoting() {
    let election = Election("Election!", question: "Question?", from: Date(), to: Date())
    let ballot = election.addBallot(named: "Ballot", with: Candidate(named: "Yes"), Candidate(named: "No"))
    election.generateFranchises(1)
    let franchise = election.franchises.first!

    XCTAssertFalse(election.hasVoted(franchise), "Vote has not been cast.")

    let (firstVoteCast, firstReturns) = franchise.castVote(on: ballot, for: ballot.candidates.first!)
    XCTAssertTrue(firstVoteCast, "Vote has been cast.")
    XCTAssertTrue(election.hasVoted(franchise), "Vote has been cast.")
    XCTAssertEqual(firstReturns, .voteCast, "Vote has been cast.")
    XCTAssertEqual(election.firstChoiceVotes(for: ballot.candidates.first!), 1, "Vote is counted.")

    let (_, secondReturns) = franchise.castVote(on: ballot, for: ballot.candidates.last!)
    XCTAssertEqual(secondReturns, .voteUpdated, "Vote has been updated.")
    XCTAssertEqual(election.firstChoiceVotes(for: ballot.candidates.first!), 0, "Vote is updated.")
    XCTAssertEqual(election.firstChoiceVotes(for: ballot.candidates.last!), 1, "Vote is counted.")
  }
}
