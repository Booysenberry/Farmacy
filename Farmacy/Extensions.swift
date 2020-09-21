//
//  Extensions.swift
//  WeedPanel
//
//  Created by Brad Booysen on 1/11/19.
//  Copyright © 2019 Booysenberry. All rights reserved.
//

import Foundation
import UIKit

// Scroll back to the top of scrollview when user changes filter
extension UIScrollView {
    func scrollToTop() {
        let desiredOffset = CGPoint(x: 0, y: -contentInset.top)
        setContentOffset(desiredOffset, animated: true)
   }
}
