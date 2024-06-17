//
//  Date+Extension.swift
//  CurrencyConvecter
//
//  Created by Екатерина Токарева on 30/01/2023.
//

import Foundation

extension Date {
    
    var formatted: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .long
        formatter.dateStyle = .medium
        formatter.locale = Locale(identifier: "en_UK")
        return formatter.string(from: self)
    }
}
