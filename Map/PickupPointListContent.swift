//
//  PickupPointListContent.swift
//  Map
//
//  Created by Duy Tran on 25/02/2023.
//

import SwiftUI

struct PickupPointListContent: View {
    // MARK: States

    var points: [PickupPoint] = []

    @Binding var selected: PickupPoint?

    // MARK: View
    
    var body: some View {
        ForEach(points) { (point: PickupPoint) in
            PickupPointRow(
                point: point,
                isSelected: point == selected
            )
            .listRowBackground(Color.clear)
        }
    }

    // MARK: Utilities
}

struct PickupPointList_Previews: PreviewProvider {
    static var previews: some View {
        List {
            PickupPointListContent(
                points: [
                    .Preview.applePark,
                    .Preview.theDukeOfEdinburgh,
                    .Preview.wolfeLiquor
                ],
                selected: .constant(.Preview.theDukeOfEdinburgh)
            )
        }
    }
}
