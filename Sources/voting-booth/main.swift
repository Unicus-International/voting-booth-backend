import PerfectHTTP
import PerfectHTTPServer

import PerfectCrypto
guard PerfectCrypto.isInitialized else {
  preconditionFailure("PerfectCrypto initialization failed.")
}

import Foundation

import VotingBooth

let election = Election(
  "Do it!",
  question: "Should we do it?",
  from: Date(timeIntervalSinceReferenceDate: 5.0e8),
  to: Date(timeIntervalSinceReferenceDate: 6.0e8)
)
election.addBallot(named: "Do it?", with: Candidate(named: "Yes"), Candidate(named: "No"))

election.generateFranchises(30)

let franchises = election.franchiseMap
let ballots = election.ballotMap
let candidates = election.candidateMap

let encoder = JSONEncoder()
encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

let decoder = JSONDecoder()

var routes = Routes()

#if DEBUG
assert(createUser(emailAddress: "testuser@unicus.no", passwordOne: "testuser", passwordTwo: "testuser"))

var debugRoutes = Routes(baseUri: "/debug")

debugRoutes.add(method: .get, uri: "/franchises") {
  request, response in

  response
    .setHeader(.contentType, value: "application/json")
    .appendBody(string: String(data: try! encoder.encode(Array(franchises.keys)), encoding: .utf8)!)
    .completed()
}

routes.add(debugRoutes)
#endif

var userRoutes = Routes(baseUri: "/user")

userRoutes.add(method: .post, uri: "/register") {
  request, response in

  response
    .completed(status: .internalServerError)
}

userRoutes.add(method: .post, uri: "/login") {
  request, response in

  guard
    let username = request.param(name: "email_address"),
    let password = request.param(name: "password")
  else {
    return response.completed(status: .badRequest)
  }

  if let user = loginUser(emailAddress: username, password: password) {
    var session = Session()

    session.set(user.identifier, for: "USER_IDENTIFIER")

    return response
      .addHeader(.custom(name: "X-Session-Id"), value: session.identifier.uuidString)
      .completed(status: .noContent)
  } else {
    return response
      .completed(status: .forbidden)
  }
}

userRoutes.add(method: .get, uri: "/logout") {
  request, response in

  request
    .header(.custom(name: "X-Session-Id"))
    .flatMap { UUID(uuidString: $0) }
    .flatMap { Session.destroy($0) }

  response
    .completed(status: .noContent)
}

routes.add(userRoutes)

routes.add(method: .get, uri: "/vote/{franchise}") {
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

routes.add(method: .post, uri: "/vote/{franchise}") {
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
    let voteData = try? decoder.decode(Vote.CodingData.self, from: bodyData),
    let vote = Vote(with: voteData, franchise: franchise)
  else {
    return response.completed(status: .badRequest)
  }

  let (result, status) = franchise.election.castVote(vote)

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
      .appendBody(string: "{\"error\": \"ERROR_\(result)\"}")
      .completed(status: .forbidden)
  }
}

try HTTPServer.launch(
  .server(name: "::1", port: 8181, routes: routes)
)
