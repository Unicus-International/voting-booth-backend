import Foundation

import PerfectHTTP

import PerfectLib

import VotingBooth

func electionRoutes() -> Routes {
  Log.info(message: "Initializing base route /elections")
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

  Log.info(message: "Initializing route /elections/commission")
  routes.add(method: .post, uri: "/commission") {
    request, response in

    guard
      let session = request.scratchPad["session"] as? Session,
      let user = session.user,
      let postBodyData = request.postBodyString?.data(using: .utf8),
      let electionData = try? decoder.decode(Election.DecodingData.self, from: postBodyData)
    else {
      Log.debug(message: "Commissioning election failed due to malformed request body")
      return response
        .completed(status: .badRequest)
    }

    let election = Election(for: user, decodingData: electionData)
    Log.info(message: "New election commissioned: \(electionData)")

    guard
      let bodyData = try? encoder.encode(election.encodingData),
      let bodyString = String(data: bodyData, encoding: .utf8)
    else {
      Log.warning(message: "Encoding of election data failed")
      return response
        .completed(status: .internalServerError)
    }

    response
      .appendBody(string: bodyString)
      .completed(status: .created)
  }

  Log.info(message: "Initializing route /elections/list")
  routes.add(method: .get, uri: "list") {
    request, response in

    guard
      let session = request.scratchPad["session"] as? Session,
      let user = session.user,
      let bodyData = try? encoder.encode(user.commissioned.map({ $0.listData })),
      let bodyString = String(data: bodyData, encoding: .utf8)
    else {
      Log.warning(message: "Encoding of list data failed")
      return response
        .completed(status: .internalServerError)
    }

    response
      .appendBody(string: bodyString)
      .completed()
  }

  Log.info(message: "Initializing base route /elections/{election}")
  var electionRoutes = Routes(baseUri: "/{election}") {
    request, response in

    guard
      let session = request.scratchPad["session"] as? Session,
      let user = session.user
    else {
      Log.warning(message: "Propagation of session and user data failed")
      return response
        .completed(status: .internalServerError)
    }

    guard
      let election = request.urlVariables["election"]
        .flatMap({ UUID(uuidString: $0) })
        .flatMap({ user.commissioned(election: $0) })
    else {
      Log.debug(message: "Election not found")
      return response
        .completed(status: .notFound)
    }

    request.scratchPad["election"] = election

    response
      .next()
  }

  Log.info(message: "Initializing route /elections/{election}/list")
  electionRoutes.add(method: .get, uri: "/list") {
    request, response in

    guard
      let election = request.scratchPad["election"] as? Election,
      let bodyData = try? encoder.encode(election.encodingData),
      let bodyString = String(data: bodyData, encoding: .utf8)
    else {
      Log.warning(message: "Encoding of election data failed")
      return response
        .completed(status: .internalServerError)
    }

    response
      .appendBody(string: bodyString)
      .completed()
  }

  Log.info(message: "Initializing base route /elections/{election}/ballots")
  var ballotRoutes = Routes(baseUri: "/ballots") {
    request, response in

    response
      .next();
  }

  Log.info(message: "Initializing route /elections/{election}/ballots/list")
  ballotRoutes.add(method: .get, uri: "/list") {
    request, response in

    guard
      let election = request.scratchPad["election"] as? Election,
      let bodyData = try? encoder.encode(election.ballotNames),
      let bodyString = String(data: bodyData, encoding: .utf8)
    else {
      Log.warning(message: "Encoding of list data failed")
      return response
        .completed(status: .internalServerError)
    }

    response
      .appendBody(string: bodyString)
      .completed()
  }

  Log.info(message: "Initializing route /elections/{election}/ballots/{ballot}/list")
  ballotRoutes.add(method: .get, uri: "/{ballot}/list") {
    request, response in

    guard let election = request.scratchPad["election"] as? Election else {
      Log.warning(message: "Propagation of election data failed")
      return response
        .completed(status: .internalServerError)
    }

    guard
      let ballotIdentifier = request.urlVariables["ballot"].flatMap({ UUID(uuidString: $0) }),
      let ballot = election.ballotMap[ballotIdentifier]
    else {
      Log.debug(message: "Ballot not found")
      return response
        .completed(status: .notFound)
    }

    guard
      let bodyData = try? encoder.encode(ballot),
      let bodyString = String(data: bodyData, encoding: .utf8)
    else {
      Log.warning(message: "Encoding of ballot data failed")
      return response
        .completed(status: .internalServerError)
    }

    response
      .appendBody(string: bodyString)
      .completed()
  }

  Log.info(message: "Initializing route /elections/{election}/ballots/new")
  ballotRoutes.add(method: .post, uri: "/new") {
    request, response in

    guard
      let election = request.scratchPad["election"] as? Election
    else {
      Log.warning(message: "Propagation of election data failed")
      return response
        .completed(status: .internalServerError)
    }

    guard
      let postBodyData = request.postBodyString?.data(using: .utf8),
      let decodingData = try? decoder.decode(Ballot.DecodingData.self, from: postBodyData)
    else {
      Log.debug(message: "Creation of new ballot failed due to malformed request body")
      return response
        .completed(status: .badRequest)
    }

    let ballot = Ballot(decoding: decodingData)

    guard
      election.addBallot(ballot)
    else {
      Log.debug(message: "New ballot could not be added")
      return response
        .completed(status: .conflict)
    }

    Log.info(message: "New ballot created: \(decodingData)")

    guard
      let bodyData = try? encoder.encode(ballot),
      let bodyString = String(data: bodyData, encoding: .utf8)
    else {
      Log.warning(message: "Encoding of ballot data failed")
      return response
        .completed(status: .internalServerError)
    }

    response
      .appendBody(string: bodyString)
      .completed(status: .created)
  }

  electionRoutes.add(ballotRoutes);

  routes.add(electionRoutes)

  return routes
}
