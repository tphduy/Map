//
//  PickupPointPickerViewModel.swift
//  Map
//
//  Created by Duy Tran on 27/02/2023.
//

import Foundation
import Combine
import Contacts
import CoreLocation
import MapKit

/// An object that manages the interactions with the pickup-point picker.
protocol PickupPointPickerDelegate: AnyObject {
    /// Notifies that a selected point was confirmmed.
    func didConfirmToSelectedPoint()
}

/// An object that manages the pickup-point data and exposes the publishers to displays a list of pickup points .
final class PickupPointPickerViewModel: ObservableObject {
    // MARK: States

    /// The center of the map that is the geocoded postal address of keywords.
    ///
    /// This value is the geocoded postal address of keywords. The default value is none.
    @Published var center: PickupPoint?

    /// A unique identifier of a pickup point that is selected.
    ///
    /// The default value is none.
    @Published var selected: PickupPoint.ID? {
        didSet {
            invalidateIsConfirmButtonEnabled()
        }
    }

    /// The user input text that describes a place name.
    ///
    /// The default value is an empty string.
    @Published var keywords: String = ""

    /// A flag that indicates whether the confirm button is hidden.
    ///
    /// The default value is `true`.
    @Published var isConfirmButtonHidden: Bool = true

    /// A flag that indicates whether the confirm button is enabled.
    ///
    /// The default value is `true`.
    @Published var isConfirmButtonEnabled: Bool = true

    /// A flag that indicates whether to present the alert within the current context.
    @Published var isAlertPresented: Bool  = false

    /// An enumeration that represents states of loading pickup points with latency.
    ///
    /// The default value is loaded with empty data.
    @Published var points: Loadable<[PickupPoint], Error> = .loaded([]) {
        didSet {
            invalidateIsConfirmButtonHidden()
        }
    }

    /// An enumeration that represents states of submitting selected pickup point with latency.
    ///
    /// The default value is loaded.
    @Published var submittingSelectedPoint: Loadable<Void, Error> = .loaded(()) {
        didSet {
            invalidateIsAlertPresented()
        }
    }

    // MARK: Dependencies

    /// An object provides methods for interacting with the pickup-point data in the remote database.
    private let remotePickupPointDataLogic: RemotePickupPointDataLogicType

    /// An object provides methods for interacting with geographic coordinates and place names.
    private let geocodingDataLogic: GeocodingDataLogicType

    /// An object that manages the interactions.
    weak var delegate: PickupPointPickerDelegate?

    // MARK: Misc

    /// A set of tokens to cancel the working publishers.
    private var cancellables = Set<AnyCancellable>()

    // MARK: Init

    /// Initiate an object that manages the pickup-point data and exposes the publishers to display a list of pickup points.
    /// - Parameters:
    ///   - keywords: A place name to perform the initial searching. The default value is an empty string.
    ///   - remotePickupPointDataLogic: An object provides methods for interacting with the pickup-point data in the remote database.
    ///   - geocodingDataLogic: An object provides methods for interacting with geographic coordinates and place names.
    init(
        keywords: String = "",
        remotePickupPointDataLogic: RemotePickupPointDataLogicType = RemotePickupPointDataLogic(),
        geocodingDataLogic: GeocodingDataLogicType = GeocodingDataLogic()
    ) {
        self.keywords = keywords
        self.remotePickupPointDataLogic = remotePickupPointDataLogic
        self.geocodingDataLogic = geocodingDataLogic
        self.sinkToKeywords()
        // Calls API immediately if needed, if the initial search happens in `sinkToKeywords` the operation will be delayed because of `debounce`.
        self.performInitialSearchIfNeeded()
    }

    // MARK: State Changes

    /// Notifies that the keywords are submitted for searching.
    func didSubmitSearch() {
        // Verifies that the keywords are not empty, othersise, resets state to empty.
        guard !keywords.isEmpty else { return resetData() }
        // Clears the curren selected pickup point.
        selected = nil
        // Toggles loading state.
        points = .isLoading(last: points.data)
        // Geocodes the keywords to a postal address.
        let geocoding = geocodingDataLogic.geocode(address: keywords).share()
        // Updates the center point of the map.
        updateCenterPoint(to: geocoding)
        // Calls API to retrive the nearby pickup point.
        updatePickupPoints(to: geocoding)
    }

    /// Notifies that the refresh control was triggered.
    func didRefresh() {
        didSubmitSearch()
    }

    /// Notifies that the confirm button was tapped.
    func didTapConfirmButton() {
        submitSelectedPointIfNeeded()
    }

    /// Observes values received by the publisher of keywords to submit for searching.
    ///
    /// The observation will ignore the first value.
    private func sinkToKeywords() {
        $keywords
            .removeDuplicates()
            .debounce(for: 1, scheduler: RunLoop.main)
            .dropFirst() // To avoid replaying the initial keywords.
            .sink { [weak self] (_) in
                self?.didSubmitSearch()
            }
            .store(in: &cancellables)
    }

    /// Submits for searching if the initial data is empty.
    private func performInitialSearchIfNeeded() {
        guard points.data?.isEmpty ?? true else { return }
        didSubmitSearch()
    }

    /// Resets all data to the empty state.
    private func resetData() {
        center = nil
        selected = nil
        points = .loaded([])
    }

