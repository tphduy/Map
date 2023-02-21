//
//  AnyMapAnnotationProtocol.swift
//  Map
//
//  Created by Duy Tran on 21/02/2023.
//

import SwiftUI
import MapKit

struct AnyMapAnnotationProtocol: MapAnnotationProtocol {
    let _annotationData: _MapAnnotationData
    let value: Any

    init<WrappedType: MapAnnotationProtocol>(_ value: WrappedType) {
        self.value = value
        _annotationData = value._annotationData
    }
}
