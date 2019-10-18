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
      Log.debug(message: "User creation failed due to missing fields in post body")
      return response
        .setHeader(.contentType, value: "application/json")
        .appendBody(string: #"{"error": "ERROR_MISSING_FIELD"}"#)
        .completed(status: .badRequest)
    }

    guard User.fetch(emailAddress: username) == nil else {
      Log.info(message: "Attempted recreation of user: \(username)")
      return response
        .completed(status: .forbidden)
    }

    guard username.isLikelyEmail else {
      Log.debug(message: "User creation failed due to username not being a likely email address")
      return response
        .setHeader(.contentType, value: "application/json")
        .appendBody(string: #"{"error": "ERROR_BAD_USERNAME"}"#)
        .completed(status: .badRequest)
    }

    guard User.create(emailAddress: username, name: name, passwordOne: passwordOne, passwordTwo: passwordTwo) else {
      Log.debug(message: "User creation failed due to differing passwords")
      return response
        .setHeader(.contentType, value: "application/json")
        .appendBody(string: #"{"error": "ERROR_PASSWORDS_DIFFER"}"#)
        .completed(status: .badRequest)
    }

    Log.info(message: "User created: \(username)")

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
      Log.debug(message: "User login failed due to missing parameters in request")
      return response.completed(status: .badRequest)
    }

    guard let user = User.login(emailAddress: username, password: password) else {
      Log.info(message: "Failed login attempt for user: \(username)")
      return response
        .completed(status: .forbidden)
    }

    let session = Session()
    session.set(user.canonicalEmailAddress, for: "USER_IDENTIFIER")

    Log.info(message: "Logged in user: \(username)")

    response
      .addHeader(.custom(name: "X-Session-Id"), value: session.identifier.uuidString)
      .completed(status: .noContent)
  }

  Log.info(message: "Initializing route /user/logout")
  userRoutes.add(method: .get, uri: "/logout") {
    request, response in

    Session
      .find(for: request)?
      .destroy()

    Log.debug(message: "Session destroyed")

    response
      .completed(status: .noContent)
  }

  return userRoutes
}
