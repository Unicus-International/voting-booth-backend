import PerfectCrypto

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

func getUser(emailAddress: String) -> User? {
  return users[emailAddress]
}

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

