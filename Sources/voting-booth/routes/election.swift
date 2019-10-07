import Foundation

import PerfectHTTP

import VotingBooth

func electionRoutes() -> Routes {
  var routes = Routes(baseUri: "/") {
    request, response in

    guard let session = Session.find(for: request) else {
      return response
        .completed(status: .forbidden)
    }

    request.scratchPad["session"] = session

    response
      .setHeader(.contentType, value: "application/json")
      .next()
  }

  routes.add(method: .get, uri: "elections") {
    request, response in

    guard
      let session = request.scratchPad["session"] as? Session,
      let user = session.user
    else {
      return response
        .completed(status: .internalServerError)
    }

    response
      .appendBody(string: String(data: try! encoder.encode(user.commissioned.map { $0.listData }), encoding: .utf8)!)
      .completed()
  }

  return routes
}
