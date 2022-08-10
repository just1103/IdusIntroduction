//
//  ItunesAPI.swift
//  AppStoreClone
//
//  Created by Hyoju Son on 2022/08/07.
//

import Combine
import Foundation

struct ItunesAPI {
    static let baseURL: String = "http://itunes.apple.com/"
}

extension ItunesAPI {
    struct AppLookup: Gettable {
        let session: URLSessionProtocol
        let url: URL?
        let method: HttpMethod = .get
//        var headers: [String : String] = [:]
//        var body: Data? = nil
        let appID: String
        
        init(
            appID: String,
            session: URLSessionProtocol = URLSession.shared,
            baseURL: String = baseURL
        ) {
            self.appID = appID
            self.session = session
            
            var urlComponents = URLComponents(string: "\(baseURL)lookup?")
            let appIDQuery = URLQueryItem(name: "id", value: "\(self.appID)")
            urlComponents?.queryItems?.append(appIDQuery)
            self.url = urlComponents?.url
        }
        
        func fetchData() -> AnyPublisher<SearchResultDTO, NetworkError> {
            guard let urlRequest = URLRequest(api: self) else {
                return Fail(error: NetworkError.urlIsNil)
                    .eraseToAnyPublisher()
            }
            
            return session.request(urlRequest: urlRequest)
        }
    }
}

// MARK: - NetworkError
enum NetworkError: Error, LocalizedError {
    case urlIsNil
    case statusCodeError
    case unknownError(message: String)
    
    var errorDescription: String? {
        switch self {
        case .urlIsNil:
            return "정상적인 URL이 아닙니다."
        case .statusCodeError:
            return "정상적인 StatusCode가 아닙니다."
        case .unknownError:
            return "알수 없는 에러가 발생했습니다."
        }
    }
}
