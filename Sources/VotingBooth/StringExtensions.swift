public extension String {
  var isLikelyEmail: Bool {
    let emailRegEx = "^[A-Z0-9a-z][A-Z0-9a-z._%+-]*@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
    return self.range(of: emailRegEx, options: .regularExpression) != nil
  }

  var canonicalEmailAddress: String {
    if (self.isLikelyEmail) {
      let splitAddress = self.lowercased().split(separator: "@")
      let splitUsername = splitAddress.first!.split(separator: "+")

      return "\(splitUsername.first!)@\(splitAddress.last!)"
    } else {
      return self
    }
  }
}
