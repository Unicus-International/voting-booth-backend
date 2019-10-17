import Foundation

public struct Franchise {
  public let election: Election
  public let identifier = UUID()
}

public extension Election {

  func generateFranchises(_ count: UInt) {
    for _ in 0..<count {
      self.franchises.append(Franchise(election: self))
    }
  }

  var franchiseMap: [UUID:Franchise] {
    Dictionary(uniqueKeysWithValues: franchises.lazy.map { ($0.identifier, $0) })
  }

}
