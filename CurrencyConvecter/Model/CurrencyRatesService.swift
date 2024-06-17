//
//  NetworkManager.swift
//  CurrencyConvecter
//
//  Created by Екатерина Токарева on 20/01/2023.
//

import Foundation

final class CurrencyRatesService {
    
    func fetchExchangeRate(completionHandler: @escaping ([ExchangeData]) -> Void) {
        var components = URLComponents()
        components.scheme = "https"
        components.host = API.baseUrl
        components.path = API.exchangeRatesEndpoint
        components.queryItems = [URLQueryItem(name: API.courseIdKey, value: String(API.courseIdValue))]
        let url = components.url
        performRequest(withURL: url, completionHandler: completionHandler)
    }
    
    private func performRequest(withURL url: URL?, completionHandler: @escaping ([ExchangeData]) -> Void) {
        guard let url else { return }
        session.dataTask(with: url) { data, response, error in
            if let data = data,
               let exchangeRate = self.parseJSON(withData: data) {
                completionHandler(exchangeRate)
            } else {
                completionHandler([])
            }
        }.resume()
    }
    
    func parseJSON(withData data: Data) -> [ExchangeData]? {
        let decoder = JSONDecoder()
        var exchangeData: [ExchangeData]?
        do {
            exchangeData = try decoder.decode([ExchangeData].self, from: data)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        return exchangeData
    }
    
    private let session: URLSession
    init(session: URLSession = .shared) {
        self.session = session
    }
}
