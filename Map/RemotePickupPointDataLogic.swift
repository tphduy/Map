//
//  RemotePickupPointDataLogic.swift
//  Map
//
//  Created by Duy Tran on 27/02/2023.
//

import Foundation
import Combine

/// An object provides methods for interacting with the pickup-point data in the remote database.
protocol RemotePickupPointDataLogicType {
    /// Gets the available pickup points around an address.
    /// - Parameters:
    ///   - address: The street name in a postal address.
    ///   - postalCode: The postal code in a postal address.
    ///   - city: The city name in a postal address.
    ///   - countryCode: The ISO country code for the country or region in a postal address, using the ISO 3166-1 alpha-2 standard.
    /// - Returns: A publisher that emits a list of pickup points or an error.
    func pickupPoints(
        address: String,
        postalCode: String,
        city: String,
        countryCode: String
    ) -> AnyPublisher<[PickupPoint], Error>

    /// Selects a pickup point as default.
    /// - Parameter id: A unique identifier of a pickup point.
    /// - Returns: A publisher that emits nothing or an error.
    func select(pickupPoint id: String) -> AnyPublisher<Void, Error>
}

/// An object provides methods for interacting with the pickup-point data in the remote database.
struct RemotePickupPointDataLogic: RemotePickupPointDataLogicType {
    // MARK: RemotePickupPointDataLogicType

