//
//  SongView.swift
//  SentenceToPlaylist
//
//  Created by Liam Rosenfeld on 12/15/21.
//

import SwiftUI
import MusicKit

struct SongView: View {
    @State var song: Song
    
    var body: some View {
        HStack {
            Group {
                if let artwork = song.artwork {
                    ArtworkImage(artwork, width: 50, height: 50)
                        .frame(width: 50, height: 50)
                        .cornerRadius(10)
                } else {
                    Rectangle()
                        .fill(Color.black)
                        .frame(width: 50, height: 50)
                        .cornerRadius(10)
                }
            }
            VStack(alignment: .leading) {
                Text(song.title)
                    .font(.headline)
                Text(song.artistName)
            }
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(NSColor.alternatingContentBackgroundColors[1]))
        .cornerRadius(10)
    }
}
