//
//  VCCheckboxToggleStyle.swift
//  Map
//
//  Created by Duy Tran on 26/02/2023.
//

import SwiftUI

struct VCCheckboxToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button {
            configuration.isOn.toggle()
        } label: {
            HStack {
                Image(systemName: configuration.isOn ? "circle.inset.filled" : "circle")
                configuration.label
            }
        }

    }
}
