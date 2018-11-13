//
//  TextFieldPaddingExtension.swift
//  Mes Listes
//
//  Created by Anastasiia Tanczak on 21/08/2018.
//  Copyright © 2018 Ana Viktoriv. All rights reserved.
//
import UIKit


extension UITextField {
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    func setRightPaddingPoints(_ amount:CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
}
