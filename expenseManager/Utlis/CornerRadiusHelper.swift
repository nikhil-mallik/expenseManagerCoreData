//
//  CornerRadiusHelper.swift
//  expenseManager
//
//  Created by Nikhil Mallik on 10/06/23.
//

import Foundation
import UIKit

class CornerRadiusHelper {
    static func applyCornerRadius(_ view: UIView ) {
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = true
    }
}
