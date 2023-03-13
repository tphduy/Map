//
//  SearchBar.swift
//  Map
//
//  Created by Duy Tran on 07/03/2023.
//

import SwiftUI

/// A specialized view for receiving search-related information from the user.
struct SearchBar: View {

    /// The text to display and edit in the search field.
    @Binding var text: String

    /// The key for the localized title of the text field, describing its purpose.
    ///
    /// The default value is `Search`.
    @State var title: LocalizedStringKey = "Search"

    /// A flag that indicates the user is editing the search field.
    @State var isEditing: Bool = false

    // MARK: View

    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")

            TextField(title, text: $text) { (isEditing) in
                self.isEditing = isEditing
            }

            if isEditing || !text.isEmpty {
                clearButton
            }
        }
        .padding(EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12))
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }

    /// A button that lets the user clear all of the text in a text field.
    var clearButton: some View {
        Button(action: clear) {
            Image(systemName: "xmark.circle.fill")
        }
    }

    // MARK: State Changes

    /// Clears all of the text in a text field.
    func clear() {
        text = ""
    }
}

struct SearchBar_Previews: PreviewProvider {
    static var previews: some View {
        SearchBar(text: .constant("Foo"))
            .foregroundColor(.gray)
    }
}
