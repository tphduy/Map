//
//  PickupPointRow.swift
//  Map
//
//  Created by Duy Tran on 25/02/2023.
//

import SwiftUI
import Kingfisher

struct PickupPointRow: View {
    // MARK: States

    @State var point: PickupPoint

    @State var isSelected: Bool = false

    // MARK: View
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Toggle(isOn: $isSelected) {}
                .toggleStyle(VCCheckboxToggleStyle())
                .foregroundColor(.black)
            VStack(alignment: .leading, spacing: 8) {
                KFImage(point.carrier?.iconURL)
                    .resizable()
                    .frame(width: 24, height: 24)
                point.carrier?.name.map { Text($0).fontWeight(.bold) }
                point.name.map { Text($0) }
                point.address.map { Text($0) }
            }
        }
    }
}

struct PickupPointRow_Previews: PreviewProvider {
    static var previews: some View {
        PickupPointRow(point: .Preview.applePark)
    }
}
