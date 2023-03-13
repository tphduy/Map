//
//  VCCheckboxToggleStyle.swift
//  Map
//
//  Created by Duy Tran on 26/02/2023.
//

import SwiftUI

/// A custom appearance and behavior of a toggle following Vestiaire Collective's design system.
struct VCCheckboxToggleStyle: ToggleStyle {
    // MARK: ToggleStyle
    
    func makeBody(configuration: Configuration) -> some View {
        Button {
            configuration.isOn.toggle()
        } label: {
            HStack {
                if #available(iOS 15, *) {
                    Image(systemName: configuration.isOn ? "circle.inset.filled" : "circle")
                } else {
                    Image(systemName: configuration.isOn ? "circle.circle.fill" : "circle")
                }
                configuration.label
            }
        }
    }
}
