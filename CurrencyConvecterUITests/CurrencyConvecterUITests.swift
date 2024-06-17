//
//  CurrencyConvecterUITests.swift
//  CurrencyConvecterUITests
//
//  Created by Екатерина Токарева on 19/01/2023.
//

import XCTest

final class CurrencyConvecterUITests: XCTestCase {
    private var app: XCUIApplication!
    private lazy var buyButton = app.buttons["BUY_BUTTON"]
    private lazy var sellButton = app.buttons["SELL_BUTTON"]
    private lazy var addCurrencyButton = app.buttons["ADD_CURRENCY_BUTTON"]
    private lazy var shareButton = app.images["SHARE_BUTTON"]
    private lazy var baseCurrencyTextField = app.textFields["BASE_CURRENCY_TEXT_FIELD"]
    private lazy var firstExchangeCurrencyTextField = app.textFields["FIRST_EXCHANGE_CURRENCY_TEXT_FIELD"]
    private lazy var secondExchangeCurrencyTextField = app.textFields["SECOND_EXCHANGE_CURRENCY_TEXT_FIELD"]
    private lazy var updateTime = app.staticTexts["UPDATE_TIME"]
    
    override func setUp() {
        app = XCUIApplication()
        app.launch()
        continueAfterFailure = false
    }
    
    func testExchangeView() {
        baseCurrencyTextField.tap()
        baseCurrencyTextField.typeText("100")
        app/*@START_MENU_TOKEN@*/.buttons["Done"]/*[[".keyboards",".buttons[\"done\"]",".buttons[\"Done\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.tap()
        app/*@START_MENU_TOKEN@*/.staticTexts["Sell"]/*[[".buttons[\"Sell\"].staticTexts[\"Sell\"]",".buttons[\"SELL_BUTTON\"].staticTexts[\"Sell\"]",".staticTexts[\"Sell\"]"],[[[-1,2],[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        let firstExchangeCurrencyValue = firstExchangeCurrencyTextField.value as! String
        let secondExchangeCurrencyValue = secondExchangeCurrencyTextField.value as! String
        XCTAssertFalse(firstExchangeCurrencyValue.isEmpty)
        XCTAssertFalse(secondExchangeCurrencyValue.isEmpty)
    }
    
    func testShareOption() {
        shareButton.tap()
        let collectionViewsQuery = app/*@START_MENU_TOKEN@*/.collectionViews/*[[".otherElements[\"ActivityListView\"].collectionViews",".collectionViews"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        collectionViewsQuery.buttons["Copy"].children(matching: .other).element(boundBy: 1).children(matching: .other).element(boundBy: 2).tap()
    }
    
    func testCurrenciesView() {
        addCurrencyButton.tap()
        let searchCurrenciesSearchField = app.navigationBars["Currencies"].searchFields["Search Currencies"]
        searchCurrenciesSearchField.tap()
        searchCurrenciesSearchField.typeText("usd")
        let USD = app/*@START_MENU_TOKEN@*/.staticTexts["USD: United States Dollar"]/*[[".cells.staticTexts[\"USD: United States Dollar\"]",".staticTexts[\"USD: United States Dollar\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        XCTAssertTrue(USD.exists)
    }
    
    func testDoesntUpdateInLessThenHour() {
        let updateText = updateTime.label
        XCUIDevice.shared.press(.home)
        app.activate()
        let updateTextAfterReopen = updateTime.label
        XCTAssertEqual(updateText, updateTextAfterReopen)
    }
    
    func testPullToUpdate() {
        let updateText = updateTime.label
        let firstCell = app.staticTexts["CONVERTOR"]
        let start = firstCell.coordinate(withNormalizedOffset: CGVectorMake(0, 0))
        let finish = firstCell.coordinate(withNormalizedOffset: CGVectorMake(0, 100))
        start.press(forDuration: 0, thenDragTo: finish)
        let updateTextAfterReopen = updateTime.label
        XCTAssertNotEqual(updateText, updateTextAfterReopen)
    }
}
