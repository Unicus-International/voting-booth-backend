import PerfectCrypto

import VotingBooth

func hashPassword(_ password: String) -> String {
  return (password.digest(.sha256)?.encode(.base64).flatMap { String(validatingUTF8: $0) })!
}

func makeSalt() -> String {
  let source = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ./"
  let range = 1...16

  return String(range.compactMap { _ in source.randomElement() })
}

extension User {
  static var users: [String:User] = [:]

  static func getUser(emailAddress: String) -> User? {
    return users[emailAddress.canonicalEmailAddress]
  }

  static func setUser(_ user: User) {
    users[user.canonicalEmailAddress] = user
  }

  static func create(emailAddress: String, name: String? = nil, passwordOne: String, passwordTwo: String) -> Bool {
    guard
      getUser(emailAddress: emailAddress) == nil,
      let user = User(
        emailAddress: emailAddress,
        name: name,
        passwordOne: passwordOne,
        passwordTwo: passwordTwo,
        saltFunction: makeSalt,
        hashingFunction: hashPassword
      )
    else {
      return false
    }

    setUser(user)

    return true
  }

  static func login(emailAddress: String, password: String) -> User? {
    if
      let user = getUser(emailAddress: emailAddress),
      user.verifyPassword(password, hashingFunction: hashPassword)
    {
      return user
    } else {
      return nil
    }
  }
}