    func pickupPoints(
        address: String,
        postalCode: String,
        city: String,
        countryCode: String
    ) -> AnyPublisher<[PickupPoint], Error> {
        var request = URLRequest(url: URL(string: "https://api.vestiairecollective.com/?m=getOrderRelayPoints&iPhoneVersion=5.111.0&lang=en&currency=EUR&u=1&v=1.1&a=iphone&id_site=1&h=86f2c751c47983da5eaafb47164e9c01&address=\(address.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)&city=\(city.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)&countryCode=\(countryCode.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)&postCode=\(postalCode.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)")!)
        request.addValue("br;q=1.0, gzip;q=0.9, deflate;q=0.8", forHTTPHeaderField: "Accept-Encoding")
        request.addValue("8337101413237827899", forHTTPHeaderField: "x-datadog-parent-id")
        request.addValue("rum", forHTTPHeaderField: "x-datadog-origin")
        request.addValue("Vestiaire Collective/5.111.0 (iPhone iOS:16.2 Scale:3.0)", forHTTPHeaderField: "User-Agent")
        request.addValue("en-FR;q=1.0, en;q=0.9", forHTTPHeaderField: "Accept-Language")
        request.addValue("942254501518430422", forHTTPHeaderField: "x-datadog-trace-id")
        request.addValue("1", forHTTPHeaderField: "x-datadog-sampling-priority")
        request.addValue("__cf_bm=x6oVE0L.ll4XqhBAHz.MfORGipS_xfZcM5clNkQbZSE-1677138173-0-ASWG9AJfjg3UcmHNZHzOv3LYFPv+ET8/m61YXfcpYxulhGKXNohB5m+TJrZc/+V3hXv+tpEpv2PPBHWC3yVnbD8=; vc_ck=1.en.EUR; vc_uid=18811483; EZBO_SESSION_vdclive=18811483.eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJjb20udmVzdGlhaXJlY29sbGVjdGl2ZSIsImlhdCI6MTY3NzEzODE2OSwibmJmIjoxNjc3MTM4MTY5LCJleHAiOjE2Nzk3MzAxNjksImRhdGEiOnsiaGFzaCI6IlwvQ09QV1Z4YTR1clRkVktvVHhoK3E4UjBpNHpXYjJIZiIsImlkIjoiMTg4MTE0ODMifX0.xWd73IK69ZQxKHV1y-1i96UDrh_98qaLPgBm18UtCXQ; EZBO_SESSION_vdclive_DEV=18811483.eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJjb20udmVzdGlhaXJlY29sbGVjdGl2ZSIsImlhdCI6MTY3NzEzODE2OSwibmJmIjoxNjc3MTM4MTY5LCJleHAiOjE2Nzk3MzAxNjksImRhdGEiOnsiaGFzaCI6IlwvQ09QV1Z4YTR1clRkVktvVHhoK3E4UjBpNHpXYjJIZiIsImlkIjoiMTg4MTE0ODMifX0.xWd73IK69ZQxKHV1y-1i96UDrh_98qaLPgBm18UtCXQ; vc_cc=eyJDQyI6IkZSIiwiZGlzcGxheU5hbWUiOnsiZnIiOiJGcmFuY2UiLCJlbiI6IkZyYW5jZSIsImRlIjoiRnJhbmtyZWljaCIsInVzIjoiRnJhbmNlIiwiaXQiOiJGcmFuY2lhIiwiZXMiOiJGcmFuY2lhIn19; id_partenaire=11; vc_rid=UC_IyTHV8JPRukNJn4yzFZFemp9OoqM9; test_ab=77; vc_country=SG;", forHTTPHeaderField: "Cookie")
        request.httpMethod = "GET"
        let result = URLSession
            .shared
            .dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: ResponseWrapper<[PickupPoint]>.self, decoder: JSONDecoder())
            .map(\.result)
            .eraseToAnyPublisher()
        return result
    }

    func select(pickupPoint id: String) -> AnyPublisher<Void, Error> {
        var request = URLRequest(url: URL(string: "https://api.vestiairecollective.com/?m=setOrderRelayPoint&iPhoneVersion=5.115.0&lang=en&currency=EUR&u=1&v=1.1&a=iphone&id_site=1&h=86f2c751c47983da5eaafb47164e9c01&null=null&reference=3055bd7e377ebb0557168e740c105dbd311956e3")!,timeoutInterval: Double.infinity)
        request.addValue("rum", forHTTPHeaderField: "x-datadog-origin")
        request.addValue("0", forHTTPHeaderField: "x-datadog-sampling-priority")
        request.addValue("Vestiaire Collective/5.115.0 (iPhone iOS:16.2 Scale:3.0)", forHTTPHeaderField: "User-Agent")
        request.addValue("en-FR;q=1.0, en;q=0.9", forHTTPHeaderField: "Accept-Language")
        request.addValue("br;q=1.0, gzip;q=0.9, deflate;q=0.8", forHTTPHeaderField: "Accept-Encoding")
        request.addValue("__cf_bm=92W1m0B6DUXr5Z_1OF0ePWXK1Um0gWR6RAL6VLGjN0s-1678423760-0-AQxyjhXf3gBsSsITP5+DYkkBB6cwlxr4VMYAU7VBJd6Ow8CCs0qFDxC4efeLYwgMYjMFb5++egiRkIb9MHlc8FA=; id_partenaire=11; vc_ck=1.en.EUR; vc_uid=18811483; EZBO_SESSION_vdclive=18811483.eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJjb20udmVzdGlhaXJlY29sbGVjdGl2ZSIsImlhdCI6MTY3ODQyMzc1NiwibmJmIjoxNjc4NDIzNzU2LCJleHAiOjE2ODEwMTU3NTYsImRhdGEiOnsiaGFzaCI6IlZjUW1RM0g0TVVsMEFwOTJyVkpIQndJMFZOV241dU1QIiwiaWQiOiIxODgxMTQ4MyJ9fQ.V_m0nGs8b6jtk_NSzvlYY0uMroHcAlZLobW1cmHsODQ; EZBO_SESSION_vdclive_DEV=18811483.eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJjb20udmVzdGlhaXJlY29sbGVjdGl2ZSIsImlhdCI6MTY3ODQyMzc1NiwibmJmIjoxNjc4NDIzNzU2LCJleHAiOjE2ODEwMTU3NTYsImRhdGEiOnsiaGFzaCI6IlZjUW1RM0g0TVVsMEFwOTJyVkpIQndJMFZOV241dU1QIiwiaWQiOiIxODgxMTQ4MyJ9fQ.V_m0nGs8b6jtk_NSzvlYY0uMroHcAlZLobW1cmHsODQ; vc_cc=eyJDQyI6IkZSIiwiZGlzcGxheU5hbWUiOnsiZnIiOiJGcmFuY2UiLCJlbiI6IkZyYW5jZSIsImRlIjoiRnJhbmtyZWljaCIsInVzIjoiRnJhbmNlIiwiaXQiOiJGcmFuY2lhIiwiZXMiOiJGcmFuY2lhIn19; vc_rid=mW40KTlaQClePi_kfhDq75HaC8E0I4Ng; test_ab=26; vc_country=SG;", forHTTPHeaderField: "Cookie")
        request.httpMethod = "GET"
        let result = URLSession
            .shared
            .dataTaskPublisher(for: request)
            .map { _ in () }
            .mapError { $0 as Error }
            .eraseToAnyPublisher()
        return result
    }

    struct ResponseWrapper<Result: Decodable>: Decodable {
        let result: Result
    }
}
