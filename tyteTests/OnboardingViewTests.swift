//
//  OnboardingViewTests.swift
//  tyte
//
//  Created by Neoself on 11/27/24.
//

import XCTest
@testable import tyte
import Foundation
import Combine

final class OnboardingViewTests: XCTestCase {
    var viewModel: AuthViewModel!
    var mockAuthService: MockAuthService!
    private var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        print("=== Test Setup ===")
        mockAuthService = MockAuthService()
        cancellables = []
        viewModel = AuthViewModel(authService: mockAuthService, appState: AppState.shared)
    }
    
    override func tearDown() {
        viewModel = nil
        mockAuthService = nil
        cancellables = nil
        super.tearDown()
    }
    
    func testEmailValidation() {
        let expectation = XCTestExpectation(description: "Email validation")
        
        viewModel.email = "invalid-email"
        viewModel.submit()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertTrue(self.viewModel.isEmailInvalid)
            XCTAssertFalse(self.viewModel.isExistingUser)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testPasswordValidation() {
        // Given
        let expectation = XCTestExpectation(description: "Password validation")
        
        // When
        viewModel.password = "short"
        viewModel.submit()
        
        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertTrue(self.viewModel.isPasswordInvalid)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testLoginSuccess() {
        // Given
        let expectation = XCTestExpectation(description: "Login success")
        let expectedResponse = LoginResponse(
            user: User(id: "1", username: "test", email: "test@test.com"),
            token: "test-token"
        )
        mockAuthService.mockLoginResult = .success(expectedResponse)
        
        // When
        viewModel.email = "test@naver.com"
        viewModel.password = "12345678"
        viewModel.isExistingUser = true
        
        viewModel.login()
        
        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            XCTAssertTrue(AppState.shared.isLoggedIn)
            XCTAssertFalse(self.viewModel.isLoading)
            XCTAssertFalse(self.viewModel.isPasswordWrong)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testLoginFailure() {
        // Given
        let expectation = XCTestExpectation(description: "Login failure")
        mockAuthService.mockLoginResult = .failure(.wrongPassword)
        
        // When
        viewModel.email = "test@naver.com"
        viewModel.password = "12341234"
        viewModel.isExistingUser = true
        
        viewModel.login()
        
        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertTrue(self.viewModel.isPasswordWrong)
            XCTAssertFalse(self.viewModel.isLoading)
            XCTAssertFalse(AppState.shared.isLoggedIn)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testSignUpSuccess() {
        // Given
        let expectation = XCTestExpectation(description: "SignUp success")
        let expectedResponse = LoginResponse(
            user: User(id: "1", username: "newuser", email: "new@test.com"),
            token: "new-token"
        )
        mockAuthService.mockSignUpResult = .success(expectedResponse)
        
        // When
        viewModel.email = "new@test.com"
        viewModel.username = "newuser"
        viewModel.password = "password123"
        
        viewModel.signUp()
        
        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertTrue(AppState.shared.isLoggedIn)
            XCTAssertFalse(self.viewModel.isLoading)
            XCTAssertFalse(self.viewModel.isUsernameInvalid)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
}
