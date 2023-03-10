//
//  PickupPointRow.swift
//  Map
//
//  Created by Duy Tran on 25/02/2023.
//

import SwiftUI
import Kingfisher

struct PickupPointRow: View {
    // MARK: States

    let point: PickupPoint

    @State var isSelected: Bool = false

    @State var isOpeningHourExpanded: Bool = false

    @Binding var selected: PickupPoint.ID?

    // MARK: View

    var body: some View {
        HStack(alignment: .top) {
            Toggle("", isOn: $isSelected)
                .toggleStyle(VCCheckboxToggleStyle())
                .foregroundColor(.black)
            VStack(alignment: .leading) {
                KFImage(point.carrier?.iconURL)
                    .resizable()
                    .frame(width: 24, height: 24)
                point.carrier?.name.map { Text($0).fontWeight(.bold) }
                point.name.map { Text($0) }
                point.address.map { Text($0) }
                distanceAndOpeningHour
            }
        }
        .onAppear {
            invalidateIsSelected(selected)
        }
        .onChange(of: selected) { newValue in
            invalidateIsSelected(newValue)
        }
    }

    @ViewBuilder
    var distanceAndOpeningHour: some View {
        let result = DisclosureGroup(isExpanded: $isOpeningHourExpanded) {
            OpeningHours(openingHourPerWeekday: openingHourPerWeekday)
        } label: {
            Group {
                Text(point.distance?.formatted ?? "Not determined")
                Text("-")
                Text(isOpeningHourExpanded ? "Hide working hours" : "Show working hours")
                    .underline()
            }
            .onTapGesture {
                isOpeningHourExpanded.toggle()
            }
        }

        if #available(iOS 15.0, *) {
            result.tint(.black)
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
        List([PickupPoint.Preview.applePark, PickupPoint.Preview.theDukeOfEdinburgh]) { (point) in
            PickupPointRow(
                point: point,
                selected: .constant(PickupPoint.Preview.applePark.id)
            )
        }
    }
}
