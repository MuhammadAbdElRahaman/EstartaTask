//
//  APICaller.swift
//
//  Created by Muhammad AbdelaRahman on 08/02/2021.
//  Copyright © 2021 WMCairo. All rights reserved.
//

import Foundation
import Combine

public protocol APICallerLogic {
	func makeRequest<R: Codable>(_ request: APIRequest) -> AnyPublisher<R, APIException>
}

public class APICaller: APICallerLogic {
	
	private var session: URLSession
	private var config: URLSessionConfiguration
	private var subscriptions = Set<AnyCancellable>()
	
	public init() {
		config = URLSessionConfiguration.default
		config.timeoutIntervalForRequest = 60
		session = URLSession.init(configuration: config)
	}
	
	
	public func makeRequest<R: Codable>(_ request: APIRequest) -> AnyPublisher<R, APIException> {
		
		return Future { [weak self] promise in
			
			guard let self = self else {
				let exception = APIException()
				promise(.failure(exception))
				return
				
			}
			guard let urlRequest = URLRequestBuilder(request) else {
				let exception = self.handelingNonSuccessRequest(url: request.serviceName,
																msg: "invalidUrl")
				promise(.failure(exception))
				return
			}
			self.session
				.dataTaskPublisher(for: urlRequest.request)
				.sink { complete in
					if case .failure(let error) = complete {
						let exception = self.handelingNonSuccessRequest(url: urlRequest.request.url!.absoluteString,
																		msg: error.localizedDescription,
																		error: error,
																		request: urlRequest.request)
						promise(.failure(exception))
						
					}
				} receiveValue: { (data: Data, response: URLResponse) in
					do {
						if let statusCode = (response as? HTTPURLResponse)?.statusCode {
							let jsonDecoder = JSONDecoder()
							if 200...299 ~= statusCode {
								print("response of ====>>>> \(request.serviceName)")
								self.printResponseJson(data, type: R.self)
								let result = try jsonDecoder.decode(R.self, from: data)
								promise(.success(result))
								
							} else {
								
								let errorResponse = try jsonDecoder.decode(ErrorResponse.self, from: data)
								
								let exception =
								self.handelingNonSuccessRequest(url: urlRequest.request.url!.absoluteString,
																msg: errorResponse.msg,
																statusCode: statusCode,
																request: urlRequest.request, data: data)
								
								promise(.failure(exception))
								
							}
							
						}
						
					} catch {
						let exception =
						self.handelingNonSuccessRequest(url: urlRequest.request.url!.absoluteString,
														msg: "unexpectedServerResponse",
														statusCode: -1, error: error,
														request: urlRequest.request)
						promise(.failure(exception))
					}
					
					
					
					
				}
				.store(in: &self.subscriptions)
		}.receive(on: DispatchQueue.main).eraseToAnyPublisher()
	}

	
	
	private func handelingNonSuccessRequest(url: String, msg: String, statusCode: Int? = nil,
											error: Error? = nil, request: URLRequest? = nil,
											data: Data? = nil) -> APIException {
		
		var exception = APIException(url: url, error: error,
									 code: statusCode, msg: msg, request: request, data: data)
		
		if  let statusCode = statusCode {
			switch statusCode {
			case -1:
				exception.kind = APIException.Kind.UNEXPECTED
			case 300 ... 499:
				exception.kind = APIException.Kind.HTTP
			default:
				exception.msg = "serverCrash"
				exception.kind = APIException.Kind.SERVERCRASH
			}
		} else {
			exception.kind = APIException.Kind.CONNECTION
		}
		if exception.msg.trimmingWhiteSpace().isEmpty || exception.code == 403 {
			exception.msg = "unknownError"
		}
		return exception
		
	}
	
	
	private func printResponseJson<T: Codable>(_ data: Data, type: T.Type) {
#if DEBUG
		if let object = try? JSONSerialization.jsonObject(with: data,
														  options: []) as? Dictionary<String,Any> ,
		   let data = try? JSONSerialization.data(withJSONObject: object,
												  options: [.prettyPrinted]),
		   let prettyPrintedString = NSString(data: data,
											  encoding: String.Encoding.utf8.rawValue) {
			debugPrint("🤞🏽🤞🏽🤞🏽🤞🏽🤞🏽🤞🏽🤞🏽🤞🏽🤞🏽🤞🏽🤞🏽🤞🏽🤞🏽🤞🏽🤞🏽🤞🏽🤞🏽🤞🏽🤞🏽🤞🏽Dictionary")
			debugPrint(prettyPrintedString)
			debugPrint("✴️✴️✴️✴️✴️✴️✴️✴️✴️✴️✴️✴️✴️✴️✴️✴️✴️✴️✴️✴️")
		}
		if let object = try? JSONSerialization.jsonObject(with: data,
														  options: []) as? T ,
		   let data = try? JSONSerialization.data(withJSONObject: object,
												  options: [.prettyPrinted]),
		   let prettyPrintedString = NSString(data: data,
											  encoding: String.Encoding.utf8.rawValue) {
			debugPrint("🤞🏽🤞🏽🤞🏽🤞🏽🤞🏽🤞🏽🤞🏽🤞🏽🤞🏽🤞🏽🤞🏽🤞🏽🤞🏽🤞🏽🤞🏽🤞🏽🤞🏽🤞🏽🤞🏽🤞🏽T")
			debugPrint(prettyPrintedString)
			debugPrint("✴️✴️✴️✴️✴️✴️✴️✴️✴️✴️✴️✴️✴️✴️✴️✴️✴️✴️✴️✴️")
		}
		if let object = try? JSONSerialization.jsonObject(with: data,
														options: []) as? Array<Any> ,
		   let data = try? JSONSerialization.data(withJSONObject: object,
												  options: [.prettyPrinted]),
		   let prettyPrintedString = NSString(data: data,
											  encoding: String.Encoding.utf8.rawValue) {
			debugPrint("🤞🏽🤞🏽🤞🏽🤞🏽🤞🏽🤞🏽🤞🏽🤞🏽🤞🏽🤞🏽🤞🏽🤞🏽🤞🏽🤞🏽🤞🏽🤞🏽🤞🏽🤞🏽🤞🏽🤞🏽Array")
			debugPrint(prettyPrintedString)
			debugPrint("✴️✴️✴️✴️✴️✴️✴️✴️✴️✴️✴️✴️✴️✴️✴️✴️✴️✴️✴️✴️")
		}
#endif
	}
	
}
