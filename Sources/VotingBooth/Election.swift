import Foundation

public class Election {
  let identifier = UUID()

  let name: String
  let question: String

  let runs: Range<Date>

  var ballots: [Ballot] = []
  let updatableVotes: Bool

  let commissioner: User
  let comptrollers: [User]

  var candidates: [Candidate] {
    ballots.flatMap { $0.candidates }
  }

  var franchises: [Franchise] = []
  var votes: [UUID:Vote] = [:]

  init(
    name: String,
    question: String,
    runs: Range<Date>,
    ballots: [Ballot] = [],
    updatableVotes: Bool,
    commissioner: User,
    comptrollers: [User] = []
  ) {
    self.name = name
    self.question = question

    self.runs = runs
    self.ballots = ballots
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
    ballots: [Ballot] = [],
    updatableVotes: Bool = true
  ) {
    self.init(
      name: name,
      question: question,
      runs: from..<to,
      ballots: ballots,
      updatableVotes: updatableVotes,
      commissioner: commissioner,
      comptrollers: comptrollers
    )
  }

  public var isOpen: Bool {
    runs.contains(Date())
  }

  public var canAddBallots: Bool {
    !isOpen
  }

  public func addBallot(_ ballot: Ballot) -> Bool {
    if (canAddBallots) {
      ballots.append(ballot)
    }

    return canAddBallots
  }

  func addBallot(named name: String, with candidates: [Candidate]) -> Bool {
    addBallot(Ballot(name: name, candidates: candidates))
  }

  @discardableResult
  public func addBallot(named name: String, with candidates: Candidate...) -> Bool {
    addBallot(named: name, with: candidates)
  }

}

public extension Election {

  struct EncodingData: Encodable {
    let identifier: UUID

    let name: String
    let question: String

    let runs: Range<Date>

    let ballots: [Ballot]
    let updatableVotes: Bool
  }

  var encodingData: EncodingData {
    EncodingData(
      identifier: identifier,
      name: name,
      question: question,
      runs: runs,
      ballots: ballots,
      updatableVotes: updatableVotes
    )
  }

}

public extension Election {

  struct DecodingData: Decodable {
    let name: String
    let question: String

    let runs: Range<Date>

    let updatableVotes: Bool
  }

  convenience init(for commissioner: User, with comptrollers: [User] = [], decodingData: DecodingData) {
    self.init(
      name: decodingData.name,
      question: decodingData.question,
      runs: decodingData.runs,
      updatableVotes: decodingData.updatableVotes,
      commissioner: commissioner,
      comptrollers: comptrollers
    )
  }

}

public extension Election {

  struct ListData: Encodable {
    let identifier: UUID
    let name: String
  }

  var listData: ListData {
    ListData(identifier: identifier, name: name)
  }

}

extension Election {

  private static var elections: [UUID:Election] = [:]

  private static func register(_ election: Election) {
    elections[election.identifier] = election
  }

  public static func fetch(_ identifier: UUID) -> Election? {
    elections[identifier]
  }

  public static var allFranchises: [UUID:Franchise] {
    elections
      .values
      .flatMap { $0.franchiseMap }
      .reduce(into: [:]) { $0[$1.0] = $1.1 }
  }

}
