//
//  CurrencyConvecterTests.swift
//  CurrencyConvecterTests
//
//  Created by Екатерина Токарева on 19/01/2023.
//

import XCTest
@testable import CurrencyConvecter
import CoreData

final class CurrencyConvecterTests: XCTestCase {
    private enum Currency: Int {
        case UAH = 0
        case EUR = 1
        case USD = 2
    }
    private var currency: Currency = .UAH
    private var rates: [LatestRate] = []
    private var exchangeService = ExchangeService()
    private var persistenceContext: NSManagedObjectContext? {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return nil }
        return appDelegate.persistentContainer.viewContext
    }
   
    func testExchangeServiceWithUAHBuyOption() {
        initializeRates()
        currency = .UAH
        let result = exchangeService.exchange(optionIsBuy: true, amount: 100, rates: rates, currencyCode: 0)
        let expectedResult: (Double, Double) = (50, 20)
        print(rates)
        XCTAssertEqual(result.0, expectedResult.0)
        XCTAssertEqual(result.1, expectedResult.1)
    }
    
    func testExchangeServiceWithUAHSellOption() {
        initializeRates()
        currency = .UAH
        let result = exchangeService.exchange(optionIsBuy: false, amount: 100, rates: rates, currencyCode: currency.rawValue)
        let expectedResult: (Double, Double) = (25, 10)
        XCTAssertEqual(result.0, expectedResult.0)
        XCTAssertEqual(result.1, expectedResult.1)
    }
    
    func testExchangeServiceWithUSDBuyOption() {
        initializeRates()
        currency = .USD
        let result = exchangeService.exchange(optionIsBuy: true, amount: 100, rates: rates, currencyCode: currency.rawValue)
        let expectedResult: (Double, Double) = (1000, 250)
        XCTAssertEqual(result.0, expectedResult.0)
        XCTAssertEqual(result.1, expectedResult.1)
    }
    
    func testExchangeServiceWithUSDSellOption() {
        initializeRates()
        currency = .USD
        let result = exchangeService.exchange(optionIsBuy: false, amount: 100, rates: rates, currencyCode: currency.rawValue)
        let expectedResult: (Double, Double) = (500, 250)
        XCTAssertEqual(result.0, expectedResult.0)
        XCTAssertEqual(result.1, expectedResult.1)
    }
    
    func testExchangeServiceWithEURBuyOption() {
        initializeRates()
        currency = .EUR
        let result = exchangeService.exchange(optionIsBuy: true, amount: 100, rates: rates, currencyCode: currency.rawValue)
        let expectedResult: (Double, Double) = (400, 40)
        XCTAssertEqual(result.0, expectedResult.0)
        XCTAssertEqual(result.1, expectedResult.1)
    }
    
    func testExchangeServiceWithEURSellOption() {
        initializeRates()
        currency = .EUR
        let result = exchangeService.exchange(optionIsBuy: false, amount: 100, rates: rates, currencyCode: currency.rawValue)
        let expectedResult: (Double, Double) = (200, 40)
        XCTAssertEqual(result.0, expectedResult.0)
        XCTAssertEqual(result.1, expectedResult.1)
    }
    
    func testUpateTimeExtensionWithHourPassed() {
        let time = initializeUpdateTime(interval: -4000)
        guard let time = time else { return }
        XCTAssertTrue(time.hourHasPassed)
    }
    
    func testUpateTimeExtensionWithHourDidNotPassed() {
        let time = initializeUpdateTime(interval: +4000)
        guard let time = time else { return }
        XCTAssertFalse(time.hourHasPassed)
    }
    
    func testUpdateTimeExtensionWithNoPreviousTime() {
        let time = initializeUpdateTime(interval: nil)
        guard let time = time else { return }
        XCTAssertFalse(time.hourHasPassed)
    }
    
    func testDateExtension() {
        let date = Date(timeIntervalSince1970: 0)
        let dateText = date.formatted()
        let expectedText = "1/1/1970, 1:00 AM"
        XCTAssertEqual(dateText, expectedText)
    }
    
    // MARK: - Private
    
    private func initializeRates() {
        guard let context = persistenceContext else { return }
        guard let entity = NSEntityDescription.entity(forEntityName: "LatestRate", in: context) else { return }
        let firstExchangeRate = LatestRate(entity: entity, insertInto: context)
        firstExchangeRate.baseCurrency = "UAH"
        firstExchangeRate.exchangeCurrency = "USD"
        firstExchangeRate.buyRate = 2.0
        firstExchangeRate.sellRate = 4.0
        rates.append(firstExchangeRate)
        let secondExchangeRate = LatestRate(entity: entity, insertInto: context)
        secondExchangeRate.baseCurrency = "UAH"
        secondExchangeRate.exchangeCurrency = "EUR"
        secondExchangeRate.buyRate = 5.0
        secondExchangeRate.sellRate = 10.0
        rates.append(secondExchangeRate)
    }
    
    private func initializeUpdateTime(interval: Int?) -> [UpdateTime]? {
        guard let context = persistenceContext else { return nil}
        guard let entity = NSEntityDescription.entity(forEntityName: "UpdateTime", in: context) else { return nil }
        let dataObject = UpdateTime(entity: entity, insertInto: context)
        guard let interval = interval else { return nil }
        dataObject.time = Date(timeIntervalSinceNow: TimeInterval(interval))
        return [dataObject]
    }
}
