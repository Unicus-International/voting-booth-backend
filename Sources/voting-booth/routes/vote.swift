import Foundation

import PerfectHTTP

import PerfectLib

import VotingBooth

func voteRoutes() -> Routes {
  Log.info(message: "Initializing base route /vote")
  var routes = Routes(baseUri: "/vote")

  Log.info(message: "Initializing route GET /vote/{franchise}")
  routes.add(method: .get, uri: "/{franchise}") {
    request, response in

    guard
      let franchise = request.urlVariables["franchise"]
        .flatMap({ UUID(uuidString: $0) })
        .flatMap({ Election.allFranchises[$0] })
    else {
      Log.debug(message: "Franchise not found")
      return response.completed(status: .notFound)
    }

    let rdata = try! encoder.encode(["election": franchise.election.encodingData])
    let rbody: String! = String(data: rdata, encoding: .utf8)

    response
      .setHeader(.contentType, value: "application/json")
      .appendBody(string: rbody)
      .completed()
  }

  Log.info(message: "Initializing route POST /vote/{franchise}")
  routes.add(method: .post, uri: "/{franchise}") {
    request, response in

    guard
      let franchise = request.urlVariables["franchise"]
        .flatMap({ UUID(uuidString: $0) })
        .flatMap({ Election.allFranchises[$0] })
    else {
      Log.debug(message: "Franchise not found")
      return response.completed(status: .notFound)
    }

    guard
      let bodyData = request.postBodyString?.data(using: .utf8),
      let voteData = try? decoder.decode(Vote.CodingData.self, from: bodyData)
    else {
      Log.debug(message: "Vote could not be entered due to malformed request body")
      return response.completed(status: .badRequest)
    }

    let (result, status) = franchise.castVote(data: voteData)

    if !result {
      Log.debug(message: "Casting vote failed with status \(status)")
      response
        .setHeader(.contentType, value: "application/json")
    } else {
      Log.debug(message: "Casting vote succeeded with status \(status)")
    }

    switch (status) {
    case .voteUpdated:
      return response
        .completed(status: .noContent)

    case .voteCast:
      return response
        .completed(status: .created)

    default:
      return response
        .appendBody(string: "{\"error\": \"ERROR_\(status.rawValue)\"}")
        .completed(status: .forbidden)
    }
  }

  return routes
}
