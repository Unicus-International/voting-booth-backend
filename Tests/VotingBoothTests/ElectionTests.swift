import XCTest
@testable import VotingBooth

final class ElectionTests: XCTestCase {
  func testFranchises() {
    let user = User(emailAddress: "testuser@unicus.no")!
    let election = Election(
      for: user,
      titled: "Election!",
      asking: "Question?",
      from: Date(), to: Date()
    )

    election.generateFranchises(5)

    XCTAssertEqual(election.franchises.count, 5, "An incorrect number of franchises are generated.")

    election.generateFranchises(5)

    XCTAssertEqual(election.franchises.count, 10, "An incorrect number of franchises are generated.")
    XCTAssertEqual(election.franchiseMap.count, 10, "Multiple franchises have the same key.")
  }

  func testBallots() {
    let user = User(emailAddress: "testuser@unicus.no")!
    let election = Election(
      for: user,
      titled: "Election!",
      asking: "Question?",
      from: Date(), to: Date()
    )

    election.addBallot(named: "A ballot.", with: [])
    election.addBallot(named: "Another ballot.", with: [])

    XCTAssertEqual(election.ballots.count, 2, "An incorrect number of ballots are added.")
    XCTAssertEqual(election.ballotMap.count, 2, "Multiple ballots have the same key.")
  }

  func testCandidates() {
    let user = User(emailAddress: "testuser@unicus.no")!
    let election = Election(
      for: user,
      titled: "Election!",
      asking: "Question?",
      from: Date(), to: Date()
    )

    election.addBallot(named: "A ballot.", with: Candidate(named: "A candidate."), Candidate(named: "Another candidate."))
    XCTAssertEqual(election.candidates.count, 2, "An incorrect number of candidates are found.")

    election.addBallot(named: "Another ballot.", with: Candidate(named: "A candidate."), Candidate(named: "Another candidate."))
    XCTAssertEqual(election.candidates.count, 4, "An incorrect number of candidates are found.")
    XCTAssertEqual(election.candidateMap.count, 4, "Multiple candidates have the same key.")
  }

  func testElectionClosedNow() {
    let user = User(emailAddress: "testuser@unicus.no")!
    let election = Election(
      for: user,
      titled: "Election!",
      asking: "Question?",
      from: Date(), to: Date()
    )

    XCTAssertFalse(election.isOpen, "An election closing now is still open.")
  }

  func testElectionClosedSoon() {
    let user = User(emailAddress: "testuser@unicus.no")!
    let election = Election(
      for: user,
      titled: "Election!",
      asking: "Question?",
      from: Date(), to: Date(timeIntervalSinceNow: 60.0)
    )

    XCTAssertTrue(election.isOpen, "An election closing in a minute is already closed.")
  }

  func testElectionPast() {
    let user = User(emailAddress: "testuser@unicus.no")!
    let election = Election(
      for: user,
      titled: "Election!",
      asking: "Question?",
      from: Date(timeIntervalSinceNow: -7200.0), to: Date(timeIntervalSinceNow: -3600.0)
    )

    XCTAssertFalse(election.isOpen, "An election in the past is still open.")
  }

  func testElectionFuture() {
    let user = User(emailAddress: "testuser@unicus.no")!
    let election = Election(
      for: user,
      titled: "Election!",
      asking: "Question?",
      from: Date(timeIntervalSinceNow: 3600.0), to: Date(timeIntervalSinceNow: 7200.0)
    )

    XCTAssertFalse(election.isOpen, "An election in the future is already open.")
  }

  func testVoting() {
    let user = User(emailAddress: "testuser@unicus.no")!
    let election = Election(
      for: user,
      titled: "Election!",
      asking: "Question?",
      from: Date(timeIntervalSinceNow: -3600.0), to: Date(timeIntervalSinceNow: 3600.0),
      ballots: [Ballot(decoding: Ballot.DecodingData(name: "Ballot", candidates: ["Yes", "No"]))]
    )

    guard
      let ballot = election.ballots.first
    else {
      return XCTAssert(false, "Election not created with ballot.")
    }

    election.generateFranchises(1)
    let franchise = election.franchises.first!

    XCTAssertFalse(election.hasVoted(franchise), "Vote has been cast.")

    let (zerothVoteCast, zerothReturns) = franchise.castVote(on: ballot, for: ballot.candidates.first!, ballot.candidates.first!)
    XCTAssertFalse(zerothVoteCast, "Vote has been cast.")
    XCTAssertEqual(zerothReturns, .invalidVote, "Vote is incorrectly labelled as valid.")

    let (firstVoteCast, firstReturns) = franchise.castVote(on: ballot, for: ballot.candidates.first!)
    XCTAssertTrue(firstVoteCast, "Vote has been cast.")
    XCTAssertTrue(election.hasVoted(franchise), "Vote has not been cast.")
    XCTAssertEqual(firstReturns, .voteCast, "Vote has not been cast.")
    XCTAssertEqual(election.firstChoiceVotes(for: ballot.candidates.first!), 1, "Vote is not counted.")

    let (_, secondReturns) = franchise.castVote(on: ballot, for: ballot.candidates.last!)
    XCTAssertEqual(secondReturns, .voteUpdated, "Vote has not been updated.")
    XCTAssertEqual(election.firstChoiceVotes(for: ballot.candidates.first!), 0, "Vote is not updated.")
    XCTAssertEqual(election.firstChoiceVotes(for: ballot.candidates.last!), 1, "Vote is not counted.")
  }

  func testElectionNoUpdate() {
    let user = User(emailAddress: "testuser@unicus.no")!
    let election = Election(
      for: user,
      titled: "Election!",
      asking: "Question?",
      from: Date(timeIntervalSinceNow: -3600.0), to: Date(timeIntervalSinceNow: 3600.0),
      ballots: [Ballot(decoding: Ballot.DecodingData(name: "Ballot", candidates: ["Yes", "No"]))],
      updatableVotes: false
    )

    guard
      let ballot = election.ballots.first
    else {
      return XCTAssert(false, "Election not created with ballot.")
    }

    election.generateFranchises(1)
    let franchise = election.franchises.first!

    let (firstVoteCast, _) = franchise.castVote(on: ballot, for: ballot.candidates.first!)
    XCTAssertTrue(firstVoteCast, "The first vote was not accepted.")

    let (secondVoteCast, _) = franchise.castVote(on: ballot, for: ballot.candidates.last!)
    XCTAssertFalse(secondVoteCast, "The second vote was erroneously accepted.")
  }

  func testUserBinding() {
    let commissioner = User(emailAddress: "commissioner@unicus.no")!
    let comptrollers = [
      User(emailAddress: "comptroller1@unicus.no")!,
      User(emailAddress: "comptroller2@unicus.no")!,
    ]

    let election = Election(
      for: commissioner,
      with: comptrollers,
      titled: "Election!",
      asking: "Question?",
      from: Date(), to: Date()
    )

    XCTAssertTrue(election.commissioned(by: commissioner), "Commissioned elections is not added to.")
    XCTAssertTrue(election.comptrolled(by: comptrollers.first!), "Comptrolling elections is not added to.")
    XCTAssertTrue(comptrollers.last!.comptrols(election), "Comptrolling elections is not added to.")

    XCTAssertFalse(commissioner.comptrols(election), "Comptrolling elections is erroneously added to.")
    XCTAssertFalse(comptrollers.first!.commissioned(election), "Commissioned elections is erroneously added to.")
    XCTAssertFalse(election.commissioned(by: comptrollers.last!), "Commissioned elections is erroneously added to.")
  }
}
