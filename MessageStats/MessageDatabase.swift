//
//  MessageDatabase.swift
//  MessageStats
//
//  Created by Liam Rosenfeld on 12/19/21.
//

import Foundation
import SQLite
import AppKit

// NOTE:
// Currently requires copying chat.db into downloads folder
// and then accessing it using sqlite3 and running `PRAGMA journal_mode=DELETE`

struct MessageDatabase {
    let db: Connection
    
    static private func getDatabasePath() -> String? {
        // create panel
        let dialog = NSOpenPanel();
        dialog.title                   = "Open chat.db";
        dialog.allowsMultipleSelection = false;
        dialog.canChooseDirectories = false;
        
        // pre select the file we want to open
//        let path = String(NSString("~/Library/Messages/chat.db").expandingTildeInPath)
        let path = String(NSString("~/Downloads/chat.sqlite3").expandingTildeInPath)
        dialog.directoryURL = NSURL.fileURL(withPath: path)
    
        // present and get panel
        if (dialog.runModal() == .OK) {
            return dialog.url?.path
        } else {
            return nil
        }
    }
    
    init?() {
        guard let path = Self.getDatabasePath() else { return nil }
        print(path)
        guard let conn = try? Connection(path, readonly: true) else { return nil }
        db = conn
    }
    
    private func chatAndMessageTable() -> Table {
        let chatMessageJoin = Table("chat_message_join")
        
        let chat = Table("chat")
        let message = Table("message")
        
        let rowID = Expression<String>("ROWID")
        let chatID = Expression<String>("chat_id")
        let messageID = Expression<String>("message_id")
        
        return chatMessageJoin
            .join(chat, on: chatID == chat[rowID])
            .join(message, on: messageID == message[rowID])
    }
    
    func messageCount() throws -> (me: Int, notMe: Int) {
        let messages = Table("message")
        let fromMe = Expression<Bool>("is_from_me")
        let me = try db.scalar(messages.filter(fromMe).count)
        let notMe = try db.scalar(messages.filter(!fromMe).count)
        return (me, notMe)
    }

    func messageCount(contact: Contact?, includes: String) throws -> (me: Int, notMe: Int) {
        var messages = chatAndMessageTable()
        
        // filter to contact
        if let contact = contact {
            let chatID = Expression<String>("chat_identifier")
            messages = messages.filter(contact.phones.contains(chatID) || contact.emails.contains(chatID))
        }
        
        // filter to regex
        if !includes.isEmpty {
            let text = Expression<String>("text")
            messages = messages.filter(text.like("%\(includes)%"))
        }
        
        // filter to from
        let fromMe = Expression<Bool>("is_from_me")
        let me = try db.scalar(messages.filter(fromMe).count)
        let notMe = try db.scalar(messages.filter(!fromMe).count)
        
        return (me, notMe)
    }
}
