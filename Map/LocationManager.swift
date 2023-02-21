//
//  LocationManager.swift
//  Map
//
//  Created by Duy Tran on 30/01/2023.
//

import Foundation
import os.log
import MapKit

/// An object that manages location privacy and starts/stops  the delivery of location-related events.
final class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    // MARK: Publishers

    /// A value that represents either the latest locations or a failure.
    ///
    /// The default value is success with an empty list of locations.
    @Published var locations: Result<[CLLocation], Error> = .success([])

    // MARK: Misc

    /// The underlying manager that starts and stops the delivery of location-related events.
    private(set) lazy var manager: CLLocationManager = {
        let result = CLLocationManager()
        result.delegate = self
        result.desiredAccuracy = kCLLocationAccuracyBest
        return result
    }()

    /// An object for writing logs to the unified logging system.
    let logger = Logger(
        subsystem: [Bundle.main.bundleIdentifier, String(describing: LocationManager.self)]
            .compactMap { $0 }
            .joined(separator: "."),
        category: "Location"
    )

    /// A flag that indicates whether it should start updating location right after the app is authorized to access location data.
    let startUpdatingLocationAfterAuthorized: Bool

    // MARK: Init

    /// Initiates an object that manages location privacy and starts/stops  the delivery of location-related events.
    /// - Parameter startUpdatingLocationAfterAuthorized: A flag that indicates whether it should start updating location right after the app is authorized to access location data.
    init(startUpdatingLocationAfterAuthorized: Bool = false) {
        self.startUpdatingLocationAfterAuthorized = startUpdatingLocationAfterAuthorized
    }

    // MARK: Side Effects

    /// Requests the user’s permission to use location services while the app is in use if the app hasn't requested yet.
    ///
    /// It will start updating location automatically if the status is authorizaed and `startUpdatingLocationAfterAuthorized` is true.
    func requestWhenInUseAuthorizationIfNeeded() {
        switch manager.authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            break
        case .authorizedAlways, .authorizedWhenInUse, .authorized:
            guard startUpdatingLocationAfterAuthorized else { break }
            manager.startUpdatingLocation()
        @unknown default:
            break
        }
    }

    /// Starts the generation of updates that report the user’s current location.
    func startUpdatingLocation() {
        manager.startUpdatingLocation()
    }

    /// Updates the current locations if the new values are different.
    /// - Parameter locations: A list of locations, each element contains the latitude, longitude, and course information reported by the system.
    private func updateLocationIfNeeded(withLocations locations: [CLLocation]) {
        let currentLocations = (try? self.locations.get()) ?? []
        guard currentLocations != locations else { return }
        self.locations = .success(locations)
    }

    // MARK: Utilities

    /// Creates a string representing the given value.
    /// - Parameter status: Constants indicating the app's authorization to use location services.
    /// - Returns: A string.
    private func describing(_ status: CLAuthorizationStatus) -> String {
        switch status {
        case .notDetermined:
            return "not determined"
        case .restricted:
            return "restricted"
        case .denied:
            return "denied"
        case .authorizedAlways:
            return "authorized always"
        case .authorizedWhenInUse:
            return "authorized when in use"
        case .authorized:
            return "authorized"
        @unknown default:
            return "unknown"
        }
    }

    // MARK: CLLocationManagerDelegate

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let statusDescription = describing(manager.authorizationStatus)
        logger.log("Location manager did change authorization to \(statusDescription)")
        requestWhenInUseAuthorizationIfNeeded()
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        logger.log(level: .error, "Location manager did fail with error \(error.localizedDescription)")
        locations = .failure(error)
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        logger.log("Location manager did update locations \(locations)")
        updateLocationIfNeeded(withLocations: locations)
    }

    func locationManager(_ manager: CLLocationManager, didFinishDeferredUpdatesWithError error: Error?) {
        let errorDescription = error
            .map { "  with error \($0.localizedDescription)" }
            ?? ""
        logger.log(level: .error, "Location manager did finish deffered updates\(errorDescription)")
        guard let error else { return }
        locations = .failure(error)
    }
}
