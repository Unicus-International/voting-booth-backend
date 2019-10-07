import PerfectHTTP

import VotingBooth

func debugRoutes() -> Routes {
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

  debugRoutes.add(method: .get, uri: "/franchises") {
    request, response in

    response
      .appendBody(string: String(data: try! encoder.encode(Array(Election.allFranchises.keys)), encoding: .utf8)!)
      .completed()
  }

  debugRoutes.add(method: .get, uri: "/sessions") {
    request, response in

    response
      .appendBody(string: String(data: try! encoder.encode(sessions), encoding: .utf8)!)
      .completed()
  }

  return debugRoutes
}
