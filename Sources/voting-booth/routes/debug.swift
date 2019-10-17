import PerfectHTTP

import PerfectLib

import VotingBooth

func debugRoutes() -> Routes {
  Log.info(message: "Initializing base route /debug")
  var debugRoutes = Routes(baseUri: "/debug") {
    request, response in

    #if DEBUG
    response
      .setHeader(.contentType, value: "application/json")
      .next()
    #else
    response
      .completed(status: .internalServerError)
    #endif
  }

  Log.info(message: "Initializing route /debug/franchises")
  debugRoutes.add(method: .get, uri: "/franchises") {
    request, response in

    response
      .appendBody(string: String(data: try! encoder.encode(Array(Election.allFranchises.keys)), encoding: .utf8)!)
      .completed()
  }

  Log.info(message: "Initializing route /debug/sessions")
  debugRoutes.add(method: .get, uri: "/sessions") {
    request, response in

    response
      .appendBody(string: String(data: try! encoder.encode(sessions), encoding: .utf8)!)
      .completed()
  }

  return debugRoutes
}
