

import Foundation

public protocol APIRequest {
	var serviceName: String {get}
	var method: HTTPMethod {get}
}

public extension APIRequest {
	var method: HTTPMethod {HTTPMethod.get}
}

public struct ErrorResponse: Codable {
	let message: String?
	let errorMessage: String?
	var msg: String {
		return message ?? errorMessage ?? "unexpectedServerResponse"
	}
	enum CodingKeys: String, CodingKey {
		case message, errorMessage
	}
}

public struct APIException: Error {
	public let userNotVerifiedLoginAPI = 307
	public var request: URLRequest?
	public var url: String
	public var msg: String
	public var code: Int?
	public var kind: APIException.Kind!
	public var error: Error?
	public var json: [String: Any]?
	
	public init(url: String, msg: String) {
		self.init(url: url, error: nil, code: nil, msg: msg, request: nil, data: nil)
	}
	
	public init() {
		self.init(url: "", error: nil, code: nil, msg: "", request: nil, data: nil)
		print(self.url)
	}
	
	public init(url: String, error: Error?, code: Int?, msg: String,
				request: URLRequest?, data: Data?) {
		
		self.code = code
		self.msg = msg
		self.error = error
		self.url = url
		self.request = request
		if let data = data {
			self.json =
			try? JSONSerialization.jsonObject(with: data, options: []) as? Dictionary<String,Any>
		}
		logException()
	}
	
	func logException() {
#if DEBUG
		print("⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️")
		print("request: \(String(describing: request))")
		print("👓👓👓👓👓👓👓👓👓👓")
		print("with url: \(url)")
		print("👓👓👓👓👓👓👓👓👓👓")
		print("get error: \(String(describing: error))")
		print("👓👓👓👓👓👓👓👓👓👓")
		print("with status code: \(String(describing: code))")
		print("👓👓👓👓👓👓👓👓👓👓")
		print("with massege: \(msg)")
		print("👓👓👓👓👓👓👓👓👓👓")
		print("with json: \(String(describing: json))")
		print("⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️")
#endif
	}
	
	public enum Kind {
		
		case CONNECTION // internet errors
		case HTTP // server error
		case SERVERCRASH
		case UNEXPECTED
		
	}
}



enum ResponseStatus<R: Codable> {
	
	case notRequested
	case isLoading(lastResponse: R?)
	case loaded(response: R)
	case fail(msg: String, lastResponse: R?)
	
	
	mutating func loading() {
		switch self {
		case .notRequested:
			self = .isLoading(lastResponse: nil)
		case .fail (_, let lastResponse):
			self = .isLoading(lastResponse: lastResponse)
		case .isLoading(let lastResponse):
			self = .isLoading(lastResponse: lastResponse)
		case .loaded(let lastResponse):
			self = .isLoading(lastResponse: lastResponse)
		}
	}
	
	mutating func didLoaded(response: R) {
		self = .loaded(response: response)
	}
	
	mutating func didfail(exception: APIException) {
		switch self {
		case .notRequested:
			self = .fail(msg: exception.msg, lastResponse: nil)
		case .fail (_, let lastResponse):
			self = .fail(msg: exception.msg, lastResponse: lastResponse)
		case .isLoading(let lastResponse):
			self = .fail(msg: exception.msg, lastResponse: lastResponse)
		case .loaded(let lastResponse):
			self = .fail(msg: exception.msg, lastResponse: lastResponse)
		}
	}
	
	var response: R? {
		switch self {
		case .notRequested:
			return nil
		case .fail(_, let lastResponse):
			return lastResponse
		case .isLoading(let lastResponse):
			return lastResponse
		case .loaded(let lastResponse):
			return lastResponse
		}
	}
	
}
