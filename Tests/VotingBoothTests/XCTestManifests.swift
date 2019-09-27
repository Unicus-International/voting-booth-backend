#if !canImport(ObjectiveC)
import XCTest

extension ElectionTests {
    // DO NOT MODIFY: This is autogenerated, use:
    //   `swift test --generate-linuxmain`
    // to regenerate.
    static let __allTests__ElectionTests = [
        ("testBallots", testBallots),
        ("testCandidates", testCandidates),
        ("testElectionClosedNow", testElectionClosedNow),
        ("testElectionClosedSoon", testElectionClosedSoon),
        ("testElectionFuture", testElectionFuture),
        ("testElectionNoUpdate", testElectionNoUpdate),
        ("testElectionPast", testElectionPast),
        ("testFranchises", testFranchises),
        ("testVoting", testVoting),
    ]
}

extension StringExtensionsTests {
    // DO NOT MODIFY: This is autogenerated, use:
    //   `swift test --generate-linuxmain`
    // to regenerate.
    static let __allTests__StringExtensionsTests = [
        ("testCanonicalEmails", testCanonicalEmail),
        ("testInvalidEmails", testInvalidEmails),
        ("testValidEmails", testValidEmails),
    ]
}

extension UserTests {
    // DO NOT MODIFY: This is autogenerated, use:
    //   `swift test --generate-linuxmain`
    // to regenerate.
    static let __allTests__UserTests = [
        ("testEmptyUser", testEmptyUser),
        ("testHashingFunction", testHashingFunction),
        ("testMatchingPasswords", testMatchingPasswords),
        ("testNamedEmptyUser", testNamedEmptyUser),
        ("testNonMatchingPasswords", testNonMatchingPasswords),
        ("testSalt", testSalt),
        ("testUsernameValidity", testUsernameValidity),
        ("testUsernameValidityEmptyUser", testUsernameValidityEmptyUser),
        ("testVerifyNonMatchingPassword", testVerifyNonMatchingPassword),
        ("testVerifyPassword", testVerifyPassword),
    ]
}

extension VotingBoothTests {
    // DO NOT MODIFY: This is autogenerated, use:
    //   `swift test --generate-linuxmain`
    // to regenerate.
    static let __allTests__VotingBoothTests = [
        ("testExample", testExample),
    ]
}

public func __allTests() -> [XCTestCaseEntry] {
    return [
        testCase(ElectionTests.__allTests__ElectionTests),
        testCase(StringExtensionsTests.__allTests__StringExtensionsTests),
        testCase(UserTests.__allTests__UserTests),
        testCase(VotingBoothTests.__allTests__VotingBoothTests),
    ]
}
#endif
