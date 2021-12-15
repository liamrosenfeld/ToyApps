//
//  PlaylistGenerator.swift
//  SentenceToPlaylist
//
//  Created by Liam Rosenfeld on 12/15/21.
//

import MusicKit

enum PlaylistGenerator {
    static func generate(for sentence: String) async -> [Song] {
        let words = sentence.split(separator: " ")
        var songs: [Song] = []
        
        let maxWords = 4
        var start = 0
        var end = min(maxWords, words.count)
       
        // tries to find songs that contain multiple words in a row
        while true {
            let fragment = words[start..<end].joined(separator: " ")
            if let song = await songWithTitle(fragment) {
                songs.append(song)
                
                // if that contained the last word, break
                if end == words.count { break }
                
                // move the start to the end and the end to the next segment
                start = end
                end = min(end + maxWords, words.count)
            } else {
                // decrease the fragment by one word
                end -= 1
                
                // if there are no words left in the fragment, skip the first word
                if start == end {
                    print("no song for \(fragment)")
                    start += 1
                    end = min(start + maxWords, words.count)
                    
                    // if last word also leave the loop
                    if start == words.count { break }
                }
            }
        }
        return songs
    }
    
    static func songWithTitle(_ title: String) async -> Song? {
        let search = MusicCatalogSearchRequest(term: String(title), types: [Song.Type]())
        do {
            let result = try await search.response()
            for song in result.songs {
                let editedSongTitle = song.title.lowercased()
                    .replacingOccurrences(of: "\\s?\\([\\w\\s.]*\\)", with: "", options: .regularExpression) // remove parenthesis (for featuring)
                    .replacingOccurrences(of: "[ \t]+$", with: "", options: .regularExpression) // remove trailing whitespace
                if editedSongTitle == title.lowercased() {
                    return song
                }
            }
        } catch let error {
            print(error)
        }
        return nil
    }
}
