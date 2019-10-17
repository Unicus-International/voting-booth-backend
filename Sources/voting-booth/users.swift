import PerfectCrypto
import PerfectLib

import VotingBooth

func hashPassword(_ password: String) -> String {
  (password.digest(.sha256)?.encode(.base64).flatMap { String(validatingUTF8: $0) })!
}

func makeSalt() -> String {
  let source = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ./"
  let range = 1...16

  return String(range.compactMap { _ in source.randomElement() })
}

extension User {
  static var users: [String:User] = [:]

  static func fetch(emailAddress: String) -> User? {
    emailAddress.canonicalEmailAddress.flatMap { users[$0] }
  }

  private static func register(_ user: User) {
    users[user.canonicalEmailAddress] = user
  }

  static func create(emailAddress: String, name: String? = nil, passwordOne: String, passwordTwo: String) -> Bool {
    guard
      fetch(emailAddress: emailAddress) == nil,
      let user = User(
        emailAddress: emailAddress,
        name: name,
        passwordOne: passwordOne,
        passwordTwo: passwordTwo,
        saltFunction: makeSalt,
        hashingFunction: hashPassword
      )
    else {
      Log.warning(message: "User '\(emailAddress)' could not be created")
      return false
    }

    register(user)

    return true
  }

  static func login(emailAddress: String, password: String) -> User? {
    if
      let user = fetch(emailAddress: emailAddress),
      user.verifyPassword(password, hashingFunction: hashPassword)
    {
      return user
    } else {
      Log.warning(message: "User '\(emailAddress)' could not be logged in")
      return nil
    }
  }
}
