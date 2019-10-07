import Foundation

import PerfectHTTP

import VotingBooth

func electionRoutes() -> Routes {
  var routes = Routes(baseUri: "/elections") {
    request, response in

#if DEBUG
    let session = fakeSession
#else
    guard let session = Session.find(for: request) else {
      return response
        .completed(status: .forbidden)
    }
#endif
    request.scratchPad["session"] = session

    response
      .setHeader(.contentType, value: "application/json")
      .next()
  }

  routes.add(method: .get, uri: "list") {
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

  var electionRoutes = Routes(baseUri: "/{election}") {
    request, response in

    guard
      let session = request.scratchPad["session"] as? Session,
      let user = session.user
    else {
      return response
        .completed(status: .internalServerError)
    }

    guard
      let election = request.urlVariables["election"]
        .flatMap({ UUID(uuidString: $0) })
        .flatMap({ user.commissioned(election: $0) })
    else {
      return response
        .completed(status: .notFound)
    }

    request.scratchPad["election"] = election

    response
      .next()
  }

  electionRoutes.add(method: .get, uri: "/list") {
    request, response in

    guard let election = request.scratchPad["election"] as? Election else {
      return response
        .completed(status: .internalServerError)
    }

    response
      .appendBody(string: String(data: try! encoder.encode(election.encodingData), encoding: .utf8)!)
      .completed()
  }

  routes.add(electionRoutes)

  return routes
}
