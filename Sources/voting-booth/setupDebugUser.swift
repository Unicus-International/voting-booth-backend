import Foundation

import PerfectLib

import VotingBooth

func setupDebugUser() {
  Log.info(message: "Creating debug user")
  assert(User.create(emailAddress: "testuser@unicus.no", passwordOne: "testuser", passwordTwo: "testuser"))
  let user = User.fetch(emailAddress: "testuser@unicus.no")!

  Log.info(message: "Creating debug election")
  let election = Election(
    for: user,
    titled: "Do it!",
    asking: "Should we do it?",
    from: Date(timeIntervalSinceNow: 10.0),
    to: Date(timeIntervalSinceNow: 3600.0)
  )
  election.addBallot(named: "Do it?", with: Candidate(named: "Yes"), Candidate(named: "No"))

  Log.info(message: "Creating debug franchises")
  election.generateFranchises(30)
}
