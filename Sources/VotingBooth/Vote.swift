import Foundation

public struct Vote: Codable {
  let ballot: UUID
  let candidates: [UUID]
}
