//
//  HomeViewModelTestCase.swift
//  FusionTests
//
//  Created by Cristina Berlinschi on 24/03/2024.
//

import XCTest
@testable import Fusion

final class HomeViewModelTestCase: XCTestCase {
    
    var viewModel: HomeViewModel!

    override func setUpWithError() throws {
        viewModel = HomeViewModel() //setup
        viewModel.userLocation = CLLocation(latitude: 53.6168073214048, longitude: -6.199705576861311) //mocking my location
    }

    override func tearDownWithError() throws {
    }

    func testUsersAreInRange() throws { //testing to see if Fusion is able to pick up users correctly that are in range
        let rangeResults = MockUsers.users.map({  viewModel.isInRange(user: $0, ofLocation: viewModel.userLocation!, range: 1000000) }) //map picks up users and sees if users are in range and creates an array of users that are in range
        XCTAssertTrue(!rangeResults.contains(false), "A user or users are not in range of you") //if I get false users are not in range
    }
    

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
