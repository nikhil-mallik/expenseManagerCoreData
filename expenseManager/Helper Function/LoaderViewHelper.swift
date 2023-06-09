//
//  LoaderViewHelper.swift
//  expenseManager
//
//  Created by Nikhil Mallik on 07/06/23.
//

import Foundation
import UIKit

class LoaderViewHelper {
    private static var loaderView: UIView?
        
        static func showLoader(on view: UIView) {
            let loaderSize: CGFloat = 60
            let loaderView = UIView(frame: CGRect(x: 0, y: 0, width: loaderSize, height: loaderSize))
            loaderView.backgroundColor = UIColor(white: 0, alpha: 0.8)
            loaderView.layer.cornerRadius = loaderSize / 2
            loaderView.center = view.center
            
            let activityIndicator = UIActivityIndicatorView(style: .medium)
            activityIndicator.color = UIColor.white
            activityIndicator.center = CGPoint(x: loaderSize / 2, y: loaderSize / 2)
            activityIndicator.startAnimating()
            
            loaderView.addSubview(activityIndicator)
            view.addSubview(loaderView)
            
            self.loaderView = loaderView
        }
        
        static func hideLoader() {
            loaderView?.removeFromSuperview()
            loaderView = nil
        }
}
