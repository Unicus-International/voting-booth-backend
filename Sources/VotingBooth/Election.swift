import Foundation

public class Election {
  public struct EncodingData: Encodable {
    let identifier: UUID

    let name: String
    let question: String

    let runs: Range<Date>

    let ballots: [Ballot]
    let updatableVotes: Bool
  }

  public struct ListData: Encodable {
    let identifier: UUID
    let name: String
  }

  public struct DecodingData: Decodable {
    let name: String
    let question: String

    let runs: Range<Date>

    let updatableVotes: Bool
  }

  let identifier = UUID()

  let name: String
  let question: String

  let runs: Range<Date>

  var ballots: [Ballot] = []
  let updatableVotes: Bool

  let commissioner: User
  let comptrollers: [User]

  var candidates: [Candidate] {
    return self.ballots.flatMap { $0.candidates }
  }

  var franchises: [Franchise] = []
  var votes: [UUID:Vote] = [:]

  init(
    name: String,
    question: String,
    runs: Range<Date>,
    updatableVotes: Bool,
    commissioner: User,
    comptrollers: [User] = []
  ) {
    self.name = name
    self.question = question

    self.runs = runs
    self.updatableVotes = updatableVotes

    self.commissioner = commissioner
    self.comptrollers = comptrollers

    commissioner.commissionedElections.append(self)
    comptrollers.forEach {
      $0.comptrollingElections.append(self)
    }

    Self.register(self)
  }

  public convenience init(
    for commissioner: User,
    with comptrollers: [User] = [],
    titled name: String,
    asking question: String,
    from: Date,
    to: Date,
    updatableVotes: Bool = true
  ) {
    self.init(
      name: name,
      question: question,
      runs: from..<to,
      updatableVotes: updatableVotes,
      commissioner: commissioner,
      comptrollers: comptrollers
    )
  }

  public convenience init(for commissioner: User, with comptrollers: [User] = [], decodingData: DecodingData) {
    self.init(
      name: decodingData.name,
      question: decodingData.question,
      runs: decodingData.runs,
      updatableVotes: decodingData.updatableVotes,
      commissioner: commissioner,
      comptrollers: comptrollers
    )
  }

  public var encodingData: EncodingData {
    return EncodingData(
      identifier: identifier,
      name: name,
      question: question,
      runs: runs,
      ballots: ballots,
      updatableVotes: updatableVotes
    )
  }

  public var isOpen: Bool {
    return runs.contains(Date())
  }

  public var listData: ListData {
    return ListData(identifier: identifier, name: name)
  }

  @discardableResult
  public func addBallot(named name: String, with candidates: [Candidate]) -> Ballot {
    let ballot = Ballot(name: name, candidates: candidates)

    self.ballots.append(ballot)

    return ballot
  }

  @discardableResult
  public func addBallot(named name: String, with candidates: Candidate...) -> Ballot {
    return self.addBallot(named: name, with: candidates)
  }

}

extension Election {
  static var elections: [UUID:Election] = [:]

  private static func register(_ election: Election) {
    elections[election.identifier] = election
  }

  public static var allFranchises: [UUID:Franchise] {
    return elections
      .values
      .flatMap { $0.franchiseMap }
      .reduce(into: [:]) { $0[$1.0] = $1.1 }
  }
}
