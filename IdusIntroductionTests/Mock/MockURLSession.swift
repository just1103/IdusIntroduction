//
//  MockURLSession.swift
//  IdusIntroductionTests
//
//  Created by Hyoju Son on 2022/08/07.
//

import Foundation
import Combine
@testable import IdusIntroduction

final class MockURLSession: URLSessionProtocol {
    var isRequestSuccess: Bool
    
    init(isRequestSuccess: Bool = true) {
        self.isRequestSuccess = isRequestSuccess
    }
    
    func request<T: Decodable>(urlRequest: URLRequest) -> AnyPublisher<T, NetworkError> {
        guard
            let path = Bundle(for: type(of: self)).path(forResource: "MockIdusSearchResult", ofType: "json"),
            let jsonString = try? String(contentsOfFile: path),
            let jsonData = jsonString.data(using: .utf8),
            let searchResult = try? JSONDecoder().decode(SearchResultDTO.self, from: jsonData) as? T
        else {
            fatalError()
        }
        
        if isRequestSuccess {
            return Just(searchResult)
                .setFailureType(to: NetworkError.self)
                .eraseToAnyPublisher()
        } else {
            return Fail(error: NetworkError.statusCodeError)
                .eraseToAnyPublisher()
        }
    }
}
