import PerfectHTTP
import PerfectHTTPServer

import PerfectCrypto
guard PerfectCrypto.isInitialized else {
  preconditionFailure("PerfectCrypto initialization failed.")
}

import Foundation

import VotingBooth

var users: [String:User] = [:]

func hashPassword(_ password: String) -> String {
  return (password.digest(.sha256)?.encode(.base64).flatMap { String(validatingUTF8: $0) })!
}

func makeSalt() -> String {
  let source = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"

  let range = 1...16

  return String(range.compactMap { _ in source.randomElement() })
}

User.defaultHashingFunction = hashPassword
User.defaultSaltFunction = makeSalt

func createUser(emailAddress: String, name: String? = nil, passwordOne: String, passwordTwo: String) -> Bool {
  guard
    users[emailAddress] == nil,
    let user = User(
      emailAddress: emailAddress,
      name: name,
      passwordOne: passwordOne,
      passwordTwo: passwordTwo
    )
  else {
    return false
  }

  users[emailAddress] = user

  return true
}

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
