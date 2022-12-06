//
//  NetworkModel.swift
//
//  Created by Muhammad AbdelaRahman on 08/02/2021.
//  Copyright © 2021 WMCairo. All rights reserved.
//

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



