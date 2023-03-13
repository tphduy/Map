//
//  PickupPointRow.swift
//  Map
//
//  Created by Duy Tran on 25/02/2023.
//

import SwiftUI
import Kingfisher

/// A view that displays a pickup point as a row in a list.
struct PickupPointRow: View {
    // MARK: States

    /// A prearranged place where you go to collect things.
    let point: PickupPoint

    /// A unique identifier of a pickup point that is selected.
    @Binding var selected: PickupPoint.ID?

    /// A flag indicates whether the current pickup point is selected.
    @State var isSelected: Bool = false

    /// A flag indicates whether the opening hour group is expanded.
    @State var isOpeningHourExpanded: Bool = false

    // MARK: View

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Toggle("", isOn: $isSelected)
                .toggleStyle(VCCheckboxToggleStyle())
                .disabled(true)
            
            VStack(alignment: .leading) {
                KFImage(point.carrier?.iconURL)
                    .resizable()
                    .frame(width: 24, height: 24)
                point.carrier?.name.map { Text($0).fontWeight(.bold) }
                point.name.map { Text($0) }
                point.address.map { Text($0) }
                distanceAndOpeningHour
            }

            Spacer()
        }
        .onAppear {
            invalidateIsSelected(selected)
        }
        .onChange(of: selected) { (newValue) in
            invalidateIsSelected(newValue)
        }
    }

    /// A view that displays the distance from the current pickup point to a reference location and the opening hours.
    ///
    ///  Selection on this view will toggle the opening hour expanded or collapsed.
    ///
    /// Can not use `DisclosureGroup` because it use right chevron instead of down cheveron as design.
    @ViewBuilder var distanceAndOpeningHour: some View {
        HStack {
            Text(point.distance?.formatted ?? "Not determined")
            Text("-")
            Text(isOpeningHourExpanded ? "Hide working hours" : "Show working hours")
                .underline()
            Image(systemName: isOpeningHourExpanded ? "chevron.up" : "chevron.down")
        }
        .onTapGesture {
            isOpeningHourExpanded.toggle()
        }
        if isOpeningHourExpanded {
            OpeningHours(openingHourPerWeekday: openingHourPerWeekday)
        }
    }

    // MARK: State Changes

    /// Determines the value of `isSelected` property with an identifier of a selected pickup point.
    ///
    /// If the current pickup point has the same identifier as the selected, then `isSelected` is true, otherwise `isSelected` is false.
    ///
    /// - Parameter selected: A unique identifier of a selected pickup point.
    func invalidateIsSelected(_ selected: PickupPoint.ID?) {
        isSelected = selected == point.id
    }

    // MARK: Utilities

    /// A list those element is a tuple of a weekday and the description.
    private var openingHourPerWeekday: [(weekday: String, description: String)] {
        [
            ("Monday", point.openingTimes?.monday ?? "Closed"),
            ("Friday", point.openingTimes?.friday ?? "Closed"),
            ("Sunday", point.openingTimes?.sunday ?? "Closed"),
            ("Tuesday", point.openingTimes?.tuesday ?? "Closed"),
            ("Thursday", point.openingTimes?.thursday ?? "Closed"),
            ("Wednesday", point.openingTimes?.wednesday ?? "Closed"),
            ("Saturday", point.openingTimes?.saturday ?? "Closed"),
        ]
    }
}

struct PickupPointRow_Previews: PreviewProvider {
    static var previews: some View {
        List([
            PickupPoint.Preview.applePark,
            PickupPoint.Preview.theDukeOfEdinburgh
        ]) { (point) in
            PickupPointRow(
                point: point,
                selected: .constant(PickupPoint.Preview.applePark.id)
            )
        }
    }
}
