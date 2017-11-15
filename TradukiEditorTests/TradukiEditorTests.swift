//
//  TradukiEditorTests.swift
//  TradukiEditorTests
//
//  Created by Vergil Choi on 2017/11/14.
//  Copyright © 2017年 Vergil Choi. All rights reserved.
//

import XCTest

class TradukiEditorTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testProjectElement() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        ProjectManager.shared.createProjectFile()
    }
    
//    func testPerformanceExample() {
//        // This is an example of a performance test case.
//        self.measure {
//            // Put the code you want to measure the time of here.
//        }
//    }
    
}
