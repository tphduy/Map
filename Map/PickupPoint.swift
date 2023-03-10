//
//  DeliveryHub.swift
//  Map
//
//  Created by Duy Tran on 02/02/2023.
//

import MapKit

/// An object that abstract a pickup point.
struct PickupPoint: Codable, Hashable {
    let address: String?
    let postcode: String?
    let name: String?
    let hasDisabledAccess: Bool?
    let city: String?
    let reference: String
    let location: Location
    let carrier: Carrier?
    let openingTimes: OpeningTimes?
    let distance: Distance?
    let isLegacyPickup: Bool?

    init(
        address: String? = nil,
        postcode: String? = nil,
        name: String? = nil,
        hasDisabledAccess: Bool? = nil,
        city: String? = nil,
        reference: String = "",
        location: Location,
        carrier: Carrier? = nil,
        openingTimes: OpeningTimes? = nil,
        distance: Distance? = nil,
        isLegacyPickup: Bool? = nil
    ) {
        self.address = address
        self.postcode = postcode
        self.name = name
        self.hasDisabledAccess = hasDisabledAccess
        self.city = city
        self.reference = reference
        self.location = location
        self.carrier = carrier
        self.openingTimes = openingTimes
        self.distance = distance
        self.isLegacyPickup = isLegacyPickup
    }

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
        let latitude, longitude: Double?

        var coordinate: CLLocationCoordinate2D {
            CLLocationCoordinate2D(latitude: latitude ?? 0, longitude: longitude ?? 0)
        }

        enum CodingKeys: String, CodingKey {
            case latitude = "lat"
            case longitude = "lng"
        }
    }

    struct OpeningTimes: Codable, Hashable {
        let monday: String?
        let friday: String?
        let sunday: String?
        let tuesday: String?
        let thursday: String?
        let wednesday: String?
        let saturday: String?
    }
}

extension PickupPoint: Identifiable {
    var id: String {
        reference
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
                reference: "One Apple Park Way, Cupertino, CA 95014, United States",
                location: Location(
                    latitude: 37.334_900,
                    longitude: -122.009_020),
                carrier: Carrier(
                    name: "Apple",
                    iconURL: URL(string: "https://cdn-icons-png.flaticon.com/512/0/747.png")),
                openingTimes: OpeningTimes(
                    monday: "09:00 - 19:00",
                    friday: "09:00 - 19:00",
                    sunday: "09:00 - 19:00",
                    tuesday: "09:00 - 19:00",
                    thursday: "09:00 - 19:00",
                    wednesday: "09:00 - 19:00",
                    saturday: "09:00 - 19:00"),
                distance: Distance(formatted: "2m", meters: 2),
                isLegacyPickup: nil)
        }

        static var theDukeOfEdinburgh: PickupPoint {
            PickupPoint(
                address: "10801 N Wolfe Rd, Cupertino, CA 95014, United States",
                postcode: nil,
                name: "The Duke of Edinburgh",
                hasDisabledAccess: nil,
                city: "Cupertino",
                reference: "10801 N Wolfe Rd, Cupertino, CA 95014, United States",
                location: Location(
                    latitude: 37.334944,
                    longitude: -122.014694),
                carrier: Carrier(
                    name: "The Duke of Edinburgh",
                    iconURL: URL(string: "https://cdn-icons-png.flaticon.com/512/0/747.png")),
                openingTimes: OpeningTimes(
                    monday: "09:00 - 19:00",
                    friday: "09:00 - 19:00",
                    sunday: "09:00 - 19:00",
                    tuesday: "09:00 - 19:00",
                    thursday: "09:00 - 19:00",
                    wednesday: "09:00 - 19:00",
                    saturday: "09:00 - 19:00"),
                distance: Distance(formatted: "3m", meters: 3),
                isLegacyPickup: nil)
        }

        static var wolfeLiquor: PickupPoint {
            PickupPoint(
                address: "1689 S Wolfe Rd, Sunnyvale, CA 94087, United States",
                postcode: nil,
                name: "Wolfe Liquor",
                hasDisabledAccess: nil,
                city: "Cupertino",
                reference: "1689 S Wolfe Rd, Sunnyvale, CA 94087, United States",
                location: Location(
                    latitude: 37.338337,
                    longitude: -122.014590),
                carrier: Carrier(
                    name: "Wolfe Liquor",
                    iconURL: URL(string: "https://cdn-icons-png.flaticon.com/512/0/747.png")),
                openingTimes: OpeningTimes(
                    monday: "09:00 - 19:00",
                    friday: "09:00 - 19:00",
                    sunday: "09:00 - 19:00",
                    tuesday: "09:00 - 19:00",
                    thursday: "09:00 - 19:00",
                    wednesday: "09:00 - 19:00",
                    saturday: "09:00 - 19:00"),
                distance: Distance(formatted: "5m", meters: 5),
                isLegacyPickup: nil)
        }
    }
}
