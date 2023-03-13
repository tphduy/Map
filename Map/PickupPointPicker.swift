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
            content
            confirmButton
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Choose a pick-up point")
        .alert(isPresented: $viewModel.isAlertPresented, content: confirmationFailureAlert)
    }

    /// The main content that reflects the current state..
    var content: some View {
        ScrollViewReader { (proxy) in
            // `ScrollView` instead of `List` because there is no way to manage the seperators and insets between items on iOS 14.
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 0, pinnedViews: .sectionHeaders) {
                    Section(content: EmptyView.init, header: searchBar)
                    Section(content: list, header: map)
                }
                .background(Color.clear)
            }
            .foregroundColor(.black)
            .background(Color(.systemGray6))
            .onReceive(viewModel.$selected) { (selected) in
                guard let selected else { return }
                withAnimation {
                    proxy.scrollTo(selected)
                }
            }
        }
    }

    /// A list of pickup points that reflects the current state.
    @ViewBuilder func list() -> some View {
        Group {
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
        .padding(EdgeInsets(top: 12, leading: 16, bottom: 0, trailing: 16))
    }

    /// A custom search bar that lets user input a place name.
    func searchBar() -> some View {
        VStack(alignment: .leading) {
            Text("Showing pick-up points near:")
            SearchBar(text: $viewModel.keywords)
        }
        .padding(EdgeInsets(top: 16, leading: 16, bottom: 10, trailing: 16))
        .background(Color(.systemBackground))
    }

    /// A that displays the pickup points on a map with selection.
    func map() -> some View {
        PickupPointMap(
            points: viewModel.points.data ?? [],
            center: $viewModel.center,
            selected: $viewModel.selected
        )
        .aspectRatio(193.0 / 123.0, contentMode: .fill)    }

    /// A view that show there is a task in progress.
    var progress: some View {
        HStack {
            Spacer()
            ProgressView()
                .progressViewStyle(.circular)
            Spacer()
        }
    }

    /// A view that displays there is no pickup points.
    var empty: some View {
        Text("There are no available pickup-points around your address.")
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
    }

    /// A view that displays the pickup points were failed to load.
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
        .frame(maxWidth: .infinity)
    }

    /// A group of views where each view displays a pickup point.
    var rows: some View {
        ForEach(viewModel.points.data ?? []) { (point) in
            PickupPointRow(point: point, selected: $viewModel.selected)
                .id(point.id)
                .frame(maxWidth: .infinity)
                .padding(EdgeInsets(top: 16, leading: 10, bottom: 16, trailing: 16))
                .background(Color(.systemBackground))
                .onTapGesture {
                    viewModel.selected = point.id
                }
        }
    }

    /// A view that lets user confirm for the currenly selected point.
    @ViewBuilder var confirmButton: some View {
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

    /// A model that describes the failure of selected point confirmation.
    /// - Returns: A representation of an alert presentation.
    func confirmationFailureAlert() -> Alert {
        Alert(
            title: Text("Error"),
            message: Text(viewModel.submittingSelectedPoint.error?.localizedDescription ?? ""),
            dismissButton: .default(Text("Dismiss"))
        )
    }
}

struct ContentView_Previews: PreviewProvider {
    // MARK: Preview

    static var previews: some View {
        Group {
            NavigationView {
                PickupPointPicker(viewModel: .preview)
            }
            .previewDisplayName("Loaded")

            NavigationView {
                PickupPointPicker(viewModel: .empty)
            }
            .previewDisplayName("Empty")

            NavigationView {
                PickupPointPicker(viewModel: .inProgressWithoutPoints)
            }
            .previewDisplayName("In Progress Without Data")

            NavigationView {
                PickupPointPicker(viewModel: .inProgressWithPoints)
            }
            .previewDisplayName("In Progress With Some Data")

            NavigationView {
                PickupPointPicker(viewModel: .failure)
            }
            .previewDisplayName("Failure")

            NavigationView {
                PickupPointPicker(viewModel: .submittingSelectedPoint)
            }
            .previewDisplayName("Submitting Selected Point")

            NavigationView {
                PickupPointPicker(viewModel: .submittedSelectedPointWithError)
            }
            .previewDisplayName("Submitted Selected Point With Error")
        }
    }
}
