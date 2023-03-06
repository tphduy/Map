//
//  OpeningHours.swift
//  Map
//
//  Created by Duy Tran on 02/03/2023.
//

import SwiftUI

struct OpeningHours: View {
    // MARK: States

    /// A list those element is a tuple of a weekday and the description.
    ///
    /// Because opening hourse respect the order of the element so we can't use a dictionary.
    @State var openingHourPerWeekday = [(weekday: String, description: String)]()

    // MARK: View

    var body: some View {
        VStack {
            ForEach(openingHourPerWeekday, id: \.weekday) { (weekday, description) in
                HStack {
                    Text(weekday)
                    Spacer()
                    Text(description)
                }
            }
        }
    }
}

struct OpeningHours_Previews: PreviewProvider {
    static var previews: some View {
        OpeningHours(openingHourPerWeekday: [
            ("Monday", "08:00-11:30 14:00-19:00"),
            ("Friday", "08:00-11:30 14:00-19:00"),
            ("Sunday", "08:00-11:30 14:00-19:00"),
            ("Tuesday", "08:00-11:30 14:00-19:00"),
            ("Thursday", "08:00-11:30 14:00-19:00"),
            ("Wednesday", "08:00-11:30 14:00-19:00"),
            ("Saturday", "08:00-11:30 14:00-19:00"),
        ])
    }
}
