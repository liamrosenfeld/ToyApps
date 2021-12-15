//
//  ContentView.swift
//  PlaylistGenerator
//
//  Created by Liam Rosenfeld on 11/30/21.
//

import SwiftUI
import MusicKit

struct ContentView: View {
    @State private var sentence = ""
    @State private var songs: [Song] = []
    @State private var generating = false
    @State private var generateTask: Task<Void, Never>?
    
    var body: some View {
        VStack {
            Text("Sentence to Playlist")
                .font(.title)
            TextField("Sentence", text: $sentence)
                .onSubmit(generate)
            
            HStack {
                Button("Generate", action: generate)
                    .disabled(generating)
                
                if generating {
                    Button("Cancel", action: cancel)
                }
            }
            
            Divider()
            if generating {
                ProgressView()
                Text("Generating...")
            } else {
                List(songs) { song in
                    SongView(song: song)
                        .frame(maxWidth: .infinity)
                }.frame(maxWidth: .infinity)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .task {
            await setupMusic()
        }
    }
    
    func generate() {
        generateTask = Task(priority: .userInitiated) {
            songs.removeAll()
            generating = true
            songs = await PlaylistGenerator.generate(for: sentence)
            generating = false
        }
    }
    
    func cancel() {
        generateTask?.cancel()
        songs.removeAll()
        generating = false
    }
    
    func setupMusic() async {
        let auth = await MusicAuthorization.request()
        print(auth)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
