//
//  PickupPointDataLogic.swift
//  Map
//
//  Created by Duy Tran on 27/02/2023.
//

import Foundation

protocol PickupPointDataLogic {

    func pickupPoints(around address: String)
}

struct DefaultPickupPointDataLogic: PickupPointDataLogic {
    // MARK: PickupPointDataLogic

    func pickupPoints(around address: String) {}
}
