//
//  PickupPointMap.swift
//  Map
//
//  Created by Duy Tran on 20/02/2023.
//

import SwiftUI
import MapKit
import Combine

/// A view that displays the locations of pickup points on the map.
struct PickupPointMap: View {
    // MARK: States

    /// A list of pickup points.
    let points: [PickupPoint]

    /// The center of an area to display on the map.
    ///
    /// Changes this property to a new value will make the map focus on the new area with the same span.
    @Binding var center: PickupPoint?

    /// A unique identifier of a pickup point that is selected.
    ///
    /// Changes this property to a new value will trigger the map to redraw the annotations.
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

    /// Returns a list of pickup points, the first element is the `center` if it is some and the following are `points`.
    /// - Returns: A list of pickup points.
    func centerAndNormalPoints() -> [PickupPoint] {
        guard let center else { return points }
        return [center] + points
    }

    /// Returns an annotation for the center pickup point.
    /// - Parameter point: A pickup point that is at the center of the map.
    /// - Returns: An annotation.
    func centerAnnotation(at point: PickupPoint) -> some MapAnnotationProtocol {
        MapAnnotation(coordinate: point.location.coordinate) {
            PickupPointMapAnnotation()
                .foregroundColor(.red)
        }
    }

    /// Returns an annotation for the selected pickup point.
    /// - Parameter point: A pickup point that is selected.
    /// - Returns: An annotation.
    func selectedAnnotation(at point: PickupPoint) -> some MapAnnotationProtocol {
        MapAnnotation(coordinate: point.location.coordinate) {
            PickupPointMapAnnotation()
                .foregroundColor(.green)
                .onTapGesture { selected = point.id }
        }
    }

    /// Returns an annotation for the unselected pickup point.
    /// - Parameter point: A pickup point that is unselected.
    /// - Returns: An annotation.
    func unselectedAnnotation(at point: PickupPoint) -> some MapAnnotationProtocol {
        MapAnnotation(coordinate: point.location.coordinate) {
            PickupPointMapAnnotation()
                .foregroundColor(.black)
                .onTapGesture { selected = point.id }
        }
    }

    /// Returns an annotation for a pickup point.
    /// - Parameter point: A prearranged place where you go to collect things.
    /// - Returns: An annotation.
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

    /// Replaces the region with a new value whose center is the location of a pickup point that has the same identifier.
    /// - Parameters:
    ///   - id: A unique identifier of a pickup point.
    ///   - animated: Specifies `true` to animation the updatatio, otherwise, `false`.
    func focus(to id: PickupPoint.ID, animated: Bool = true) {
        guard let point = points.first(where: { $0.id == id }) else { return }
        focus(to: point, animated: animated)
    }

    /// Replaces the region with a new value whose center is the pickup point location with the same span.
    /// - Parameters:
    ///   - point: A prearranged place where you go to collect things.
    ///   - animated: Specifies `true` to animation the updatatio, otherwise, `false`.
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
