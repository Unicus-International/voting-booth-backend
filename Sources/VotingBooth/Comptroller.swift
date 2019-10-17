import Foundation

public extension Election {

  func commissioned(by user: User) -> Bool {
    user == commissioner
  }

  func comptrolled(by user: User) -> Bool {
    comptrollers.contains(user)
  }

}

public extension User {

  func commissioned(_ election: Election) -> Bool {
    election.commissioned(by: self)
  }

  func commissioned(election identifier: UUID) -> Election? {
    commissioned.first(where: { $0.identifier == identifier })
  }

  func comptrols(_ election: Election) -> Bool {
    election.comptrolled(by: self)
  }

  var commissioned: [Election] {
    self.commissionedElections
  }

  var comptrolling: [Election] {
    self.comptrollingElections
  }

}
