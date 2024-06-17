//
//  CurrencyRatesServiceTests.swift
//  CurrencyConvecterTests
//
//  Created by Екатерина Токарева on 30/01/2023.
//

import XCTest
@testable import CurrencyConvecter

final class CurrencyRatesServiceTests: XCTestCase {
    
    private var result: [ExchangeData]?
    private let session = URLSessionMock()
    private lazy var currencyRatesService = CurrencyRatesService(session: session)
    
    func testSuccessfulServiceResponse() {
        let data = loadJSONData(fromFile: "validData")
        session.data = data
        let comparingResult = currencyRatesService.parseJSON(withData: data)
        currencyRatesService.fetchExchangeRate(completionHandler: { self.result = $0 })
        XCTAssertEqual(result, comparingResult)
    }
    
    func testFailServiceResponse() {
        let data = loadJSONData(fromFile: "notValidData")
        session.data = data
        let comparingResult: [ExchangeData]? = []
        currencyRatesService.fetchExchangeRate(completionHandler: { self.result = $0 })
        XCTAssertEqual(result, comparingResult)
    }
    
    // MARK: - Private
    
    private func loadJSONData(fromFile fileName: String) -> Data {
        let bundle = Bundle(for: type(of: self))
        let url = bundle.url(forResource: fileName, withExtension: "json")!
        return try! Data(contentsOf: url)
    }
}
