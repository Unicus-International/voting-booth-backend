import Foundation

public struct User: Codable {
  public static var defaultSaltFunction: () -> String = { return "" }
  public static var defaultHashingFunction: (String) -> String = { return $0 }

  let emailAddress: String
  let name: String?
  let passwordHash: String?

  public init(emailAddress: String, name: String? = nil) {
    self.emailAddress = emailAddress
    self.name = name
    self.passwordHash = nil
  }

  public init?(
    emailAddress: String,
    name: String? = nil,
    passwordOne: String,
    passwordTwo: String,
    saltFunction: () -> String = defaultSaltFunction,
    hashingFunction hash: (String) -> String = defaultHashingFunction
  ) {
    guard passwordOne == passwordTwo else {
      return nil
    }

    self.emailAddress = emailAddress
    self.name = name
    let salt = saltFunction()
    self.passwordHash = "$5$\(salt)$\(hash(salt + passwordOne))"
  }

  public func verifyPassword(
    _ password: String,
    hashingFunction hash: (String) -> String = defaultHashingFunction
  ) -> Bool {
    guard let hashed = self.passwordHash else {
      return false
    }

    var fields = hashed
      .split(separator: "$", omittingEmptySubsequences: false)
      .map { String($0) }

    guard
      let hashedPassword = fields.popLast(),
      let salt = fields.popLast(),
      fields.popLast() == "5"
    else {
      return false
    }

    return hashedPassword == hash(salt + password)
  }
}