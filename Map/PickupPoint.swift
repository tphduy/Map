//
//  DeliveryHub.swift
//  Map
//
//  Created by Duy Tran on 02/02/2023.
//

import MapKit

struct PickupPoint: Codable, Hashable {
    let address: String?
    let postcode: String?
    let name: String?
    let hasDisabledAccess: Bool?
    let city: String?
    let reference: String?
    let location: Location
    let carrier: Carrier?
    let openingTimes: OpeningTimes?
    let distance: Distance?
    let isLegacyPickup: Bool?

    struct Carrier: Codable, Hashable {
        let name: String?
        let iconURL: URL?

        enum CodingKeys: String, CodingKey {
            case name
            case iconURL = "iconUrl"
        }
    }

    struct Distance: Codable, Hashable {
        let formatted: String?
        let meters: Int?
    }

    struct Location: Codable, Hashable {
        let latitude, longitude: Double

        var coordinate: CLLocationCoordinate2D {
            CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }

        enum CodingKeys: String, CodingKey {
            case latitude
            case longitude = "lng"
        }
    }

    struct OpeningTimes: Codable, Hashable {
        let saturday, monday, friday, tuesday: String?
        let wednesday, thursday, sunday: String?
    }
}

extension PickupPoint: Identifiable {
    var id: Int {
        hashValue
    }
}

extension  PickupPoint {
    enum Preview {
        static var applePark: PickupPoint {
            PickupPoint(
                address: "One Apple Park Way, Cupertino, CA 95014, United States",
                postcode: nil,
                name: "Apple Park",
                hasDisabledAccess: nil,
                city: "Cupertino",
                reference: nil,
                location: Location(
                    latitude: 37.334_900,
                    longitude: -122.009_020),
                carrier: Carrier(
                    name: "Apple",
                    iconURL: URL(string: "https://cdn-icons-png.flaticon.com/512/0/747.png")),
                openingTimes: nil,
                distance: nil,
                isLegacyPickup: nil)
        }

        static var theDukeOfEdinburgh: PickupPoint {
            PickupPoint(
                address: "10801 N Wolfe Rd, Cupertino, CA 95014, United States",
                postcode: nil,
                name: "The Duke of Edinburgh",
                hasDisabledAccess: nil,
                city: "Cupertino",
                reference: nil,
                location: Location(
                    latitude: 37.334944,
                    longitude: -122.014694),
                carrier: Carrier(
                    name: "The Duke of Edinburgh",
                    iconURL: URL(string: "https://cdn-icons-png.flaticon.com/512/0/747.png")),
                openingTimes: nil,
                distance: nil,
                isLegacyPickup: nil)
        }

        static var wolfeLiquor: PickupPoint {
            PickupPoint(
                address: "1689 S Wolfe Rd, Sunnyvale, CA 94087, United States",
                postcode: nil,
                name: "Wolfe Liquor",
                hasDisabledAccess: nil,
                city: "Cupertino",
                reference: nil,
                location: Location(
                    latitude: 37.338337,
                    longitude: -122.014590),
                carrier: Carrier(
                    name: "Wolfe Liquor",
                    iconURL: URL(string: "https://cdn-icons-png.flaticon.com/512/0/747.png")),
                openingTimes: nil,
                distance: nil,
                isLegacyPickup: nil)
        }
    }
}
