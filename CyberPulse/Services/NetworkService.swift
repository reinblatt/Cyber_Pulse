import Foundation
import Combine
import Alamofire

class NetworkService {
    private let baseURL = "https://api.cybersecuritynews.com/v1"
    private let apiKey: String
    
    init(apiKey: String = ProcessInfo.processInfo.environment["CYBERSECURITY_NEWS_API_KEY"] ?? "") {
        self.apiKey = apiKey
    }
    
    func fetchNews() -> AnyPublisher<[NewsItem], Error> {
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(apiKey)",
            "Accept": "application/json"
        ]
        
        return Future<[NewsItem], Error> { promise in
            AF.request("\(self.baseURL)/news",
                      method: .get,
                      headers: headers)
                .validate()
                .responseDecodable(of: NewsResponse.self) { response in
                    switch response.result {
                    case .success(let newsResponse):
                        promise(.success(newsResponse.articles))
                    case .failure(let error):
                        promise(.failure(error))
                    }
                }
        }
        .eraseToAnyPublisher()
    }
}

private struct NewsResponse: Decodable {
    let articles: [NewsItem]
    
    enum CodingKeys: String, CodingKey {
        case articles
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        articles = try container.decode([NewsItem].self, forKey: .articles)
    }
} 