//
//  HomeViewModelTestCase.swift
//  FusionTests
//
//  Created by Cristina Berlinschi on 24/03/2024.
//

import XCTest
@testable import Fusion
import FirebaseFirestore

final class HomeViewModelTestCase: XCTestCase {
    
    var viewModel: HomeViewModel!
    var likedDocumentID: String?
    var dislikedDocumentID: String?
    
    enum TestErrors: Error { //defining possible errors that might arise
        case documentIDError, emptyDocumentSnapshot
    }

    override func setUpWithError() throws {
        viewModel = HomeViewModel() //setup
        viewModel.userLocation = CLLocation(latitude: 53.6168073214048, longitude: -6.199705576861311) //mocking my location
    }

    override func tearDownWithError() throws {
        if let likedDocumentID = likedDocumentID {
            Firestore.firestore().collection("swiped").document(likedDocumentID).delete() //deleting the tests data that may has been saved in the database
        }
        if let dislikedDocumentID = dislikedDocumentID {
            Firestore.firestore().collection("swiped").document(dislikedDocumentID).delete() //deleting the tests data that may has been saved in the database
        }
    }

    func testLikingUser() async throws { //testing for swiping right on a user, expected it is saved within database ie it is saving properly
        let mockUserID = "testUserID"
        let user = User(id: "testOtherUserID", fullname: "Bob Builder", email: "bob123@gmail.com", businessField: .fashion)
        let documentReference = await viewModel.swiped(user: user, isRight: true, currentUserID: mockUserID)
        guard let documentID = documentReference?.documentID else {
            throw TestErrors.documentIDError
        }
        self.likedDocumentID = documentID //makes it aware of the documentID 
        let result = try? await Firestore.firestore().collection("swiped").document(documentID).getDocument()
        guard let documentSnapshot = result,
        let data = documentSnapshot.data(),
        let isRight = data["isRight"] as? Bool else {
            throw TestErrors.emptyDocumentSnapshot
        }
        XCTAssertTrue(isRight)
    }
    
    func testDislikingUser() async throws { //testing for swiping left on a user, expected it is saved within database ie it is saving properly
        let mockUserID = "testUserID"
        let user = User(id: "testOtherUserID", fullname: "Bob Builder", email: "bob123@gmail.com", businessField: .fashion)
        let documentReference = await viewModel.swiped(user: user, isRight: false, currentUserID: mockUserID)
        guard let documentID = documentReference?.documentID else {
            throw TestErrors.documentIDError
        }
        self.dislikedDocumentID = documentID
        let result = try? await Firestore.firestore().collection("swiped").document(documentID).getDocument()
        guard let documentSnapshot = result,
        let data = documentSnapshot.data(),
        let isRight = data["isRight"] as? Bool else {
            throw TestErrors.emptyDocumentSnapshot
        }
        XCTAssertTrue(!isRight)
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
