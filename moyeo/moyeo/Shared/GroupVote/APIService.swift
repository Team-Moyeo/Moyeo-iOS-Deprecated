//
//  APIService.swift
//  moyeo
//
//  Created by Giwoo Kim on 8/8/24.
//
// JSON 데이터로 인코딩
//voteInfo -> jsonData ---------------------------> jsonObject ------------------> jsonStringData -----> jsonString
//         encode      JSONSerialization.jsonObject         JSONSerialization.data                 String
//voteInfo ----> jsonData -------> jsonString
//         encode         String
// 차이 [String: String] vs [String: Any]  , JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted)



import Foundation
import Combine
import Foundation
//  T를 URLSession.shared.dataTaskPublisher에서 가져오는 모델로 정의함.
// Combine으로 작성하고 다시  async/await으로 작성
// SwiftTips 참조 https://www.youtube.com/watch?v=esmf26aGz4s

class APIService<T: Decodable, S:Decodable> {
    
    //혹시 모르니  public
    var cancellables = Set<AnyCancellable>()
    var responseData: T?
    var response : S?
    
    func get(for url: URL) -> AnyPublisher<T, Error> {
        URLSession.shared
            .dataTaskPublisher(for: url)
            .tryMap { element -> Data in
                guard let httpResponse = element.response as? HTTPURLResponse,
                    httpResponse.statusCode == 200 else {
                        throw URLError(.badServerResponse)
                    }
                
                return element.data
            }
            .decode(type: T.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
    
   func fetchData(url: URL) {
            get(for: url)
                .sink(
                    receiveCompletion: { completion in
                        switch completion {
                        case .finished:
                            print("Finished successfully")
                        case .failure(let error):
                            print("Failed with error: \(error)")
                        }
                    },
                    receiveValue: { [weak self] (response: T) in
                        self?.responseData = response
                        print("Received value: \(response)")
                        // response에 대한 추가 작업 수행
                    }
                )
                .store(in: &cancellables)
        }
        
    
        func getResponseData() -> T? {
            return responseData
        }

    
    // combine --> async await 이 간단함
    func asyncLoad(for url: URL) async throws -> T {
      
        let (data, response) = try await URLSession.shared.data(from: url)

        guard (response as? HTTPURLResponse)?.statusCode == 200
        else { throw URLError(.badServerResponse) }

        guard let decoded = try? JSONDecoder().decode(T.self, from: data)
        else { throw URLError(.cannotDecodeContentData)}

        return decoded
       
    }
// URLRequest Version
    
    func get(for urlRequest: URLRequest) -> AnyPublisher<T, Error> {
        URLSession.shared
            .dataTaskPublisher(for: urlRequest)
            .tryMap { element -> Data in
                guard let httpResponse = element.response as? HTTPURLResponse,
                    httpResponse.statusCode == 200 else {
                        throw URLError(.badServerResponse)
                    }
                
                return element.data
            }
            .decode(type: T.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
    
   func fetchData(urlRequest: URLRequest) {
            get(for: urlRequest)
                .sink(
                    receiveCompletion: { completion in
                        switch completion {
                        case .finished:
                            print("Finished successfully")
                        case .failure(let error):
                            print("Failed with error: \(error)")
                        }
                    },
                    receiveValue: { [weak self] (response: T) in
                        self?.responseData = response
                        print("Received value: \(response)")
                        // response에 대한 추가 작업 수행
                    }
                )
                .store(in: &cancellables)
        }
        
    
        
    
    // combine --> async await 이 간단함
    func asyncLoad(for urlRequest: URLRequest) async throws -> T {
      
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        
        print("asyncLoad response \(data)")
        guard (response as? HTTPURLResponse)?.statusCode == 200
        else { throw URLError(.badServerResponse) }
       
        print("Decoding in URL method : \(urlRequest.httpMethod?.description ?? "" ) \(urlRequest.url?.description ?? "" )   type: \(T.self) ")
        
        guard let decoded = try? JSONDecoder().decode(T.self, from: data)
        else { print("Decoding Fail in url \(urlRequest.url) \(data) \(T.self)")
               throw URLError(.cannotDecodeContentData)
        }
        print("asyncLoad Success: \(decoded) ")
      
        return decoded
       
    }
    func asyncPost(for urlRequest: URLRequest) async throws -> S {
       
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        
        print("asyncPost method:\(urlRequest.httpMethod?.description ?? "") data: \(data.description) response :\(response)")
        
        guard (response as? HTTPURLResponse)?.statusCode == 200
        else { throw URLError(.badServerResponse) }
        
        print("asyncPost in url \(String(describing: urlRequest.url?.description)) \(data.base64EncodedString())  type: \(T.self) ")
        
        guard let decoded = try? JSONDecoder().decode( S.self, from: data)
        else { print("Decoding Fail in url \(String(describing: urlRequest.url)) \(data) \(T.self)")
               throw URLError(.cannotDecodeContentData)
        }
        
          
        print("In the asyncSave SUCCESS decoded : \(decoded) ")
      
       return decoded
    }
    
   
}
