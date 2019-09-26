public extension String {
  var isLikelyEmail: Bool {
    let emailRegEx = "^[A-Z0-9a-z][A-Z0-9a-z._%+-]*@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
    return self.range(of: emailRegEx, options: .regularExpression) != nil
  }

  var canonicalEmailAddress: String {
    return self
  }
}
