import XCTest
import VotingBooth

final class StringExtensionsTests: XCTestCase {

  func testValidEmails() {
    XCTAssertTrue("testuser@unicus.no".isLikelyEmail, "Trivial case.")
    XCTAssertTrue("a@a.aa".isLikelyEmail, "Minimal case.")
    XCTAssertTrue("user@some-server.com".isLikelyEmail, "Domain contains a dash.")
    XCTAssertTrue("some-user@domain.com".isLikelyEmail, "Username contains a dash.")
    XCTAssertTrue("user.name+voting-booth@gmail.com".isLikelyEmail, "Username contains plussed component.")
    XCTAssertTrue("user@strange.top.level.domain".isLikelyEmail, "Non-.com-domain.")
    XCTAssertTrue("user@normal.domain.com".isLikelyEmail, "Multiply dotted domain.")
    XCTAssertTrue("user123456789@domain5.com".isLikelyEmail, "Alphanumeric username.")
    XCTAssertTrue("004798765432@telia.no".isLikelyEmail, "Telephone number-like username.")
  }

  func testInvalidEmails() {
    XCTAssertFalse("a@a.a".isLikelyEmail, "Subminimal case.")
    XCTAssertFalse("voting booth@domain.com".isLikelyEmail, "Username contains whitespace.")
    XCTAssertFalse("domain.com".isLikelyEmail, "Domain only.")
    XCTAssertFalse("user@thisdomain".isLikelyEmail, "Email address is local.")
    XCTAssertFalse("@domain.com".isLikelyEmail, "No username.")
    XCTAssertFalse("user@voting-booth+gmail.com".isLikelyEmail, "Domain contains plussed component.")
    XCTAssertFalse("user".isLikelyEmail, "Username only.")
    XCTAssertFalse("+voting-booth@domain.com".isLikelyEmail, "Username doesn't start with an alphanumeric.")
    XCTAssertFalse("Foo user@domain.com".isLikelyEmail, "Junk before email address.")
    XCTAssertFalse("user@domain name.com".isLikelyEmail, "Domain contains whitespace.")
    XCTAssertFalse("Test User <testuser@unicus.com>".isLikelyEmail, "Address is complete specification.")
  }

  func testCanonicalEmail() {
    let canonical = "testuser@unicus.no"

    XCTAssertEqual("testuser@unicus.no".canonicalEmailAddress, canonical, "Email address is changed.")
    XCTAssertEqual("testuser+element@unicus.no".canonicalEmailAddress, canonical, "Plussed element is not removed.")
    XCTAssertEqual("TestUser@unicus.no".canonicalEmailAddress, canonical, "Email address is not lowercase.")
  }

}
