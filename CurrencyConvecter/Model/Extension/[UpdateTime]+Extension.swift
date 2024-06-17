//
//  [LatestRate]+Extension.swift
//  CurrencyConvecter
//
//  Created by Екатерина Токарева on 30/01/2023.
//

import Foundation

extension [UpdateTime] {
    var hourHasPassed: Bool {
        guard !self.isEmpty else {
            return true
        }
        let currentTime = Date()
        if let time = self.first?.time,
           let newTime = Calendar.current.date(byAdding: .hour, value: -1, to: time),
           currentTime > newTime {
            return true
        }
        return false
    }
}
