//
//  myMessengerUITests.swift
//  myMessengerUITests
//
//  Created by Mokhtar on 10/18/18.
//  Copyright © 2018 Ahmed Mokhtar. All rights reserved.
//

import XCTest

class myMessengerUITests: XCTestCase {
    
    let app = XCUIApplication()

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        app.launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        
        let app = XCUIApplication()
        let tablesQuery = app.tables
        tablesQuery.staticTexts["Ozil"].tap()
        app.navigationBars["myMessenger.ChatLogView"].buttons["Back"].tap()
        tablesQuery/*@START_MENU_TOKEN@*/.cells.staticTexts["Mokhtar"]/*[[".cells.staticTexts[\"Mokhtar\"]",".staticTexts[\"Mokhtar\"]"],[[[-1,1],[-1,0]]],[1]]@END_MENU_TOKEN@*/.tap()
        
        let collectionViewsQuery = app.collectionViews
        collectionViewsQuery/*@START_MENU_TOKEN@*/.buttons["play"].swipeLeft()/*[[".cells.buttons[\"play\"]",".swipeUp()",".swipeLeft()",".buttons[\"play\"]"],[[[-1,3,1],[-1,0,1]],[[-1,2],[-1,1]]],[0,0]]@END_MENU_TOKEN@*/
        collectionViewsQuery.children(matching: .cell).element(boundBy: 8).otherElements.containing(.button, identifier:"play").children(matching: .image).element.tap()
        collectionViewsQuery.children(matching: .cell).element(boundBy: 1).children(matching: .other).element(boundBy: 1).tap()
        
        
    }

}
