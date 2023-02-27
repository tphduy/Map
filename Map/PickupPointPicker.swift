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

    @StateObject var viewModel = PickupPointPickerViewModel()

    // MARK: View

    var body: some View {
        content
        .listStyle(.plain)
        .navigationTitle("Choose a pick-up point")
        .searchable(text: $viewModel.keywords, prompt: "Address")
        .onSubmit(of: .search) {
            viewModel.didSubmitSearch()
        }
    }

    @ViewBuilder @MainActor
    var content: some View {
        switch viewModel.state {
        case let .failed(error):
            Text(error.localizedDescription)
        case .isLoading:
            ProgressView()
        case .loaded:
            List(selection: $viewModel.selected) {
                Section {
                    listContent
                } header: {
                    map
                }
            }
        }
    }

    var map: some View {
        PickupPointMap(
            points: viewModel.state.data ?? [],
            center: $viewModel.center,
            selected: $viewModel.selected
        )
        .scaledToFill()
        .listRowInsets(EdgeInsets())
    }

    var listContent: some View {
        PickupPointListContent(
            points: viewModel.state.data ?? [],
            selected: $viewModel.selected
        )
    }
}

struct ContentView_Previews: PreviewProvider {

    static var previews: some View {
        NavigationStack {
            PickupPointPicker(viewModel: .preview)
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}
