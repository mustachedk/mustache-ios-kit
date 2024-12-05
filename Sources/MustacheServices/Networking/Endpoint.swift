import Foundation
import MustacheFoundation

public protocol Endpoint {

    var baseURL: URL { get }

    var method: RequestType { get }

    var path: String { get }

    var parameters: [String: String]? { get }

    var headers: [String: String] { get }

    var body: Any? { get }

    var demoData: Decodable? { get }

    var authentication: Authentication { get }

    var encoding: EncodingType { get }

    var cachePolicy: URLRequest.CachePolicy { get }
    
    var requestModifer: ((inout URLRequest) -> ())? { get }
    
}

public extension Endpoint {

    var method: RequestType { return .get }

    var parameters: [String: String]? { return nil }

    var headers: [String: String] { return [:] }

    var body: Any? { return nil }

    var demoData: Decodable? { return nil }

    var authentication: Authentication { return .none }

    var encoding: EncodingType { return .none }

    var cachePolicy: URLRequest.CachePolicy { return .useProtocolCachePolicy }
    
    var requestModifer: ((inout URLRequest) -> ())? { return nil }
    
}

public enum Authentication {
    case none
    case basic
    case bearer
    case oauth
    case oauth2
}

public extension Endpoint {

    func request() -> URLRequest {

        guard var components = URLComponents(url: self.baseURL.appendingPathComponent(self.path), resolvingAgainstBaseURL: false) else {
            fatalError("Unable to create URL components")
        }

        if let parameters = self.parameters {
            components.queryItems = parameters.map {
                URLQueryItem(name: String($0), value: String($1))
            }
        }

        guard let url = components.url else {
            fatalError("Could not get url")
        }

        var request = URLRequest(url: url)
        request.cachePolicy = self.cachePolicy
        request.httpMethod = method.rawValue

        for (key, value) in self.headers {
            request.addValue(value, forHTTPHeaderField: key)
        }
        
        switch self.encoding {
            case .none:
                break
                
            case .json(let encoder):
                
                guard let body = self.body as? Encodable else { fatalError("Unable to cast body as Encodable") }
                
                let wrapper = EncodableWrapper(body)
                let encoder = encoder ?? JSONEncoder().configured({ (encoder: JSONEncoder) in
                    encoder.dateEncodingStrategy = .iso8601
                })
                guard let data = try? encoder.encode(wrapper) else { fatalError("Unable to encode body \(body)") }
                
                request.httpBody = data
                request.addValue(self.encoding.contentType, forHTTPHeaderField: "Content-Type")
                
            case .urlEncoded:
                
                guard let body = self.body as? [String: String] else { fatalError("Unable to cast body as [String: String]") }
                
                if body.count == 0 { break }
                let arrayDictionary = Array(body)
                let data = NSMutableData(data: "\(arrayDictionary.first!.key)=\(arrayDictionary.first!.value)".data(using: .utf8)!)
                if arrayDictionary.count > 1 {
                    for dict in arrayDictionary.dropFirst() {
                        data.append("&\(dict.key)=\(dict.value)".data(using: .utf8)!)
                    }
                }
                
                request.httpBody = data as Data
                request.addValue(self.encoding.contentType, forHTTPHeaderField: "Content-Type")
                
            case .multipartFormData:
                
                guard let body = self.body as? [FormData] else { fatalError("Unable to cast body as [FormData]") }
                
                let boundary = self.generateBoundaryString()
                let content = NSMutableData()
                
                for data in body {
                    switch data {
                        case .text(let key, let value):
                            var headers = "--\(boundary)\r\n"
                            headers += "Content-Disposition: form-data; name=\"\(key)\"\r\n"
                            headers += "\r\n"
                            headers += "\(value)\r\n"
                            guard let data = headers.data(using: .utf8) else { fatalError("Unable to encode \(key) as Data") }
                            content.append(data)
                        case .data(let key,let fileName, let contentType, let value):
                            var headers = "--\(boundary)\r\n"
                            headers += "Content-Disposition:form-data; name=\"\(key)\"; filename=\"\(fileName)\"\r\n"
                            headers += "Content-Type: \(contentType)\r\n"
                            headers += "\r\n"
                            guard let data = headers.data(using: .utf8) else { fatalError("Unable to encode headers for \(key) as Data") }
                            content.append(data)
                            content.append(value)
                            guard let crlf = "\r\n".data(using: .utf8) else { fatalError("Unable to encode CRLF for \(key) as Data") }
                            content.append(crlf)
                    }
                }
                guard let end = "--\(boundary)--\r\n".data(using:.utf8) else { fatalError("Unable to encode end for Form Data") }
                content.append(end)
                
                request.httpBody = content as Data
                request.addValue("\(self.encoding.contentType); boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            
            case .data:
                
                guard let body = self.body as? Data else { fatalError("Unable to cast body as Data") }
                request.httpBody = body
                request.addValue(self.encoding.contentType, forHTTPHeaderField: "Content-Type")
            
            case .text:
                
                guard let body = self.body as? String else { fatalError("Unable to cast body as String") }
                request.httpBody = body.data(using: .utf8, allowLossyConversion: false)
                request.addValue(self.encoding.contentType, forHTTPHeaderField: "Content-Type")
        }
        
        if let modifier = self.requestModifer {
            modifier(&request)
        }
        
        return request
    }

}

extension Endpoint {
    
    private func generateBoundaryString() -> String {
        return "Boundary-\(NSUUID().uuidString)"
    }
    
}
