//
//  GeocodingDataLogic.swift
//  Map
//
//  Created by Duy Tran on 27/02/2023.
//

import Foundation
import CoreLocation
import Combine

protocol GeocodingDataLogicType {
    func geocode(address: String) -> AnyPublisher<CLPlacemark, Error>
}

struct GeocodingDataLogic: GeocodingDataLogicType {
    // MARK: GeocodingDataLogicType

    func geocode(address: String) -> AnyPublisher<CLPlacemark, Error> {
        return Deferred {
            Future<CLPlacemark, Error> { (promise) in
                let geocoder = CLGeocoder()
                geocoder.geocodeAddressString(address) { (placemarks: [CLPlacemark]?, error: Error?) in
                    if let error {
                        return promise(.failure(error))
                    } else if let placemark = placemarks?.first {
                        promise(.success(placemark))
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }
}
