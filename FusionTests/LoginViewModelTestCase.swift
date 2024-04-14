//
//  LoginViewModelTestCase.swift
//  FusionTests
//
//  Created by Cristina Berlinschi on 29/03/2024.
//

import XCTest
@testable import Fusion

@MainActor
final class LoginViewModelTestCase: XCTestCase {
    
    var viewModel: LoginViewModel!

    override func setUpWithError() throws {
        viewModel = LoginViewModel()
        viewModel.email = "test1@gmail.com"
        viewModel.password = "123456abc"
    }

    override func tearDownWithError() throws {
    }

    func testEmail() throws {
        XCTAssertTrue(viewModel.isEmailValid(), "User email is not valid")
    }
    
    func testPassword() throws {
        XCTAssertTrue(viewModel.isPasswordValid(), "User password is not valid")
    }
    

    func testPerformanceExample() throws {
        self.measure {
        }
    }

}
