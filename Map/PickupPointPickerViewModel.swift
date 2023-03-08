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

/// An object that manages the pickup-point data and exposes the publishers to displays a list of pickup points .
final class PickupPointPickerViewModel: ObservableObject {
    // MARK: States

    @Published var center: PickupPoint?

    @Published var selected: PickupPoint.ID?
    
    @Published var keywords: String = ""

    @Published var state: Loadable<[PickupPoint], Error> = .loaded([])

    // MARK: Dependencies

    private let remotePickupPointDataLogic: RemotePickupPointDataLogicType

    private let geocodingDataLogic: GeocodingDataLogicType

    // MARK: Misc

    private var cancellables = Set<AnyCancellable>()

    // MARK: Init

    init(
        keywords: String = "",
        remotePickupPointDataLogic: RemotePickupPointDataLogicType = RemotePickupPointDataLogic(),
        geocodingDataLogic: GeocodingDataLogicType = GeocodingDataLogic()
    ) {
        self.keywords = keywords
        self.remotePickupPointDataLogic = remotePickupPointDataLogic
        self.geocodingDataLogic = geocodingDataLogic
        self.sinkToKeywords()
        self.performInitialSearchIfNeeded()
    }

    // MARK: State Changes

    /// Notifies that the keywords are submitted for searching.
    func didSubmitSearch() {
        // Verifies that the keywords are some.
        guard !keywords.isEmpty else { return resetData() }
        selected = nil
        state = .isLoading(last: state.data)
        let geocoding = geocodingDataLogic.geocode(address: keywords).share()
        updateCenterPoint(to: geocoding)
        updatePickupPoints(to: geocoding)
    }

    /// Notifies that the refresh control was triggered.
    func didRefresh() {
        didSubmitSearch()
    }

    /// Notifies that the confirm button was tapped.
    func didTapConfirmButton() {}

    /// Observes values received by the publisher of keywords to submit for searching.
    private func sinkToKeywords() {
        $keywords
            .removeDuplicates()
            .debounce(for: 1, scheduler: RunLoop.main)
            .dropFirst()
            .sink { [weak self] (_) in
                self?.didSubmitSearch()
            }
            .store(in: &cancellables)
    }

    /// Submits for searching if the initial data is empty.
    private func performInitialSearchIfNeeded() {
        guard state.data?.isEmpty ?? true else { return }
        didSubmitSearch()
    }

    /// Resets all data to the empty state.
    private func resetData() {
        center = nil
        selected = nil
        state = .loaded([])
    }

    /// Updates the center point of the map followings the values of an address publisher.
    /// - Parameter address: A publisher that emmits an address or an error.
    private func updateCenterPoint(to address: Publishers.Share<AnyPublisher<CLPlacemark, Error>>) {
        address
            .receive(on: RunLoop.main)
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
                    countryCode: address.isoCountryCode,
                    stateCode: nil
                )
            }
            .receive(on: RunLoop.main)
            .sink { [weak self] (completion) in
                guard let self, case let .failure(error) = completion else { return }
                self.state = .failed(error)
            } receiveValue: { (points: [PickupPoint]) in
                self.state = .loaded(points)
            }
            .store(in: &cancellables)
    }
}

extension PickupPointPickerViewModel {
    // MARK: Preview
    
    static var preview: PickupPointPickerViewModel {
        let result = PickupPointPickerViewModel()
        result.center = .Preview.applePark
        result.selected = PickupPoint.Preview.theDukeOfEdinburgh.id
        result.keywords = "Apple park"
        result.state = .loaded([.Preview.theDukeOfEdinburgh, .Preview.wolfeLiquor])
        return result
    }

    static var empty: PickupPointPickerViewModel {
        let result = PickupPointPickerViewModel()
        result.center = .Preview.applePark
        result.keywords = "Apple park"
        result.state = .loaded([])
        return result
    }

    static var inProgressWithoutData: PickupPointPickerViewModel {
        let result = PickupPointPickerViewModel()
        result.center = .Preview.applePark
        result.keywords = "Apple park"
        result.state = .isLoading(last: nil)
        return result
    }

    static var inProgressWithData: PickupPointPickerViewModel {
        let result = PickupPointPickerViewModel()
        result.center = .Preview.applePark
        result.keywords = "Apple park"
        result.state = .isLoading(last: [.Preview.theDukeOfEdinburgh, .Preview.wolfeLiquor])
        return result
    }

    static var failure: PickupPointPickerViewModel {
        let result = PickupPointPickerViewModel()
        result.center = .Preview.applePark
        result.keywords = "Apple park"
        result.state = .failed(NSError())
        return result
    }
}
