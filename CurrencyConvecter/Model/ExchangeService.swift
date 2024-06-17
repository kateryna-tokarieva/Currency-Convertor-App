//
//  Exchange.swift
//  CurrencyConvecter
//
//  Created by Екатерина Токарева on 30/01/2023.
//

import Foundation
import UIKit

struct ExchangeService {
    func exchange(optionIsBuy: Bool,
                  amount: Double,
                  rates: [LatestRate],
                  currencyCode: Int) -> (Double, Double) {
        
        let firstRate: Double
        let secondRate: Double
        
        switch currencyCode {
        case 1:
            (firstRate, secondRate) = calculateRates(optionIsBuy, rates[0], rates[1])
        case 2:
            (firstRate, secondRate) = calculateRates(optionIsBuy, rates[1], rates[0])
        default:
            firstRate = (optionIsBuy) ? rates[0].buyRate : rates[0].sellRate
            secondRate = (optionIsBuy) ? rates[1].buyRate : rates[1].sellRate
        }
        
        let result1 = amount / firstRate
        let result2 = amount / secondRate
        return (result1, result2)
    }
    
    private func calculateRates(_ optionIsBuy: Bool, _ rate1: LatestRate, _ rate2: LatestRate) -> (Double, Double) {
        let firstRate = (optionIsBuy) ? 1 / rate1.sellRate : 1 / rate1.buyRate
        let secondRate: Double
        if optionIsBuy {
            secondRate = firstRate * rate2.sellRate
        } else {
            secondRate = firstRate * rate2.buyRate
        }
        return (firstRate, secondRate)
    }
}

