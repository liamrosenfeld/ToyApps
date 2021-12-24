//
//  ContentView.swift
//  MessageStats
//
//  Created by Liam Rosenfeld on 12/15/21.
//

import SwiftUI

struct ContentView: View {
    
    @State private var database: MessageDatabase?
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Message Stats")
                .font(.title)
                .padding([.bottom], 10)
            
            if let database = database {
                StatsView(database: database)
            } else {
                Button("Open Messages Database") {
                    database = MessageDatabase()
                }
            }
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
