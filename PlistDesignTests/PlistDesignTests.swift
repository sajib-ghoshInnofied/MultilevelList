//
//  PlistDesignTests.swift
//  PlistDesignTests
//
//  Created by Sajib Ghosh on 21/12/23.
//

import XCTest
@testable import PlistDesign

final class PlistDesignTests: XCTestCase {

    var mockNetwork: MockNetwork!
    var sut: HomeViewModel!
    
    override func setUp() {
        super.setUp()
        mockNetwork = MockNetwork()
        let apiDataManager = HomeAPIDataManager(networkService: mockNetwork)
        sut = HomeViewModel(apiDataManager: apiDataManager)
    }
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func test_fetching_data_with_success() async {
        //Given
        mockNetwork.shouldReturnError = false
        //When
        var actualData: PlistRootModel?
        let expectation = self.expectation(description: "Fetch plist data")
        var thrownError: Error?
        let errorHandler = { thrownError = $0 }
        let dataHandler = { actualData = $0 }
        Task{
            let (plist,error) = await sut.fetchPlist()
            dataHandler(plist)
            errorHandler(error)
            expectation.fulfill()
        }
        //Then
        await fulfillment(of: [expectation],timeout: 2)
        XCTAssertNotNil(actualData)
        if let error = thrownError {
            XCTFail("Async error thrown: \(error.localizedDescription)")
        }
    }
    
    func test_fetching_data_with_error() async {
        //Given
        mockNetwork.shouldReturnError = true
        //When
        var receivedError: CustomError?
        let (_,error) = await sut.fetchPlist()
        receivedError = error
        //Then
        XCTAssertNotNil(receivedError)
        
    }

}
