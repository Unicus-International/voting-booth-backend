import PerfectHTTP
import PerfectHTTPServer

import Foundation

import VotingBooth

let election = Election("Do it!", question: "Should we do it?")
election.addBallot(named: "Do it?", with: Candidate(named: "Yes"), Candidate(named: "No"))

election.generateFranchises(30)

let franchises = election.franchiseMap

let encoder = JSONEncoder()
encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

let decoder = JSONDecoder()

var routes = Routes()

#if DEBUG
routes.add(method: .get, uri: "/debug/franchises") {
  request, response in

  response
    .setHeader(.contentType, value: "application/json")
    .appendBody(string: String(data: try! encoder.encode(Array(franchises.keys)), encoding: .utf8)!)
    .completed()
}
#endif

routes.add(method: .get, uri: "/vote/{franchise}") {
  request, response in

  guard let franchise = request.urlVariables["franchise"].flatMap({ UUID(uuidString: $0) }).flatMap({ franchises[$0] }) else {
    return response.completed(status: .notFound)
  }

  let rdata = try! encoder.encode(["election": franchise.election])
  let rbody: String! = String(data: rdata, encoding: .utf8)

  response
    .setHeader(.contentType, value: "application/json")
    .appendBody(string: rbody)
    .completed()
}

routes.add(method: .post, uri: "/vote/{franchise}") {
  request, response in

  guard let franchise = request.urlVariables["franchise"].flatMap({ UUID(uuidString: $0) }).flatMap({ franchises[$0] }) else {
    return response.completed(status: .notFound)
  }

  guard let bodyData = request.postBodyString?.data(using: .utf8) else {
    return response.completed(status: .badRequest)
  }

  if let _ = try? decoder.decode(Vote.self, from: bodyData) {
    response
      .setHeader(.contentType, value: "application/json")
      .appendBody(string: "Spoon!")
      .completed()
  } else {
    response
      .completed(status: .badRequest)
  }
}

try HTTPServer.launch(
  .server(name: "::1", port: 8181, routes: routes)
)
