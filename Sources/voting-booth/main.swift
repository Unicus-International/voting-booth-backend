import Foundation

import PerfectHTTP
import PerfectHTTPServer

import PerfectLib

import PerfectCrypto
guard PerfectCrypto.isInitialized else {
  preconditionFailure("PerfectCrypto initialization failed.")
}

Log.debug(message: "Initializing JSON encoder/decoder")
let encoder = JSONEncoder()
encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
encoder.dateEncodingStrategy = .iso8601

let decoder = JSONDecoder()
decoder.dateDecodingStrategy = .iso8601

Log.debug(message: "Initializing routes")
var routes = Routes()

#if DEBUG
Log.debug(message: "Creating fake user")
setupDebugUser()

Log.debug(message: "Creating fake session")
let fakeSession = Session()
fakeSession.set("testuser@unicus.no", for: "USER_IDENTIFIER")

Log.debug(message: "Initializing debug routes")
routes.add(debugRoutes())
#endif

Log.debug(message: "Initializing routes")
routes.add(userRoutes())
routes.add(voteRoutes())
routes.add(electionRoutes())

Log.debug(message: "Launching server")
try HTTPServer.launch(
  .server(name: "::1", port: 8181, routes: routes)
)
