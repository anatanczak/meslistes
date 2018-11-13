//
//  UIViewcornerRadius.swift
//  Mes Listes
//
//  Created by Anastasiia Tanczak on 13/11/2018.
//  Copyright © 2018 Ana Viktoriv. All rights reserved.
//

import UIKit

extension UIView {
    func roundCorners(corners:UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }
}
