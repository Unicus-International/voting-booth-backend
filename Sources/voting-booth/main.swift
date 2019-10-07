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
let election = Election(
  "Do it!",
  question: "Should we do it?",
  from: Date(timeIntervalSinceReferenceDate: 5.0e8),
  to: Date(timeIntervalSinceReferenceDate: 6.0e8)
)
election.addBallot(named: "Do it?", with: Candidate(named: "Yes"), Candidate(named: "No"))

election.generateFranchises(30)

assert(User.create(emailAddress: "testuser@unicus.no", passwordOne: "testuser", passwordTwo: "testuser"))

routes.add(debugRoutes())
#endif

routes.add(userRoutes())
routes.add(voteRoutes())

try HTTPServer.launch(
  .server(name: "::1", port: 8181, routes: routes)
)
