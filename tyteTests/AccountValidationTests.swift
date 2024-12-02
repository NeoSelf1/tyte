//
//  AccountValidationTests.swift
//  tyte
//
//  Created by Neoself on 11/27/24.
//

import XCTest
@testable import tyte
import Foundation
import Combine

final class AccountValidationTests: XCTestCase {
    var viewModel: AuthViewModel!
    var mockAuthService: MockAuthService!
    
    override func setUp() {
        super.setUp()
        mockAuthService = MockAuthService()
        viewModel = AuthViewModel(authService: mockAuthService)
    }
    
    override func tearDown() {
        viewModel = nil
        mockAuthService = nil
        super.tearDown()
    }
    
    func testValidUsername() {
        let validUsernames = ["user123", "neo_self", "test_user_123", "abc123", "username20"]
        
        for username in validUsernames {
            viewModel.username = username
            XCTAssertTrue(viewModel.usernamePredicate.evaluate(with: username), "Username '\(username)' should be valid")
            XCTAssertFalse(viewModel.isUsernameInvalid)
        }
    }
    
    func testUsernameTooShort() {
        let shortUsernames = ["a", "ab", ""]
        
        for username in shortUsernames {
            viewModel.username = username
            XCTAssertFalse(viewModel.usernamePredicate.evaluate(with: username), "Username '\(username)' should be invalid - too short")
        }
    }
    
    func testUsernameTooLong() {
        let longUsername = "verylongusernamethatismorethan20characters"
        
        viewModel.username = longUsername
        XCTAssertFalse(viewModel.usernamePredicate.evaluate(with: longUsername), "Username should be invalid - too long")
    }
    
    func testUsernameInvalidCharacters() {
        let invalidUsernames = [
            "user@name",  // @ not allowed
            "user name",  // space not allowed
            "user-name",  // hyphen not allowed
            "user.name",  // period not allowed
            "user#name",  // special characters not allowed
            "!username",  // special characters not allowed
        ]
        
        for username in invalidUsernames {
            viewModel.username = username
            XCTAssertFalse(viewModel.usernamePredicate.evaluate(with: username), "Username '\(username)' should be invalid - contains invalid characters")
        }
    }
    
    func testKoreanUsername() {
        let validUsernames = [
            "홍길동",
            "사용자123",
            "테스트_user",
            "ㄱㄴㄷ123",
            "한글이름2024"
        ]
        
        for username in validUsernames {
            viewModel.username = username
            XCTAssertTrue(viewModel.usernamePredicate.evaluate(with: username), "Korean username '\(username)' should be valid")
        }
    }
    
    func testUsernameEdgeCases() {
        let edgeCases = ["123", "aaa", "12345678901234567890", "___", "a_1"]
        for username in edgeCases {
            viewModel.username = username
            XCTAssertTrue(viewModel.usernamePredicate.evaluate(with: username), "Username '\(username)' should be valid")
        }
    }
    
    func testUsernameStateReset() {
        // Test that isUsernameInvalid is reset when username changes
        viewModel.username = "invalid@username"
        viewModel.isUsernameInvalid = true
        
        // When username changes
        viewModel.username = "valid_username"
        
        // Then isUsernameInvalid should be reset
        XCTAssertFalse(viewModel.isUsernameInvalid, "isUsernameInvalid should be reset when username changes")
    }
    
    func testSignUpButtonStateWithUsername() {
        viewModel.email = "test@example.com"
        viewModel.password = "password123"
        viewModel.username = "a"  // Too short
        XCTAssertTrue(viewModel.isSignUpButtonDisabled, "Sign up button should be disabled with invalid username")
        viewModel.username = "validuser123"
        XCTAssertFalse(viewModel.isSignUpButtonDisabled, "Sign up button should be enabled with valid username")
    }
    
    //MARK: - 비밀번호
    func testValidPasswords() {
            let validPasswords = ["password123", "longpassword1234567890", "Pass1234!@#$", "한글비밀번호123", "12345678", "        "]
            
            for password in validPasswords {
                viewModel.password = password
                XCTAssertTrue(viewModel.passwordPredicate.evaluate(with: password), "Password '\(password)' should be valid")
                XCTAssertFalse(viewModel.isPasswordInvalid, "Password '\(password)' should not set isPasswordInvalid")
            }
        }
        
        func testPasswordTooShort() {
            let shortPasswords = ["", "1234567", "short", "abc"]
            
            for password in shortPasswords {
                viewModel.password = password
                XCTAssertFalse(viewModel.passwordPredicate.evaluate(with: password), "Password '\(password)' should be invalid - too short")
            }
        }
        
        func testPasswordStateReset() {
            viewModel.password = "short"
            viewModel.isPasswordInvalid = true
            viewModel.isPasswordWrong = true
            viewModel.password = "newpassword123"
            
            XCTAssertFalse(viewModel.isPasswordInvalid, "isPasswordInvalid should be reset when password changes")
            XCTAssertFalse(viewModel.isPasswordWrong, "isPasswordWrong should be reset when password changes")
        }
        
        func testSignUpButtonStateWithPassword() {
            viewModel.username = "validuser"
            viewModel.email = "test@example.com"
            viewModel.password = "short"
            XCTAssertTrue(viewModel.isSignUpButtonDisabled, "Sign up button should be disabled with invalid password")
            viewModel.password = "validpassword123"
            XCTAssertFalse(viewModel.isSignUpButtonDisabled, "Sign up button should be enabled with valid password")
        }
        
        func testLoginButtonStateWithPassword() {
            viewModel.email = "test@example.com"
            viewModel.isExistingUser = true
            viewModel.password = ""
            XCTAssertTrue(viewModel.isButtonDisabled, "Login button should be disabled with empty password")
            viewModel.password = "password123"
            XCTAssertFalse(viewModel.isButtonDisabled, "Login button should be enabled with non-empty password")
            viewModel.isPasswordWrong = true
            XCTAssertTrue(viewModel.isButtonDisabled, "Login button should be disabled with wrong password")
        }
        
        func testPasswordErrorStatesAfterLoginFailure() {
            let expectation = XCTestExpectation(description: "Login failure")
            mockAuthService.mockLoginResult = .failure(.wrongPassword)
            viewModel.email = "test@test.com"
            viewModel.password = "wrongpassword"
            viewModel.isExistingUser = true
            viewModel.login()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                XCTAssertTrue(self.viewModel.isPasswordWrong, "isPasswordWrong should be true after login failure")
                XCTAssertFalse(self.viewModel.isLoading, "isLoading should be false after login failure")
                XCTAssertFalse(self.viewModel.isPasswordInvalid, "isPasswordInvalid should not be affected by login failure")
                expectation.fulfill()
            }
            wait(for: [expectation], timeout: 1.0)
        }
}
