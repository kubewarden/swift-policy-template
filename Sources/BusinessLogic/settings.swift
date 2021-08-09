import Foundation
import kubewardenSdk

public class Settings: Codable, Validatable {
  let deniedNames: Set<String>

  public init(deniedNames: Set<String>) {
    self.deniedNames = deniedNames
  }

  required public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    if let deniedNames = try container.decodeIfPresent(Set<String>.self, forKey: .deniedNames) {
      self.deniedNames = deniedNames
    } else {
      self.deniedNames = Set<String>()
    }
  }

  public var debugDescription: String {
    return "\(self) - deniedNames: \(deniedNames)"
  }

  // No validation has to be performed, settings are always valid in this case
  public func validate() throws {
  }
}
