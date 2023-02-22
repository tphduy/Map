//
//  PickupPointMapAnnotation.swift
//  Map
//
//  Created by Duy Tran on 22/02/2023.
//

import SwiftUI

struct PickupPointMapAnnotation: View {
    var body: some View {
        VStack(spacing: 0) {
              Image(systemName: "mappin.circle.fill")
                .font(.title)

              Image(systemName: "arrowtriangle.down.fill")
                .font(.caption)
                .offset(x: 0, y: -5)
            }
    }
}

struct PickupPointMapAnnotation_Previews: PreviewProvider {
    static var previews: some View {
        PickupPointMapAnnotation()
    }
}
