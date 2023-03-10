//
//  GeocodingDataLogic.swift
//  Map
//
//  Created by Duy Tran on 27/02/2023.
//

import Foundation
import CoreLocation
import Combine

/// An object provides methods for interacting with geographic coordinates and place names.
protocol GeocodingDataLogicType {
    /// Geocode a place name to a postal address.
    /// - Parameter address: A string describing the location you want to look up. For example, you could specify the string “1 Infinite Loop, Cupertino, CA” to locate Apple headquarters.
    /// - Returns: A publisher that emits a postal address or an error.
    func geocode(address: String) -> AnyPublisher<CLPlacemark, Error>

    /// Geocode a place name to a postal address.
    /// - Parameter address: A string describing the location you want to look up. For example, you could specify the string “1 Infinite Loop, Cupertino, CA” to locate Apple headquarters.
    /// - Returns: A postal address.
    func geocode(address: String) async throws -> CLPlacemark
}

/// An object provides methods for interacting with geographic coordinates and place names.
final class GeocodingDataLogic: GeocodingDataLogicType {
    // MARK: Dependencies

    /// An interface for converting between geographic coordinates and place names.
    private let geocoder: CLGeocoder = CLGeocoder()

    /// A dictionary that stores the possible postal address of a place name in pairs.
    private var cache: [String: CLPlacemark] = [:]

    // MARK: GeocodingDataLogicType

    func geocode(address: String) -> AnyPublisher<CLPlacemark, Error> {
        return Deferred { // Awaits subscription before running the supplied closure to create a publisher for the new subscriber.
            Future<CLPlacemark, Error> { (promise) in
                // Returns the cache value if possible.
                if let result = self.cache[address] { return promise(.success(result)) }
                // Geocodes the place name to a postal address.
                self.geocoder.geocodeAddressString(address) { (placemarks: [CLPlacemark]?, error: Error?) in
                    if let error {
                        // Clears the associated cache entry.
                        self.cache[address] = nil
                        // Emits the result to the publisher.
                        return promise(.failure(error))
                    } else if let placemark = placemarks?.first {
                        // Caches the latest value.
                        self.cache[address] = placemark
                        // Emits the result to the publisher.
                        promise(.success(placemark))
                    } else {
                        // Clears the associated cache entry.
                        self.cache[address] = nil
                        // Emits the result to the publisher.
                        return promise(.failure(GeocodingError.empty))
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }

    func geocode(address: String) async throws -> CLPlacemark {
        // Returns the cache value if possible.
        if let result = cache[address] { return result  }
        // Geocodes the place name to a postal address.
        guard
            let result = try await geocoder.geocodeAddressString(address).first
        else {
            throw GeocodingError.empty
        }
        return result
    }

    // MARK: State Changes

    /// Resets cache storage to empty.
    func reset() {
        cache.removeAll()
    }
}

extension GeocodingDataLogic {
    // MARK: Subtypes

    /// A specialized error that provides localized messages describing the error and why it occurred of the geocoding process.
    enum GeocodingError: LocalizedError {
        /// Although the geocoding was success but the result is empty.
        case empty
    }
}
