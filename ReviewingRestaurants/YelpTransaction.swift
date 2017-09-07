//
//  YelpTransaction.swift
//  ReviewingRestaurants
//
//  Created by David Anglin on 9/7/17.
//  Copyright © 2017 David Anglin. All rights reserved.
//

import Foundation

enum YelpTransaction {
    case pickup, delivery, restaurantReservation
}

extension YelpTransaction {
    init?(rawValue: String) {
        switch rawValue {
        case "pickup": self = .pickup
        case "delivery": self = .delivery
        case "restaurant_reservation": self = .restaurantReservation
        default: return nil
        }
    }
}
