//
//  Contacts.swift
//  MessageStats
//
//  Created by Liam Rosenfeld on 12/15/21.
//

import Contacts
import ContactsUI
import SwiftUI
import AppKit

struct Contact {
    var name: String?
    var phones: [String]
    var emails: [String]
    var photo: NSImage?
}

extension Contact: Equatable { }

struct ContactView: View {
    var contact: Contact
    let contactFormatter = CNContactFormatter()
    
    var body: some View {
        HStack {
            if let image = contact.photo {
                Image(nsImage: image)
                    .resizable()
                    .frame(width: 50, height: 50)
                    .cornerRadius(25)
                    .padding(.trailing, 5)
            }
            VStack(alignment: .leading) {
                Text(contact.name ?? "Could Not Get Name")
                    .font(.body.bold())
                ForEach(contact.phones, id: \.self) { phone in
                    Text(phone)
                }
                ForEach(contact.emails, id: \.self) { email in
                    Text(email)
                }
            }
        }
        .padding()
        .background(Color(NSColor.alternatingContentBackgroundColors[1]))
        .cornerRadius(10)
    }
}

struct ContactPickerView: NSViewRepresentable {
    @Binding var contact: Contact?
    
    let button = NSButton()
    let popover = CNContactPicker()
    
    func makeNSView(context: Context) -> some NSView {
        button.title = "Pick Contact"
        button.bezelStyle = .rounded
        button.action = #selector(context.coordinator.buttonPressed)
        button.target = context.coordinator
        popover.delegate = context.coordinator
        return button
    }
    
    func updateNSView(_ nsView: NSViewType, context: Context) { }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, CNContactPickerDelegate {
        let parent: ContactPickerView
        
        init(_ parent: ContactPickerView) {
            self.parent = parent
        }
        
        func contactPicker(_ picker: CNContactPicker, didSelect contact: CNContact) {
            let name = CNContactFormatter().string(from: contact)
            let phones = contact.phoneNumbers.map { $0.value.normalizedString }
            let emails = contact.emailAddresses.map { String($0.value) }
            let photo = contact.getThumbnailImage()
            parent.contact = Contact(name: name, phones: phones, emails: emails, photo: photo)
            parent.popover.close()
        }
        
        @objc func buttonPressed() {
            parent.popover.showRelative(to: parent.button.bounds, of: parent.button, preferredEdge: .maxX)
        }
    }
}

extension CNPhoneNumber {
    /// Format of +1XXXYYYZZZZ
    var normalizedString: String {
        if !stringValue.contains("(") {
            return stringValue
        }
        let newVal = stringValue
            .replacingOccurrences(of: "(", with: "")
            .replacingOccurrences(of: ")", with: "")
            .replacingOccurrences(of: "-", with: "")
            .replacingOccurrences(of: " ", with: "")
        if stringValue.contains("+") {
            return newVal
        } else {
            return "+1\(newVal)"
        }
    }
}

extension CNContact {
    func getThumbnailImage() -> NSImage? {
        var photo: NSImage? = nil
        let keys = [CNContactThumbnailImageDataKey as CNKeyDescriptor]
        let request = CNContactFetchRequest(keysToFetch: keys)
        request.predicate = NSPredicate(format: "identifier = %@", self.identifier)
        let store = CNContactStore()
        do {
            try store.enumerateContacts(with: request) { contact, _ in
                if let imageData = contact.thumbnailImageData, let contactImage = NSImage(data: imageData) {
                    photo = contactImage
                }
            }
        } catch let err {
            print(err)
        }
        return photo
    }
}
