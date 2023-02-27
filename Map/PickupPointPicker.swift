//
//  PickupPointsPicker.swift
//  Map
//
//  Created by Duy Tran on 24/01/2023.
//

import SwiftUI
import MapKit

/// A view that lets users pick an available pickup poitn from a map or from a list.
struct PickupPointPicker: View {
    // MARK: States

    @ObservedObject var viewModel = PickupPointPickerViewModel()

    /// An action that dismisses the current presentation
    @Environment(\.dismiss) var dismiss

    // MARK: View

    var body: some View {
        List(selection: $viewModel.selected) {
            Section {
                listContent
            } header: {
                map
            }
        }
        .listStyle(.plain)
        .navigationTitle("Choose a pick-up point")
        .searchable(text: $viewModel.keywords, prompt: "Address")
        .onSubmit(of: .search) {
            viewModel.didSubmitSearch()
        }
    }

    var map: some View {
        PickupPointMap(
            referencePoint: viewModel.referencePoint,
            points: viewModel.points,
            selected: $viewModel.selected
        )
        .scaledToFill()
        .listRowInsets(EdgeInsets())
    }

    var listContent: some View {
        PickupPointListContent(
            points: viewModel.points,
            selected: $viewModel.selected
        )
    }
}

struct ContentView_Previews: PreviewProvider {
    private static var viewModel: PickupPointPickerViewModel {
        let result = PickupPointPickerViewModel()
        result.keywords = "Apple Park"
        result.referencePoint = .Preview.applePark
        result.selected = .Preview.theDukeOfEdinburgh
        result.state = .loaded([.Preview.theDukeOfEdinburgh, .Preview.wolfeLiquor])
        return result
    }

    static var previews: some View {
        NavigationStack {
            PickupPointPicker(viewModel: viewModel)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
