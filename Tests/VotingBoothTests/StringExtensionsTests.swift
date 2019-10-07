import XCTest
import VotingBooth

final class StringExtensionsTests: XCTestCase {

  func testValidEmails() {
    XCTAssertTrue("testuser@unicus.no".isLikelyEmail, "Trivial case rejected.")
    XCTAssertTrue("a@a.aa".isLikelyEmail, "Minimal case rejected.")
    XCTAssertTrue("user@some-server.com".isLikelyEmail, "Domain containing dash rejected.")
    XCTAssertTrue("some-user@domain.com".isLikelyEmail, "Username containing dash rejected.")
    XCTAssertTrue("user.name+voting-booth@gmail.com".isLikelyEmail, "Username containing plussed component rejected.")
    XCTAssertTrue("user@normal.domain.com".isLikelyEmail, "Multiply dotted domain rejected.")
    XCTAssertTrue("user@strange.top.level.domain".isLikelyEmail, "Non-.com-domain rejected.")
    XCTAssertTrue("user123456789@domain.com".isLikelyEmail, "Alphanumeric username rejected.")
    XCTAssertTrue("user@domain5.com".isLikelyEmail, "Alphanumeric domain rejected.")
    XCTAssertTrue("004798765432@telia.no".isLikelyEmail, "Telephone number-like username rejected.")
  }

  func testInvalidEmails() {
    XCTAssertFalse("a@a.a".isLikelyEmail, "Subminimal case accepted.")
    XCTAssertFalse("voting booth@domain.com".isLikelyEmail, "Username containing whitespace accepted.")
    XCTAssertFalse("domain.com".isLikelyEmail, "Domain only accepted.")
    XCTAssertFalse("user@thisdomain".isLikelyEmail, "Local email address accepted.")
    XCTAssertFalse("@domain.com".isLikelyEmail, "Address without username accepted.")
    XCTAssertFalse("user@voting-booth+gmail.com".isLikelyEmail, "Domain containing plussed compontent accepted.")
    XCTAssertFalse("user".isLikelyEmail, "Email address with username only is accepted.")
    XCTAssertFalse("+voting-booth@domain.com".isLikelyEmail, "Username not starting with an alphanumeric character accepted.")
    XCTAssertFalse("Foo user@domain.com".isLikelyEmail, "Username containing whitespace accepted.")
    XCTAssertFalse("user@domain name.com".isLikelyEmail, "Domain containing whitespace accepted.")
    XCTAssertFalse("Test User <testuser@unicus.com>".isLikelyEmail, "Complete address specification accepted.")
  }

  func testCanonicalEmail() {
    let canonical = "testuser@unicus.no"

    XCTAssertEqual("testuser@unicus.no".canonicalEmailAddress, canonical, "Email address is changed.")
    XCTAssertEqual("testuser+element@unicus.no".canonicalEmailAddress, canonical, "Plussed element is not removed.")
    XCTAssertEqual("TestUser@unicus.no".canonicalEmailAddress, canonical, "Email address is not lowercase.")
  }

}
