import XCTest

class OnboardingUITests: XCTestCase {
    let app = XCUIApplication()

    override func setUpWithError() throws {
        continueAfterFailure = false
        // UI 테스트용 환경 설정
        app.launch()
        
        // 테스트 시작 전 로그아웃 상태 확인
        if app.buttons["plus"].exists { // 메인 화면의 플로팅 버튼 존재 여부로 로그인 상태 체크
            navigateToSettings()
            app.buttons["로그아웃"].tap()
            sleep(1)
            app.buttons["로그아웃"].tap() // 팝업의 확인 버튼
        }
    }
    
    // MARK: - 새 사용자 가입 플로우 테스트
    func test_NewUserSignUpFlow() throws {
        // Given: 온보딩 화면에서 시작
        let emailInput = app.textFields["이메일"]
        XCTAssertTrue(emailInput.waitForExistence(timeout: 5))
        
        // When: 새로운 이메일 입력
        emailInput.tap()
        emailInput.typeText("newuser@example.com")
        sleep(1)
        
        // Then: 이메일로 시작하기 버튼 탭
        app.buttons["이메일로 시작하기"].tap()
        sleep(2) // 서버 응답 대기
        
        // 회원가입 화면으로 전환 확인
        let usernameInput = app.textFields["사용자 이름"]
        XCTAssertTrue(usernameInput.waitForExistence(timeout: 5))
        
        // 사용자 이름 입력
        usernameInput.tap()
        usernameInput.typeText("TestUser")
        sleep(1)
        
        // 비밀번호 입력
        let passwordInput = app.secureTextFields["비밀번호"]
        passwordInput.tap()
        passwordInput.typeText("password123")
        sleep(1)
        
        // 계정 생성
        app.buttons["계정 생성하기"].tap()
        sleep(2)
        
        // 메인 화면으로 전환 확인
        XCTAssertTrue(app.buttons["plus"].waitForExistence(timeout: 5))
    }
    
    // MARK: - 기존 사용자 로그인 플로우 테스트
    func testExistingUserLoginFlow() throws {
        // Given: 온보딩 화면에서 시작
        let emailInput = app.textFields["이메일"]
        XCTAssertTrue(emailInput.waitForExistence(timeout: 5))
        
        // When: 기존 이메일 입력
        emailInput.tap()
        emailInput.typeText("existing@example.com")
        sleep(1)
        
        // 이메일로 시작하기 버튼 탭
        app.buttons["이메일로 시작하기"].tap()
        sleep(2)
        
        // Then: 비밀번호 입력 필드 표시 확인
        let passwordInput = app.secureTextFields["비밀번호"]
        XCTAssertTrue(passwordInput.waitForExistence(timeout: 5))
        
        // 비밀번호 입력
        passwordInput.tap()
        passwordInput.typeText("password123")
        sleep(1)
        
        // 로그인
        app.buttons["로그인하기"].tap()
        sleep(2)
        
        // 메인 화면으로 전환 확인
        XCTAssertTrue(app.buttons["plus"].waitForExistence(timeout: 5))
    }
    
    // MARK: - 소셜 로그인 플로우 테스트
    func testSocialLoginFlow() throws {
        // Google 로그인
        XCTAssertTrue(app.buttons["Google로 시작하기"].waitForExistence(timeout: 5))
        app.buttons["Google로 시작하기"].tap()
        sleep(2)
        
        // Apple 로그인 버튼 존재 확인
        XCTAssertTrue(app.buttons["Sign in with Apple"].exists)
    }
    
    // MARK: - 게스트 모드 테스트
    func testGuestModeFlow() throws {
        // 게스트 모드 시작
        XCTAssertTrue(app.buttons["게스트모드로 시작하기"].waitForExistence(timeout: 5))
        app.buttons["게스트모드로 시작하기"].tap()
        sleep(2)
        
        // 게스트 모드에서 Todo 추가 시도
        XCTAssertTrue(app.buttons["plus"].waitForExistence(timeout: 5))
        app.buttons["plus"].tap()
        sleep(1)
        
        // 로그인 필요 팝업 확인
        XCTAssertTrue(app.staticTexts["로그인 필요"].exists)
    }
    
    // MARK: - 유효성 검사 테스트
    func testValidationFlow() throws {
        // 이메일 유효성 검사
        let emailInput = app.textFields["이메일"]
        emailInput.tap()
        emailInput.typeText("invalid-email")
        app.buttons["이메일로 시작하기"].tap()
        sleep(1)
        // 에러 메시지 확인
        XCTAssertTrue(app.staticTexts["이메일 주소가 올바르지 않아요. 오타는 없었는지 확인해 주세요."].exists)
        
        // 회원가입 화면으로 이동
        emailInput.tap()
        emailInput.typeText("newuser@example.com")
        app.buttons["이메일로 시작하기"].tap()
        sleep(2)
        
        // 사용자 이름 유효성 검사 (3-20자 영문, 숫자)
        let usernameInput = app.textFields["사용자 이름"]
        usernameInput.tap()
        usernameInput.typeText("a")
        
        // 비밀번호 유효성 검사 (8자 이상)
        let passwordInput = app.secureTextFields["비밀번호"]
        passwordInput.tap()
        passwordInput.typeText("123")
        
        // 버튼 비활성화 상태 확인
        XCTAssertFalse(app.buttons["계정 생성하기"].isEnabled)
    }
    
    // MARK: - 화면 전환 테스트
    func testNavigationFlow() throws {
        // 회원가입 화면으로 이동했다가 돌아오기
        let emailInput = app.textFields["이메일"]
        emailInput.tap()
        emailInput.typeText("newuser@example.com")
        app.buttons["이메일로 시작하기"].tap()
        sleep(2)
        
        // 로그인으로 돌아가기
        app.buttons["로그인으로 돌아가기"].tap()
        sleep(1)
        
        // 원래 화면으로 돌아왔는지 확인
        XCTAssertTrue(app.buttons["이메일로 시작하기"].exists)
    }
    
    // MARK: - Helper Methods
    private func navigateToSettings() {
        app.buttons["MY"].tap()
        sleep(1)
        app.buttons["gearshape.fill"].tap()
        sleep(1)
    }
}

// MARK: - XCUIApplication Extension
extension XCUIApplication {
    // 자주 사용하는 UI 요소들에 대한 편의 속성
    var emailTextField: XCUIElement {
        textFields["이메일"]
    }
    
    var passwordSecureTextField: XCUIElement {
        secureTextFields["비밀번호"]
    }
    
    var usernameTextField: XCUIElement {
        textFields["사용자 이름"]
    }
    
    // 특정 텍스트가 화면에 표시되는지 확인하는 헬퍼 메서드
    func containsText(_ text: String) -> Bool {
        staticTexts[text].exists
    }
    
    // 버튼이 활성화될 때까지 대기하는 헬퍼 메서드
    func waitForButton(_ identifier: String, timeout: TimeInterval = 5) -> Bool {
        buttons[identifier].waitForExistence(timeout: timeout)
    }
}
