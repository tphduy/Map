//
//  SearchBar.swift
//  Map
//
//  Created by Duy Tran on 07/03/2023.
//

import SwiftUI

struct SearchBar: View {

    @Binding var text: String

    @State var isEditing: Bool = false

    let title: LocalizedStringKey

    init(
        _ title: LocalizedStringKey = "Search",
        text: Binding<String>
    ) {
        self.title = title
        self._text = text
    }

    // MARK: View

    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")

            TextField(title, text: $text) { (isEditing) in
                self.isEditing = isEditing
            }

            if isEditing || !text.isEmpty {
                Button(action: clear) {
                    Image(systemName: "xmark.circle.fill")
                }
            }
        }
        .padding(EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12))
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }

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
