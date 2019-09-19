import Foundation

public class Election: Encodable {
  var name: String
  var question: String

  var ballots: [Ballot] = []

  var candidates: [Candidate] {
    return self.ballots.flatMap { $0.candidates }
  }

  var franchises: [Franchise] = []
  var votes: [UUID:Vote] = [:]

  public init(_ name: String, question: String) {
    self.name = name
    self.question = question
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

  private enum CodingKeys: String, CodingKey {
    case name
    case question

    case ballots
  }

}
