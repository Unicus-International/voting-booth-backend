import Foundation

import PerfectHTTP

import VotingBooth

func voteRoutes() -> Routes {
  var routes = Routes(baseUri: "/vote")

  routes.add(method: .get, uri: "/{franchise}") {
    request, response in

    guard let franchise = request.urlVariables["franchise"].flatMap({ UUID(uuidString: $0) }).flatMap({ franchises[$0] }) else {
      return response.completed(status: .notFound)
    }

    let rdata = try! encoder.encode(["election": franchise.election.encodingData])
    let rbody: String! = String(data: rdata, encoding: .utf8)

    response
      .setHeader(.contentType, value: "application/json")
      .appendBody(string: rbody)
      .completed()
  }

  routes.add(method: .post, uri: "/{franchise}") {
    request, response in

    guard
      let franchise = request.urlVariables["franchise"]
        .flatMap({ UUID(uuidString: $0) })
        .flatMap({ franchises[$0] })
    else {
      return response.completed(status: .notFound)
    }

    guard
      let bodyData = request.postBodyString?.data(using: .utf8),
      let voteData = try? decoder.decode(Vote.CodingData.self, from: bodyData)
    else {
      return response.completed(status: .badRequest)
    }

    let (result, status) = franchise.castVote(data: voteData)

    if !result {
      response
        .setHeader(.contentType, value: "application/json")
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
