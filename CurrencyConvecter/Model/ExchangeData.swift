//
//  ExchangeData.swift
//  CurrencyConvecter
//
//  Created by Екатерина Токарева on 20/01/2023.
//

import Foundation

struct ExchangeData: Codable, Equatable {
    let baseCurrency: String
    let exchangeCurrency: String
    let buyRate: String
    let sellRate: String

    enum CodingKeys: String, CodingKey {
        case baseCurrency = "base_ccy"
        case exchangeCurrency = "ccy"
        case buyRate = "buy"
        case sellRate = "sale"
    }
    
    static func ==(lhs: ExchangeData, rhs: ExchangeData) -> Bool {
        return lhs.baseCurrency == rhs.baseCurrency && lhs.exchangeCurrency == rhs.exchangeCurrency && lhs.buyRate == rhs.buyRate && lhs.sellRate == rhs.sellRate
    }
    
}
