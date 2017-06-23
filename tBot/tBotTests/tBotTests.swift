//
//  tBotTests.swift
//  tBotTests
//
//  Created by Сергей Мельников on 20/06/2017.
//  Copyright © 2017 Сергей Мельников. All rights reserved.
//

import XCTest

@testable import tBot

class tBotTests: XCTestCase {
    
    var client: ClientAPI!
    
    override func setUp() {
        super.setUp()
        client = ClientAPI()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testTranslateFromRuToEn() {
        let exp = expectation(description: "\(#function)\(#line)")
        client.translate(text: "Привет") { _, translate in
            XCTAssertTrue(translate?.translate == "Hi")
            exp.fulfill()
        }
        waitForExpectations(timeout: 5) { (error) in
            if error != nil {
                XCTAssertTrue(false)
            }
        }
    }
    
    func testTranslateFromEnToRu() {
        let exp = expectation(description: "\(#function)\(#line)")
        client.fromLang = "en"
        client.toLang = "ru"
        client.translate(text: "Hello") { _, translate in
            XCTAssertTrue(translate?.translate == "Привет")
            exp.fulfill()
        }
        waitForExpectations(timeout: 5) { (error) in
            if error != nil {
                XCTAssertTrue(false)
            }
        }
    }
    
//    func testGetListLang() {
//        let exp = expectation(description: "\(#function)\(#line)")
//        client.getListLang() { _, list in
//            if list != nil {
//                XCTAssertTrue(!(list?.isEmpty)!)
//                exp.fulfill()
//            } else {
//                XCTAssert(false)
//                exp.fulfill()
//            }
//        }
//        waitForExpectations(timeout: 5) { (error) in
//            if error != nil {
//                XCTAssertTrue(false)
//            }
//        }
//    }
    
}
