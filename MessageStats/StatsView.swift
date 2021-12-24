//
//  StatsView.swift
//  MessageStats
//
//  Created by Liam Rosenfeld on 12/23/21.
//

import SwiftUI

struct StatsView: View {
    let database: MessageDatabase
    
    @State private var pieData: [String: Int] = [:]
    @State private var contact: Contact?
    @State private var includes = ""
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Data")
                .font(.title2)
            PieView(data: pieData)
                .frame(maxWidth: 300, maxHeight: 300)
            
            Text("Filters")
                .font(.title2)
            Text("Thread With:")
                .font(.title3)
            if let contact = contact {
                HStack {
                    ContactView(contact: contact)
                    Button {
                        self.contact = nil
                    } label: {
                        Image(systemName: "minus")
                    }
                }
                
            } else {
                ContactPickerView(contact: $contact)
                    .frame(width: 100)
            }
            
            Text("Includes:")
                .font(.title3)
            TextField("Includes", text: $includes)
            
            Button("Filter", action: loadData)
        }
        .onAppear(perform: loadData)
    }
    
    func loadData() {
        do {
            let (me, notMe) = try database.messageCount(contact: contact, includes: includes)
            pieData = ["Me": me, "Not Me": notMe].filter { (_, val) in val != 0 }
        } catch let err {
            print(err)
        }
    }
}
