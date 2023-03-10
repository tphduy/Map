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
        VStack {
            list
            confirmButton
        }
        .listStyle(.plain)
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Choose a pick-up point")
        .alert(isPresented: $viewModel.isAlertPresented, content: alert)
    }

    var list: some View {
        ScrollViewReader { (proxy) in
            List {
                searchBar
                Section {
                    listContent
                } header: {
                    map
                }
            }
            .background(Color(.systemGroupedBackground))
            .onReceive(viewModel.$selected) { (selected) in
                guard let selected else { return }
                withAnimation {
                    proxy.scrollTo(selected)
                }
            }
        }
    }

    @ViewBuilder
    var listContent: some View {
        if #available(iOS 15.0, *) {
            switch viewModel.points {
            case .loaded(let data) where data.isEmpty:
                empty
                    .listRowSeparator(.hidden)
            case .isLoading, .loaded:
                rows
                    .listRowSeparator(.hidden)
            case .failed:
                failure
                    .listRowSeparator(.hidden)
            }
        } else {
            switch viewModel.points {
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
    }

    var searchBar: some View {
        VStack(alignment: .leading) {
            Text("Showing pick-up points near:")
            SearchBar(text: $viewModel.keywords)
        }
        .background(Color(.systemBackground))
        .listRowBackground(Color(.systemBackground))
    }

    var map: some View {
        ZStack(alignment: .center) {
            PickupPointMap(
                points: viewModel.points.data ?? [],
                center: $viewModel.center,
                selected: $viewModel.selected
            )
            .aspectRatio(193.0 / 123.0, contentMode: .fill)

            if case .isLoading = viewModel.points {
                ProgressView()
            }
        }
        .listRowInsets(EdgeInsets())
    }

    var progress: some View {
        HStack {
            Spacer()
            ProgressView()
            Spacer()
        }
    }

    var empty: some View {
        Text("There are no available pickup-points around your address.")
            .multilineTextAlignment(.center)
    }

    var failure: some View {
        VStack(spacing: 8) {
            Text("Something went wrong, please try again by pulling to refresh.")
                .multilineTextAlignment(.center)
            Button(action: viewModel.didRefresh) {
                Text("Refresh")
                    .padding(EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8))
                    .foregroundColor(.white)
                    .background(Color.blue)
                    .cornerRadius(4)
            }
        }
    }

    var rows: some View {
        ForEach(viewModel.points.data ?? []) { (point) in
            PickupPointRow(point: point, selected: $viewModel.selected)
                .id(point.id)
                .padding()
                .background(Color(.systemBackground))
                .listRowBackground(Color.clear)
                .onTapGesture {
                    viewModel.selected = point.id
                }
        }
    }

    @ViewBuilder
    var confirmButton: some View {
        if !viewModel.isConfirmButtonHidden {
            Button(action: viewModel.didTapConfirmButton) {
                HStack(spacing: 8) {
                    Text("Confirm")
                    if case .isLoading = viewModel.submittingSelectedPoint {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .foregroundColor(.white)
                .background(viewModel.isConfirmButtonEnabled ? Color.black : Color.gray)
                .cornerRadius(2)
                .font(.headline)
            }
            .padding()
            .disabled(!viewModel.isConfirmButtonEnabled)
        }
    }

    func alert() -> Alert {
        Alert(
            title: Text("Error"),
            message: Text(viewModel.submittingSelectedPoint.error?.localizedDescription ?? ""),
            dismissButton: .default(Text("Dismiss"))
        )
    }
}

struct ContentView_Previews: PreviewProvider {
    // MARK: Preview

    static var loaded: some View {
        Group {
            if #available(iOS 16.0, *) {
                NavigationStack {
                    PickupPointPicker(viewModel: .preview)
                }
            } else {
                NavigationView {
                    PickupPointPicker(viewModel: .preview)
                }
            }
        }
        .previewDisplayName("Loaded")
    }

    static var empty: some View {
        Group {
            if #available(iOS 16.0, *) {
                NavigationStack {
                    PickupPointPicker(viewModel: .empty)
                }
            } else {
                NavigationView {
                    PickupPointPicker(viewModel: .empty)
                }
            }
        }
        .previewDisplayName("Empty")
    }

    static var inProgressWithoutPoints: some View {
        Group {
            if #available(iOS 16.0, *) {
                NavigationStack {
                    PickupPointPicker(viewModel: .inProgressWithoutPoints)
                }
            } else {
                NavigationView {
                    PickupPointPicker(viewModel: .inProgressWithoutPoints)
                }
            }
        }
        .previewDisplayName("In Progress Without Data")
    }

    static var inProgressWithPoints: some View {
        Group {
            if #available(iOS 16.0, *) {
                NavigationStack {
                    PickupPointPicker(viewModel: .inProgressWithPoints)
                }
            } else {
                NavigationView {
                    PickupPointPicker(viewModel: .inProgressWithPoints)
                }
            }
        }
        .previewDisplayName("In Progress With Some Data")
    }

    static var failure: some View {
        Group {
            if #available(iOS 16.0, *) {
                NavigationStack {
                    PickupPointPicker(viewModel: .failure)
                }
            } else {
                NavigationView {
                    PickupPointPicker(viewModel: .failure)
                }
            }
        }
        .previewDisplayName("Failure")
    }

    static var submittingSelectedPoint: some View {
        Group {
            if #available(iOS 16.0, *) {
                NavigationStack {
                    PickupPointPicker(viewModel: .submittingSelectedPoint)
                }
            } else {
                NavigationView {
                    PickupPointPicker(viewModel: .submittingSelectedPoint)
                }
            }
        }
        .previewDisplayName("Submitting Selected Point")
    }

    static var submittedSelectedPointWithError: some View {
        Group {
            if #available(iOS 16.0, *) {
                NavigationStack {
                    PickupPointPicker(viewModel: .submittedSelectedPointWithError)
                }
            } else {
                NavigationView {
                    PickupPointPicker(viewModel: .submittedSelectedPointWithError)
                }
            }
        }
        .previewDisplayName("Submitted Selected Point With Error")
    }

    static var previews: some View {
        Group {
            loaded
            empty
            inProgressWithoutPoints
            inProgressWithPoints
            failure
            submittingSelectedPoint
            submittedSelectedPointWithError
        }
    }
}
