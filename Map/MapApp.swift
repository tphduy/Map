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
            if #available(iOS 16.0, *) {
                NavigationStack {
                    PickupPointPicker(viewModel: PickupPointPickerViewModel(keywords: "13 Place Lachambeaudie, Paris, France"))
                }
            } else {
                NavigationView {
                    PickupPointPicker(viewModel: PickupPointPickerViewModel(keywords: "13 Place Lachambeaudie, Paris, France"))
                }
            }
        }
    }
}
