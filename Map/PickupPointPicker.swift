//
//  PickupPointsPicker.swift
//  Map
//
//  Created by Duy Tran on 24/01/2023.
//

import SwiftUI
import MapKit

/// A view that lets user pick an available pickup poitns on map or from a list.
struct PickupPointPicker: View {
    // MARK: States

    @State var referencePoint: PickupPoint?

    @State var points: [PickupPoint] = []

    @State var selectedIndexes: [Int] = []

    @State var keywords = ""

    /// An action that dismisses the current presentation
    @Environment(\.dismiss) var dismiss

    @Environment(\.dismissSearch)
    private var dismissSearch

    // MARK: View

    var body: some View {
        List {
            Section {
                list
            } header: {
                map
            }
        }
        .listStyle(.plain)
        .navigationTitle("Choose a pick-up point")
        .searchable(text: $keywords, prompt: "Address")
        .onSubmit(of: .search) {
            dismissSearch()
        }
    }

    var map: some View {
        PickupPointMap(
            referencePoint: referencePoint,
            points: points,
            selectedIndexes: $selectedIndexes
        )
        .listRowInsets(EdgeInsets())
        .scaledToFill()
    }

    var list: some View {
        ForEach(points) { (deliveryHubs: PickupPoint) in
            deliveryHubs.carrier?.name.map {
                Text([$0, $0, $0, $0, $0, $0, $0, $0, $0].joined(separator: "\n"))
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            PickupPointPicker(
                referencePoint: .Preview.applePark,
                points: [
                    .Preview.theDukeOfEdinburgh,
                    .Preview.wolfeLiquor
                ],
                selectedIndexes: [1]
            )
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
