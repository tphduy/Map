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
        case .isLoading, .loaded:
            list
        }
    }

    var map: some View {
        PickupPointMap(
            points: viewModel.state.data ?? [],
            center: $viewModel.center,
            selected: $viewModel.selected
        )
        .aspectRatio(193.0 / 123.0, contentMode: .fill)
        .listRowInsets(EdgeInsets())
    }

    var progress: some View {
        HStack {
            Spacer()
            ProgressView()
                .progressViewStyle(.circular)
            Spacer()
        }
        .listRowSeparator(.hidden)
    }

    @ViewBuilder
    var listContent: some View {
        if case.isLoading = viewModel.state { progress }
        PickupPointListContent(
            points: viewModel.state.data ?? [],
            selected: $viewModel.selected
        )
    }

    var list: some View {
        List(selection: $viewModel.selected) {
            Section {
                listContent
            } header: {
                map
            }
        }
    }

    func submitButtonDidTap() {}
}

struct ContentView_Previews: PreviewProvider {

    static var previews: some View {
        NavigationStack {
            PickupPointPicker(viewModel: .preview)
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}
