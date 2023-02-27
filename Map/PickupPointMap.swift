//
//  PickupPointMap.swift
//  Map
//
//  Created by Duy Tran on 20/02/2023.
//

import SwiftUI
import MapKit

struct PickupPointMap: View {
    // MARK: States

    @State var points: [PickupPoint] = []

    @Binding var center: PickupPoint?

    @Binding var selected: PickupPoint?

    /// A  rectangular geographic region that centers the map.
    ///
    /// The default value is Apple Park.
    @State var region: MKCoordinateRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.334_900, longitude: -122.009_020),
        latitudinalMeters: 1200,
        longitudinalMeters: 1200
    )

    // MARK: View

    var body: some View {
        Map(
            coordinateRegion: $region,
            showsUserLocation: false,
            userTrackingMode: .constant(.follow),
            annotationItems: centerAndNormalPoints(),
            annotationContent: annotation(for:)
        )
        .onChange(of: center) { newValue in
            guard let center = newValue?.location.coordinate else { return }
            region = MKCoordinateRegion(center: center, span: region.span)
        }
    }

    // MARK: Utilities

    func point(at index: Int) -> PickupPoint? {
        guard points.startIndex <= index, index < points.endIndex else { return nil }
        return points[index]
    }

    func isPointSelected(_ point: PickupPoint) -> Bool {
        point == selected
    }

    func tint(of point: PickupPoint) -> Color {
        isPointSelected(point) ? .green : .black
    }

    func centerAndNormalPoints() -> [PickupPoint] {
        let centerLocation = PickupPoint.Location(
            latitude: region.center.latitude,
            longitude: region.center.longitude)
        let centerPoint = PickupPoint(location: centerLocation)
        return [centerPoint] + points
    }

    func centerAnnotation(at coordinate: CLLocationCoordinate2D) -> some MapAnnotationProtocol {
        MapMarker(coordinate: coordinate, tint: .red)
    }

    func selectedAnnotation(at coordinate: CLLocationCoordinate2D) -> some MapAnnotationProtocol {
        MapAnnotation(coordinate: coordinate) {
            PickupPointMapAnnotation()
                .foregroundColor(.green)
        }
    }

    func unselectedAnnotation(at coordinate: CLLocationCoordinate2D) -> some MapAnnotationProtocol {
        MapAnnotation(coordinate: coordinate) {
            PickupPointMapAnnotation()
                .foregroundColor(.black)
        }
    }

    func annotation(for point: PickupPoint) -> some MapAnnotationProtocol {
        let isCenter = point == center
        let isSelected = isPointSelected(point)
        let coordinate = point.location.coordinate
        switch (isCenter, isSelected) {
        case (true, _):
            return AnyMapAnnotationProtocol(centerAnnotation(at: coordinate))
        case (false, true):
            return AnyMapAnnotationProtocol(selectedAnnotation(at: coordinate))
        case (false, false):
            return AnyMapAnnotationProtocol(unselectedAnnotation(at: coordinate))
        }
    }
}

struct CarrierMap_Previews: PreviewProvider {
    static var previews: some View {
        PickupPointMap(
            points: [.Preview.theDukeOfEdinburgh, .Preview.wolfeLiquor],
            center: .constant(.Preview.applePark),
            selected: .constant(.Preview.theDukeOfEdinburgh)
        )
    }
}
