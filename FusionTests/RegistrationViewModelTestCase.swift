//
//  RegistrationViewModelTestCase.swift
//  FusionTests
//
//  Created by Cristina Berlinschi on 20/03/2024.
//

import XCTest
@testable import Fusion

final class RegistrationViewModelTestCase: XCTestCase {
    
    var viewModel: RegistrationViewModel!
    
    override func setUpWithError() throws {
        viewModel = RegistrationViewModel()
        viewModel.email = "test1@gmail.com"
        viewModel.fullname = "Bob Ross"
        viewModel.password = "123456abc" 
        viewModel.confirmPassword = "123456abc"  //mocking registration variables
    }

    override func tearDownWithError() throws {
     
    }

    func testEmail() throws {
        XCTAssertTrue(viewModel.isEmailValid(), "User email is not valid")
    }
    
    func testPassword() throws {
        XCTAssertTrue(viewModel.isPasswordValid(), "User password is not valid")
    }
    
    func testFullname() throws {
        XCTAssertTrue(viewModel.isFullnameValid(), "User full name is not valid")
    }

    func testPerformanceExample() throws {
        self.measure {
        }
    }

}
