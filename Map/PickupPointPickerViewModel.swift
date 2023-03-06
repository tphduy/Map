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
        self.performInitialSearchIfNeeded()
    }

    // MARK: State Changes

    func didSubmitSearch() {
        // Verifies that the keywords are some.
        guard !keywords.isEmpty else { return resetData() }
        selected = nil
        state = .isLoading(last: state.data)
        let geocoding = geocodingDataLogic.geocode(address: keywords).share()
        updateCenterPoint(to: geocoding)
        updatePickupPoints(to: geocoding)
    }

    func didTapSubmitButton() {}

    private func performInitialSearchIfNeeded() {
        guard state.data?.isEmpty ?? true else { return }
        didSubmitSearch()
    }

    private func resetData() {
        center = nil
        selected = nil
        state = .loaded([])
    }

    private func updateCenterPoint(to geocoding: Publishers.Share<AnyPublisher<CLPlacemark, Error>>) {
        geocoding
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

    private func updatePickupPoints(to geocoding: Publishers.Share<AnyPublisher<CLPlacemark, Error>>) {
        geocoding
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

    static var preview: PickupPointPickerViewModel {
        let result = PickupPointPickerViewModel()
        result.center = .Preview.applePark
        result.selected = PickupPoint.Preview.theDukeOfEdinburgh.id
        result.keywords = "Apple park"
        result.state = .loaded([.Preview.theDukeOfEdinburgh, .Preview.wolfeLiquor])
        return result
    }
}
