import Foundation

public class User: Codable {
  let identifier = UUID()
  let emailAddress: String
  let name: String?
  let passwordHash: String?

  public init?(emailAddress: String, name: String? = nil) {
    guard emailAddress.isLikelyEmail else {
      return nil
    }

    self.emailAddress = emailAddress
    self.name = name
    self.passwordHash = nil
  }

  public init?(
    emailAddress: String,
    name: String? = nil,
    passwordOne: String,
    passwordTwo: String,
    saltFunction: () -> String = { "" },
    hashingFunction hash: (String) -> String = { $0 }
  ) {
    guard
      passwordOne == passwordTwo,
      emailAddress.isLikelyEmail
    else {
      return nil
    }

    self.emailAddress = emailAddress
    self.name = name
    let salt = saltFunction()
    self.passwordHash = "$5$\(salt)$\(hash(salt + passwordOne))"
  }

  public var isRegisterable: Bool {
    passwordHash == nil
  }

  public var canonicalEmailAddress: String {
    emailAddress.canonicalEmailAddress
  }

  var commissionedElections: [Election] = []
  var comptrollingElections: [Election] = []

  public func verifyPassword(
    _ password: String,
    hashingFunction hash: (String) -> String = { $0 }
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

  enum CodingKeys: String, CodingKey {
    case identifier
    case emailAddress = "email_address"

    case name
    case passwordHash
  }
}

extension User: Equatable {

  public static func == (_ lhs: User, _ rhs: User) -> Bool {
    lhs.emailAddress == rhs.emailAddress
  }

}
