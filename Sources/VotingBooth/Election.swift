import Foundation

public class Election {
  public struct EncodingData: Encodable {
    let name: String
    let question: String

    let runs: [String:String]
    let ballots: [Ballot]
  }

  let name: String
  let question: String

  let runs: Range<Date>

  var ballots: [Ballot] = []

  var candidates: [Candidate] {
    return self.ballots.flatMap { $0.candidates }
  }

  var franchises: [Franchise] = []
  var votes: [UUID:Vote] = [:]

  public init(_ name: String, question: String, from: Date, to: Date) {
    self.name = name
    self.question = question

    self.runs = from..<to
  }

  public var encodingData: EncodingData {
    let formatter = ISO8601DateFormatter()

    return EncodingData(
      name: name,
      question: question,
      runs: [
        "from": formatter.string(from: runs.lowerBound),
        "to": formatter.string(from: runs.upperBound),
      ],
      ballots: ballots
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
