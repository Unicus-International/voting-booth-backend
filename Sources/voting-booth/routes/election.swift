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

  routes.add(method: .post, uri: "/commission") {
    request, response in

    guard
      let session = request.scratchPad["session"] as? Session,
      let user = session.user,
      let postBodyData = request.postBodyString?.data(using: .utf8),
      let electionData = try? decoder.decode(Election.DecodingData.self, from: postBodyData)
    else {
      return response
        .completed(status: .badRequest)
    }

    let election = Election(for: user, decodingData: electionData)

    guard
      let bodyData = try? encoder.encode(election.encodingData),
      let bodyString = String(data: bodyData, encoding: .utf8)
    else {
      return response
        .completed(status: .internalServerError)
    }

    response
      .appendBody(string: bodyString)
      .completed(status: .created)
  }

  routes.add(method: .get, uri: "list") {
    request, response in

    guard
      let session = request.scratchPad["session"] as? Session,
      let user = session.user,
      let bodyData = try? encoder.encode(user.commissioned.map({ $0.listData })),
      let bodyString = String(data: bodyData, encoding: .utf8)
    else {
      return response
        .completed(status: .internalServerError)
    }

    response
      .appendBody(string: bodyString)
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

    guard
      let election = request.scratchPad["election"] as? Election,
      let bodyData = try? encoder.encode(election.encodingData),
      let bodyString = String(data: bodyData, encoding: .utf8)
    else {
      return response
        .completed(status: .internalServerError)
    }

    response
      .appendBody(string: bodyString)
      .completed()
  }

  var ballotRoutes = Routes(baseUri: "/ballots") {
    request, response in

    response
      .next();
  }

  ballotRoutes.add(method: .get, uri: "/list") {
    request, response in

    guard
      let election = request.scratchPad["election"] as? Election,
      let bodyData = try? encoder.encode(election.ballotNames),
      let bodyString = String(data: bodyData, encoding: .utf8)
    else {
      return response
        .completed(status: .internalServerError)
    }

    response
      .appendBody(string: bodyString)
      .completed()
  }

  ballotRoutes.add(method: .get, uri: "/{ballot}/list") {
    request, response in

    guard
      let election = request.scratchPad["election"] as? Election,
      let ballotIdentifier = request.urlVariables["ballot"].flatMap({ UUID(uuidString: $0) })
    else {
      return response
        .completed(status: .internalServerError)
    }

    guard let ballot = election.ballotMap[ballotIdentifier] else {
      return response
        .completed(status: .notFound)
    }

    guard
      let bodyData = try? encoder.encode(ballot),
      let bodyString = String(data: bodyData, encoding: .utf8)
    else {
      return response
        .completed(status: .internalServerError)
    }

    response
      .appendBody(string: bodyString)
      .completed()
  }

  electionRoutes.add(ballotRoutes);

  routes.add(electionRoutes)

  return routes
}
