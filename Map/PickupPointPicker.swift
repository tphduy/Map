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

    /// An object that manages the pickup-point data and exposes the publishers to displays a list of pickup points .
    @ObservedObject var viewModel = PickupPointPickerViewModel()

    // MARK: View

    var body: some View {
        ScrollViewReader { (proxy) in
            List(selection: $viewModel.selected) {
                Section {
                    listContent
                } header: {
                    map
                }
            }
            .onReceive(viewModel.$selected) { (selected) in
                proxy.scrollTo(selected)
            }
        }
        .listStyle(.plain)
        .navigationTitle("Choose a pick-up point")
        .searchable(text: $viewModel.keywords, prompt: "Address")
        .onSubmit(of: .search) {
            viewModel.didSubmitSearch()
        }
    }

    @ViewBuilder
    var listContent: some View {
        switch viewModel.state {
        case .isLoading:
            progress
            rows
        case .loaded(let data) where data.isEmpty:
            empty
        case .loaded:
            rows
        case .failed:
            failure
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

    var empty: some View {
        Text("There are no available pickup-points around your address.")
            .listRowSeparator(.hidden)
    }

    var failure: some View {
        Text("Something went wrong, please try again by pulling to refresh.")
    }

    var rows: some View {
        ForEach(viewModel.state.data ?? []) { (point) in
            PickupPointRow(point: point)
                .id(point.id)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    // MARK: Preview

    static var previews: some View {
        Group {
            NavigationStack {
                PickupPointPicker(viewModel: .preview)
                    .navigationBarTitleDisplayMode(.inline)
            }
            .previewDisplayName("Loaded With Some Data")

            NavigationStack {
                PickupPointPicker(viewModel: {
                    let result = PickupPointPickerViewModel()
                    result.center = .Preview.applePark
                    result.keywords = "Apple park"
                    result.state = .loaded([])
                    return result
                }())
                .navigationBarTitleDisplayMode(.inline)
            }
            .previewDisplayName("Loaded Without Data")

            NavigationStack {
                PickupPointPicker(viewModel: {
                    let result = PickupPointPickerViewModel()
                    result.center = .Preview.applePark
                    result.keywords = "Apple park"
                    result.state = .isLoading(last: nil)
                    return result
                }())
                .navigationBarTitleDisplayMode(.inline)
            }
            .previewDisplayName("Is Loading Without Data")

            NavigationStack {
                PickupPointPicker(viewModel: {
                    let result = PickupPointPickerViewModel()
                    result.center = .Preview.applePark
                    result.keywords = "Apple park"
                    result.state = .isLoading(last: [.Preview.theDukeOfEdinburgh, .Preview.wolfeLiquor])
                    return result
                }())
                .navigationBarTitleDisplayMode(.inline)
            }
            .previewDisplayName("Is Loading With Some Data")
        }
    }
}
