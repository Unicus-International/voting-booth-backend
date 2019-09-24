import PerfectHTTP
import Foundation

func userRoutes() -> Routes {
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
      let session = Session()

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

  return userRoutes
}
