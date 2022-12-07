
import Foundation

struct URLRequestBuilder {
	
	private(set) var request: URLRequest
	
	init?(_ apiRequest: APIRequest) {
		
		guard let url = URL(string: apiRequest.serviceName) else {
			return nil
		}
		request = URLRequest(url: url)
		request.httpMethod = apiRequest.method.rawValue
		let stringURL = "\(apiRequest.serviceName)"
		request.url = URL(string: stringURL.encodeURL())!
		
		#if DEBUG
		print("✈️✈️✈️✈️✈️✈️✈️✈️✈️✈️✈️✈️✈️✈️✈️✈️✈️✈️")
		print(request.cURL(pretty: true))
		print("⛎⛎⛎⛎⛎⛎⛎⛎⛎⛎⛎⛎⛎⛎⛎⛎⛎⛎⛎")
		#endif
		
	}
	
	
}

public enum HTTPMethod: String {
	case post = "POST"
	case put = "PUT"
	case get = "GET"
}

public extension URLRequest {
	func cURL(pretty: Bool = false) -> String {
		let newLine = pretty ? "\\\n" : ""
		let method = (pretty ? "--request " : "-X ") + "\(String(describing: self.httpMethod)) \(newLine)"
		let url: String = (pretty ? "--url " : "") + "\'\(self.url?.absoluteString ?? "")\' \(newLine)"
		
		var cURL = "curl "
		var header = ""
		var data: String = ""
		
		if let httpHeaders = self.allHTTPHeaderFields, httpHeaders.keys.count > 0 {
			for (key,value) in httpHeaders {
				header += (pretty ? "--header " : "-H ") + "\'\(key): \(value)\' \(newLine)"
			}
		}
		
		if let bodyData = self.httpBody, let bodyString = String(data: bodyData, encoding: .utf8),  !bodyString.isEmpty {
			data = "--data '\(bodyString)'"
		}
		
		cURL += method + url + header + data
		
		return cURL
	}
}

extension String {
	func encodeURL()-> String {
		return self.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
	}
	
	func trimmingWhiteSpace() -> String {
		return self.trimmingCharacters(in: .whitespacesAndNewlines)
	}
}