    /// Updates the center point of the map followings the values of an address publisher.
    /// - Parameter address: A publisher that emmits an address or an error.
    private func updateCenterPoint(to address: Publishers.Share<AnyPublisher<CLPlacemark, Error>>) {
        address
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (completion) in
                guard let self, case .failure = completion else { return }
                self.resetData()
            } receiveValue: { [weak self] (placemark: CLPlacemark) in
                guard let self else { return }
                guard let coordinate = placemark.location?.coordinate else { return self.resetData() }
                let location = PickupPoint.Location(latitude: coordinate.latitude, longitude: coordinate.longitude)
                self.center = PickupPoint(location: location)
            }
            .store(in: &cancellables)
    }

    /// Updates the pickup points of the map followings the values of an address publisher.
    /// - Parameter address: A publisher that emmits an address or an error.
    private func updatePickupPoints(to address: Publishers.Share<AnyPublisher<CLPlacemark, Error>>) {
        address
            .compactMap(\.postalAddress)
            .flatMap { (address: CNPostalAddress) -> AnyPublisher<[PickupPoint], Error> in
                self.remotePickupPointDataLogic.pickupPoints(
                    address: address.street,
                    postalCode: address.postalCode,
                    city: address.city,
                    countryCode: address.isoCountryCode
                )
            }
            .receive(on: DispatchQueue.main)
            .print("FOOOOOOOOOOOO")
            .sink { [weak self] (completion) in
                guard let self, case let .failure(error) = completion else { return }
                self.points = .failed(error)
            } receiveValue: { (points: [PickupPoint]) in
                self.points = .loaded(points)
            }
            .store(in: &cancellables)
    }

    /// Submits the currently selected point to a remote database if there is no task in progress.
    private func submitSelectedPointIfNeeded() {
        // Verifies whether it's possible to submit.
        guard shouldSubmitSelectedPoint() else { return }
        // Verifies there is a selected pickup point.
        guard let selected else { return }
        // Shows loading.
        submittingSelectedPoint = .isLoading(last: nil)
        // Submits the selected point.
        remotePickupPointDataLogic
            .select(pickupPoint: selected)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (completion) in
                guard let self, case let .failure(error) = completion else { return }
                // Shows errors to user.
                self.submittingSelectedPoint = .failed(error)
            } receiveValue: { [weak self] (_) in
                guard let self else { return }
                // Hides loading
                self.submittingSelectedPoint = .loaded(())
                // Notifies the delegate about this event.
                self.delegate?.didConfirmToSelectedPoint()
            }
            .store(in: &cancellables)
    }

    /// Invalidates the value of `isConfirmButtonHidden`.
    private func invalidateIsConfirmButtonHidden() {
        isConfirmButtonHidden = points.data?.isEmpty ?? true
    }

    /// Invalidates the value of `isConfirmButtonEnabled`.
    private func invalidateIsConfirmButtonEnabled() {
        isConfirmButtonEnabled = selected != nil
    }

    /// Invalidates the value of `isAlertPresented`.
    private func invalidateIsAlertPresented() {
        if case .failed = submittingSelectedPoint {
            isAlertPresented = true
        } else {
            isAlertPresented = false
        }
    }

    // MARK: Utilities

    /// Verifies whether it's possible to submit the selected point to a remote database.
    /// - Returns: `true` if there is no submitting task in progress, otherwise, `false`.
    private func shouldSubmitSelectedPoint() -> Bool {
        // Verifies that there is no submitting task in progress.
        if case .isLoading = submittingSelectedPoint { return false }
        return true
    }
}

extension PickupPointPickerViewModel {
    // MARK: Preview

    /// Returns an instance with loaded data.
    static var preview: PickupPointPickerViewModel {
        let result = PickupPointPickerViewModel()
        result.center = .Preview.applePark
        result.keywords = "Apple park"
        result.points = .loaded([.Preview.theDukeOfEdinburgh, .Preview.wolfeLiquor])
        return result
    }

    /// Returns an instance with loaded data but empty.
    static var empty: PickupPointPickerViewModel {
        let result = PickupPointPickerViewModel()
        result.center = .Preview.applePark
        result.keywords = "Apple park"
        result.points = .loaded([])
        return result
    }

    /// Returns an instance with a task in progress while there are no pickup points.
    static var inProgressWithoutPoints: PickupPointPickerViewModel {
        let result = PickupPointPickerViewModel()
        result.center = .Preview.applePark
        result.keywords = "Apple park"
        result.points = .isLoading(last: nil)
        return result
    }

    /// Returns an instance with a task in progress while there are some pickup points.
    static var inProgressWithPoints: PickupPointPickerViewModel {
        let result = PickupPointPickerViewModel()
        result.center = .Preview.applePark
        result.keywords = "Apple park"
        result.points = .isLoading(last: [.Preview.theDukeOfEdinburgh, .Preview.wolfeLiquor])
        return result
    }

    /// Returns an instance with a task that was failed.
    static var failure: PickupPointPickerViewModel {
        let result = PickupPointPickerViewModel()
        result.center = .Preview.applePark
        result.keywords = "Apple park"
        result.points = .failed(NSError())
        return result
    }

    // Returns an instance while submitting the selected point.
    static var submittingSelectedPoint: PickupPointPickerViewModel {
        let result = PickupPointPickerViewModel()
        result.center = .Preview.applePark
        result.selected = PickupPoint.Preview.theDukeOfEdinburgh.id
        result.keywords = "Apple park"
        result.points = .loaded([.Preview.theDukeOfEdinburgh, .Preview.wolfeLiquor])
        result.submittingSelectedPoint = .isLoading(last: nil)
        return result
    }

    // Returns an instance while submitting the selected point.
    static var submittedSelectedPointWithError: PickupPointPickerViewModel {
        let result = Self.submittingSelectedPoint
        result.submittingSelectedPoint = .failed(NSError(domain: "Foo bar", code: 0))
        result.isAlertPresented = true
        return result
    }
}
