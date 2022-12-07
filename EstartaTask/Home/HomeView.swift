//
//  HomeView.swift
//  EstartaTask
//
//  Created by Muhammad AbdelaRahman on 06/12/2022.
//

import SwiftUI

struct HomeView: View {
	
	@ObservedObject var viewModel: HomeViewModel
	@State private var showingAlert = false
	private let loadMore = 1
	
	var body: some View {
		
		content
			.onAppear(perform: {
				viewModel.getList()
			})
		
	}
	
	private var content: AnyView {
		switch viewModel.estarListResponse {
		case .notRequested:
			return AnyView(Text(""))
		case .loaded:
			let response = viewModel.estarListResponse.response
			return displayList(response: response)
		case let .fail(msg, lastResponse):
			return AnyView(
				displayList(response: lastResponse)
					.onAppear(perform: {
						showingAlert = true
					})
					.alert("\(msg)", isPresented: $showingAlert) {
						Button("OK", role: .cancel) {
							showingAlert = false
						}
					}
			)
		case let .isLoading(lastResponse):
			return AnyView(
				ZStack {
					displayList(response: lastResponse)
					ProgressView()
						.scaleEffect(2, anchor: .center)
				}
			)
		}
	}
	
	func displayList(response: Any?) -> AnyView {
		
		guard let response = response else {
			return emptyView()
		}
		
		let elements: [EstarModel.Result] =
		(response as? EstarModel.Response)?.results ?? []
		
		return AnyView(
			NavigationView {
				List {
					ForEach(elements) { element in
						
						ElementCard(element: element)
							.listRowSeparator(.hidden)
							.listRowInsets(EdgeInsets(top: 8, leading: 8,
													  bottom: 8, trailing: 8))
							
							.background {
								NavigationLink("", destination: DetailView(element: element))
									
							}
							.listRowBackground(Color.white)
					}
				}
				.navigationBarTitle("Home", displayMode: .inline)
				.listStyle(PlainListStyle())
				.onAppear {
					UITableView.appearance().showsVerticalScrollIndicator = false
				}
			}
		)
		
		
	}
	
	func emptyView() -> AnyView {
		AnyView(
			VStack(alignment: .center, spacing: 40.0) {
				Image("emptyHome")
				Text("This is where your “List” will be show!")
					.multilineTextAlignment(.center)
					.padding(.horizontal, 48.0)
			}
		)
	}
	
	
}


struct ElementCard: View {
	
	var element: EstarModel.Result
	
	var body: some View {
		
		HStack{
			VStack(alignment: .leading, spacing: 12.0) {
				Text("ID: \(element.id)")
				Text("Name: \(element.name)")
			}
			Spacer()
		}
		.padding(.horizontal, 8.0)
		.padding(.vertical, 16.0)
		.background(Color.white)
		.cornerRadius(12)
		.shadow(color: Color.black.opacity(0.5), radius: 2, x: 0, y: 1)
	}
	
}




struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
		let viewModel = HomeViewModel()
		let response = EstarModel.Response()
		viewModel.estarListResponse = ResponseStatus<EstarModel.Response>.loaded(response: response)
		//return ElementCard(element: response.results.last!)
		return HomeView(viewModel: viewModel)
		
		
		
	}
}
