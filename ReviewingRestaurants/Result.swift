//
//  Result.swift
//  ReviewingRestaurants
//
//  Created by David Anglin on 9/11/17.
//  Copyright © 2017 David Anglin. All rights reserved.
//

import Foundation


enum Result<T, U> where U: Error {
    case success(T)
    case failure(U)
}

















