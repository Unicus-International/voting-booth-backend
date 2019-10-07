import Foundation

import PerfectHTTP
import PerfectHTTPServer

import PerfectCrypto
guard PerfectCrypto.isInitialized else {
  preconditionFailure("PerfectCrypto initialization failed.")
}

let encoder = JSONEncoder()
encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
encoder.dateEncodingStrategy = .iso8601

let decoder = JSONDecoder()
decoder.dateDecodingStrategy = .iso8601

var routes = Routes()

#if DEBUG
setupDebugUser()

let fakeSession = Session()
fakeSession.set("testuser@unicus.no", for: "USER_IDENTIFIER")

routes.add(debugRoutes())
#endif

routes.add(userRoutes())
routes.add(voteRoutes())
routes.add(electionRoutes())

try HTTPServer.launch(
  .server(name: "::1", port: 8181, routes: routes)
)
