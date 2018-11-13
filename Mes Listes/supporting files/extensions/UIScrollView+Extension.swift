//
//  UIScrollView+Extension.swift
//  Costless
//
//  Created by Mikhail Panfilov on 12/22/17.
//  Copyright © 2017 Sannacode. All rights reserved.
//

import UIKit

extension UIScrollView {
    func setContentInsetAndScrollIndicatorInsets(edgeInsets: UIEdgeInsets) {
        self.contentInset = edgeInsets
        self.scrollIndicatorInsets = edgeInsets
    }
}
