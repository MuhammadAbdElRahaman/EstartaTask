

import Foundation
import Combine



class HomeViewModel: ObservableObject {
	
	@Published var estarListResponse = ResponseStatus<EstarModel.Response>.notRequested
	private var estaerSubscription: AnyCancellable!
	private let pageSize = 5
	private let caller: APICallerLogic = APICaller()
		
	func getList() {
		
		let request = EstarModel.Request()
		
		estaerSubscription = caller.makeRequest(request)
			.sink { [weak self] complete in
				switch complete {
				case .finished:
					self?.estaerSubscription.cancel()
				case .failure(let exception):
					self?.estarListResponse.didfail(exception: exception)
				}
			} receiveValue: { [weak self] response in
				self?.estarListResponse.didLoaded(response: response)
			}
	}
	
}
