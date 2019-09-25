import XCTest
@testable import VotingBooth

final class UserTests: XCTestCase {
  func testEmptyUser() {
    let user = User(emailAddress: "testuser@unicus.no")

    XCTAssertNotNil(user, "User created successfully.")
    XCTAssertTrue(user!.isRegisterable, "User is registerable.")
  }

  func testNamedEmptyUser() {
    let user = User(emailAddress: "testuser@unicus.no", name: "Test User")

    XCTAssertNotNil(user, "User created successfully.")
    XCTAssertTrue(user!.isRegisterable, "User is registerable.")
  }

  func testMatchingPasswords() {
    let user = User(emailAddress: "testuser@unicus.no", passwordOne: "matching", passwordTwo: "matching")

    XCTAssertNotNil(user, "Passwords match.")
  }

  func testNonMatchingPasswords() {
    let user = User(emailAddress: "testuser@unicus.no", passwordOne: "matching", passwordTwo: "different")

    XCTAssertNil(user, "Passwords are different.")
  }

  func testVerifyPassword() {
    let user = User(emailAddress: "testuser@unicus.no", passwordOne: "password", passwordTwo: "password")

    XCTAssertNotNil(user, "User created successfully.")
    XCTAssertTrue(user!.verifyPassword("password"), "Password is verified.")
  }

  func testVerifyNonMatchingPassword() {
    let user = User(emailAddress: "testuser@unicus.no", passwordOne: "password", passwordTwo: "password")

    XCTAssertNotNil(user, "User created successfully.")
    XCTAssertFalse(user!.verifyPassword("pass word"), "Password is not verified.")
  }

  func testUsernameValidityEmptyUser() {
    let user = User(emailAddress: "not_an_email_address")

    XCTAssertNil(user)
  }

  func testUsernameValidity() {
    let user = User(emailAddress: "not_an_email_address", passwordOne: "password", passwordTwo: "password")

    XCTAssertNil(user)
  }

  func testHashingFunction() {
    let hashingFunction: (String) -> String = { String($0.reversed()) }
    let user = User(
      emailAddress: "testuser@unicus.no",
      passwordOne: "password",
      passwordTwo: "password",
      hashingFunction: hashingFunction
    )

    XCTAssertNotNil(user, "User created successfully.")
    XCTAssertTrue(user!.verifyPassword("password", hashingFunction: hashingFunction), "Password is verified.")
  }

  func testSalt() {
    let saltFunction: () -> String = { "salt" }
    let user = User(
      emailAddress: "testuser@unicus.no",
      passwordOne: "password",
      passwordTwo: "password",
      saltFunction: saltFunction
    )

    XCTAssertNotNil(user, "User created successfully.")
    XCTAssertTrue(user!.verifyPassword("password"), "Password is verified.")
  }
}
