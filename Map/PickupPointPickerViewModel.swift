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

final class PickupPointPickerViewModel: ObservableObject {
    // MARK: States

    @Published var referencePoint: PickupPoint?
    @Published var selected: PickupPoint?
    @Published var keywords = ""
    @Published var state: Loadable<[PickupPoint], Error> = .isLoading(last: nil)

    var points: [PickupPoint] {
        state.data ?? []
    }

    // MARK: Dependencies

    private let remotePickupPointDataLogic: RemotePickupPointDataLogicType

    private let geocodingDataLogic: GeocodingDataLogicType

    // MARK: Misc

    private var cancellables = Set<AnyCancellable>()

    // MARK: Init

    init(
        remotePickupPointDataLogic: RemotePickupPointDataLogicType = RemotePickupPointDataLogic(),
        geocodingDataLogic: GeocodingDataLogicType = GeocodingDataLogic()
    ) {
        self.remotePickupPointDataLogic = remotePickupPointDataLogic
        self.geocodingDataLogic = geocodingDataLogic
    }

    // MARK: State Changes

    func didSubmitSearch() {
        // Verifies that the keywords are some.
        guard !keywords.isEmpty else { return resetData() }
        state = .isLoading(last: state.data)
        let geocoding = geocodingDataLogic
            .geocode(address: keywords)
            .share()
        updateReferencePoint(to: geocoding)
        updatePickupPoints(to: geocoding)

    }

    private func resetData() {
        referencePoint = nil
        selected = nil
        state = .loaded([])
    }

    private func updateReferencePoint(to placemark: CLPlacemark) {
        referencePoint = PickupPoint(
            address: placemark.postalAddress?.street,
            postcode: placemark.postalAddress?.postalCode,
            name: nil,
            hasDisabledAccess: nil,
            city: placemark.postalAddress?.city,
            reference: nil,
            location: PickupPoint.Location(
                latitude: placemark.location?.coordinate.latitude ?? 0,
                longitude: placemark.location?.coordinate.longitude ?? 0),
            carrier: nil,
            openingTimes: nil,
            distance: nil,
            isLegacyPickup: nil
        )
    }

    private func updateReferencePoint(to geocoding: Publishers.Share<AnyPublisher<CLPlacemark, Error>>) {
        geocoding
            .receive(on: RunLoop.main)
            .sink { (completion) in
                guard case .failure = completion else { return }
                self.resetData()
            } receiveValue: { (placemark: CLPlacemark) in
                self.updateReferencePoint(to: placemark)
            }
            .store(in: &cancellables)
    }

    private func updatePickupPoints(to geocoding: Publishers.Share<AnyPublisher<CLPlacemark, Error>>) {
        selected = nil

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
            .sink { (completion) in
                guard case let .failure(error) = completion else { return }
                self.state = .failed(error)
            } receiveValue: { (points: [PickupPoint]) in
                self.resetData()
                self.state = .loaded(points)
            }
            .store(in: &cancellables)
    }
}
