//
//  PickupPointMap.swift
//  Map
//
//  Created by Duy Tran on 20/02/2023.
//

import SwiftUI
import MapKit
import Combine

struct PickupPointMap: View {
    // MARK: States

    var points: [PickupPoint]

    @Binding var center: PickupPoint?

    @Binding var selected: PickupPoint.ID?

    /// A  rectangular geographic region that centers the map.
    ///
    /// The default value is Apple Park.
    @State var region: MKCoordinateRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.334_900, longitude: -122.009_020),
        latitudinalMeters: 1000,
        longitudinalMeters: 1000
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
        .onAppear {
            guard let center else { return }
            focus(to: center, animated: false)
        }
        .onChange(of: center) { (newValue) in
            guard let newValue else { return }
            focus(to: newValue)
        }
        .onChange(of: selected) { (newValue) in
            guard let newValue else { return }
            focus(to: newValue)
        }
    }

    // MARK: Utilities

    func centerAndNormalPoints() -> [PickupPoint] {
        guard let center else { return points }
        return [center] + points
    }

    func centerAnnotation(at point: PickupPoint) -> some MapAnnotationProtocol {
        MapAnnotation(coordinate: point.location.coordinate) {
            PickupPointMapAnnotation()
                .foregroundColor(.red)
        }
    }

    func selectedAnnotation(at point: PickupPoint) -> some MapAnnotationProtocol {
        MapAnnotation(coordinate: point.location.coordinate) {
            PickupPointMapAnnotation()
                .foregroundColor(.green)
                .onTapGesture { selected = point.id }
        }
    }

    func unselectedAnnotation(at point: PickupPoint) -> some MapAnnotationProtocol {
        MapAnnotation(coordinate: point.location.coordinate) {
            PickupPointMapAnnotation()
                .foregroundColor(.black)
                .onTapGesture { selected = point.id }
        }
    }

    func annotation(for point: PickupPoint) -> some MapAnnotationProtocol {
        let isCenter = point == center
        let isSelected = point.id == selected
        switch (isCenter, isSelected) {
        case (true, _):
            return AnyMapAnnotationProtocol(centerAnnotation(at: point))
        case (false, true):
            return AnyMapAnnotationProtocol(selectedAnnotation(at: point))
        case (false, false):
            return AnyMapAnnotationProtocol(unselectedAnnotation(at: point))
        }
    }

    // MARK: State Changes

    func focus(to id: PickupPoint.ID, animated: Bool = true) {
        guard let point = points.first(where: { $0.id == id }) else { return }
        focus(to: point, animated: animated)
    }

    func focus(to point: PickupPoint, animated: Bool = true) {
        let center = point.location.coordinate
        let task = { region = MKCoordinateRegion(center: center, span: region.span) }
        animated ? withAnimation(.default, task) : task()
    }
}

struct CarrierMap_Previews: PreviewProvider {
    static var previews: some View {
        PickupPointMap(
            points: [.Preview.theDukeOfEdinburgh, .Preview.wolfeLiquor],
            center: .constant(.Preview.applePark),
            selected: .constant(PickupPoint.Preview.theDukeOfEdinburgh.id)
        )
    }
}
