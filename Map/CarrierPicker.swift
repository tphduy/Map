//
//  PickupPointsPicker.swift
//  Map
//
//  Created by Duy Tran on 24/01/2023.
//

import SwiftUI
import MapKit

/// A view that lets user pick an available pickup poitns on map or from a list.
struct CarrierPicker: View {
    // MARK: States

    @State var referencePoint: PickupPoint?

    @State var points: [PickupPoint] = []

    @State var selectedIndexes: [Int] = []

    @State var keywords = ""

    /// An action that dismisses the current presentation
    @Environment(\.dismiss) var dismiss

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
        .searchable(text: $keywords)
        .tint(.black)
        .navigationTitle("Choose a pick-up point")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            closeToolbarItem
        }
    }

    var closeToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Button(action: dismiss.callAsFunction) {
                Label("", systemImage: "xmark")
            }
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
        ForEach(points + points + points + points) { (deliveryHubs: PickupPoint) in
            deliveryHubs.carrier?.name.map { Text($0) }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            CarrierPicker(
                referencePoint: .Preview.applePark,
                points: [
                    .Preview.theDukeOfEdinburgh,
                    .Preview.wolfeLiquor
                ]
            )
        }
    }
}
