//
//  MapApp.swift
//  Map
//
//  Created by Duy Tran on 24/01/2023.
//

import SwiftUI

@main
struct MapApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                CarrierPicker(
                    referencePoint: .Preview.applePark,
                    points: [
                        .Preview.theDukeOfEdinburgh,
                        .Preview.wolfeLiquor
                    ],
                    selectedIndexes: [1]
                )
            }
        }
    }
}
