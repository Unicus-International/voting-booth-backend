import PerfectHTTP
import PerfectHTTPServer

import PerfectLib
import Foundation

import VotingBooth

let election = Election("Do it!", question: "Should we do it?")
election.addBallot(named: "Do it?", with: Candidate(named: "Yes"), Candidate(named: "No"))

election.generateFranchises(30)

var routes = Routes()

let encoder = JSONEncoder()
routes.add(method: .get, uri: "/vote/{franchise}") {
  request, response in

  let franchise: String! = request.urlVariables["franchise"]

  let rdata = try! encoder.encode(["election": election])
  let rbody: String! = String(data: rdata, encoding: .utf8)

  response
    .setHeader(.contentType, value: "application/json")
    .appendBody(string: rbody)
    .completed()
}

let decoder = JSONDecoder()
routes.add(method: .post, uri: "/vote/{franchise}") {
  request, response in

  let franchise: String! = request.urlVariables["franchise"]
  guard let bodyData = request.postBodyString?.data(using: .utf8) else {
    response
      .completed(status: .badRequest)

    return
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
