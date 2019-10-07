import Foundation

public extension Election {
  func commissioned(by user: User) -> Bool {
    return user == commissioner
  }

  func comptrolled(by user: User) -> Bool {
    return comptrollers.contains(user)
  }
}

public extension User {
  func commissioned(_ election: Election) -> Bool {
    return election.commissioned(by: self)
  }

  func commissioned(election identifier: UUID) -> Election? {
    return commissioned.first(where: { $0.identifier == identifier })
  }

  func comptrols(_ election: Election) -> Bool {
    return election.comptrolled(by: self)
  }

  var commissioned: [Election] {
    self.commissionedElections
  }

  var comptrolling: [Election] {
    self.comptrollingElections
  }
}
