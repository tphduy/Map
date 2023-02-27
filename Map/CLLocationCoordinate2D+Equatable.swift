//
//  CLLocationCoordinate2D+Equatable.swift
//  Map
//
//  Created by Duy Tran on 27/02/2023.
//

import CoreLocation

extension CLLocationCoordinate2D: Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}
