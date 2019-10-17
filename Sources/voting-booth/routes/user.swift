import Foundation

import PerfectHTTP

import PerfectLib

import VotingBooth

extension Session {
  static func find(for request: HTTPRequest) -> Session? {
    return request
      .header(.custom(name: "X-Session-Id"))
      .flatMap { UUID(uuidString: $0) }
      .flatMap { Session.find($0) }
  }
}

func userRoutes() -> Routes {
  Log.info(message: "Initializing base route /user")
  var userRoutes = Routes(baseUri: "/user")

  Log.info(message: "Initializing route /user/register")
  userRoutes.add(method: .post, uri: "/register") {
    request, response in

    guard
      let name = request.param(name: "name"),
      let username = request.param(name: "email_address"),
      let passwordOne = request.param(name: "password_one"),
      let passwordTwo = request.param(name: "password_two")
    else {
      return response
        .setHeader(.contentType, value: "application/json")
        .appendBody(string: #"{"error": "ERROR_MISSING_FIELD"}"#)
        .completed(status: .badRequest)
    }

    guard User.fetch(emailAddress: username) == nil else {
      return response
        .completed(status: .forbidden)
    }

    guard username.isLikelyEmail else {
      return response
        .setHeader(.contentType, value: "application/json")
        .appendBody(string: #"{"error": "ERROR_BAD_USERNAME"}"#)
        .completed(status: .badRequest)
    }

    guard User.create(emailAddress: username, name: name, passwordOne: passwordOne, passwordTwo: passwordTwo) else {
      return response
        .setHeader(.contentType, value: "application/json")
        .appendBody(string: #"{"error": "ERROR_PASSWORDS_DIFFER"}"#)
        .completed(status: .badRequest)
    }

    response
      .completed(status: .created)
  }

  Log.info(message: "Initializing route /user/login")
  userRoutes.add(method: .post, uri: "/login") {
    request, response in

    guard
      let username = request.param(name: "email_address"),
      let password = request.param(name: "password")
    else {
      return response.completed(status: .badRequest)
    }

    if let user = User.login(emailAddress: username, password: password) {
      let session = Session()

      session.set(user.canonicalEmailAddress, for: "USER_IDENTIFIER")

      return response
        .addHeader(.custom(name: "X-Session-Id"), value: session.identifier.uuidString)
        .completed(status: .noContent)
    } else {
      return response
        .completed(status: .forbidden)
    }
  }

  Log.info(message: "Initializing route /user/logout")
  userRoutes.add(method: .get, uri: "/logout") {
    request, response in

    Session
      .find(for: request)?
      .destroy()

    response
      .completed(status: .noContent)
  }

  return userRoutes
}
