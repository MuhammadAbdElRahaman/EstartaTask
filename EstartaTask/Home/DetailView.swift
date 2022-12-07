//
//  DetailView.swift
//  EstartaTask
//
//  Created by Muhammad AbdelaRahman on 06/12/2022.
//

import SwiftUI

struct DetailView: View {
	
	var element: EstarModel.Result
	
	var body: some View {
		
		VStack{
			
			HStack{
				VStack(alignment: .leading, spacing: 12.0) {
					Text("Name: \(element.name)")
					Text("Price: \(element.price)")
					Text("created at: \(element.createdAt)")
					
					
				}
				Spacer()
			}
			.padding(.horizontal, 16.0)
			.padding(.vertical, 24.0)
			.background(Color.white)
			.cornerRadius(12)
			.shadow(color: Color.black.opacity(0.5), radius: 2, x: 0, y: 1)
			
			Spacer()
			
		}
		
		.padding(.all, 16)
	}
	
	
	
	
}






struct DetailView_Previews: PreviewProvider {
	static var previews: some View {
		let response = EstarModel.Response()
		return DetailView(element: response.results.first!)
	}
}

