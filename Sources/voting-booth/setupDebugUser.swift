import Foundation

import VotingBooth

func setupDebugUser() {
  assert(User.create(emailAddress: "testuser@unicus.no", passwordOne: "testuser", passwordTwo: "testuser"))
  let user = User.fetch(emailAddress: "testuser@unicus.no")!

  let election = Election(
    for: user,
    titled: "Do it!",
    asking: "Should we do it?",
    from: Date(timeIntervalSinceReferenceDate: 5.0e8),
    to: Date(timeIntervalSinceReferenceDate: 6.0e8)
  )
  election.addBallot(named: "Do it?", with: Candidate(named: "Yes"), Candidate(named: "No"))

  election.generateFranchises(30)
}