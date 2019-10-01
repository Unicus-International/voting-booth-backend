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

  var candidates: [Candidate] {
    return self.ballots.flatMap { $0.candidates }
  }

  var franchises: [Franchise] = []
  var votes: [UUID:Vote] = [:]

  public init(_ name: String, question: String, from: Date, to: Date, updatableVotes: Bool = true) {
    self.name = name
    self.question = question

    self.runs = from..<to
    self.updatableVotes = updatableVotes
  }

  public var encodingData: EncodingData {
    let formatter = ISO8601DateFormatter()

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
