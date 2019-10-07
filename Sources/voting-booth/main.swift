import Foundation

import PerfectHTTP
import PerfectHTTPServer

import PerfectCrypto
guard PerfectCrypto.isInitialized else {
  preconditionFailure("PerfectCrypto initialization failed.")
}

import VotingBooth

let encoder = JSONEncoder()
encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
encoder.dateEncodingStrategy = .iso8601

let decoder = JSONDecoder()
decoder.dateDecodingStrategy = .iso8601

var routes = Routes()

#if DEBUG
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

routes.add(debugRoutes())
#endif

routes.add(userRoutes())
routes.add(voteRoutes())
routes.add(electionRoutes())

try HTTPServer.launch(
  .server(name: "::1", port: 8181, routes: routes)
)
