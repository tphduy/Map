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
            Text("Welcome")
                .sheet(isPresented: .constant(true), content: { pickupPointPicker })
        }
    }

    var pickupPointPicker: some View {
        NavigationStack {
            PickupPointPicker()
        }
    }
}
