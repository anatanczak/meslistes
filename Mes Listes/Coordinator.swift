//
//  Coordinator.swift
//  Mes Listes
//
//  Created by Anastasiia Tanczak on 17/08/2018.
//  Copyright © 2018 Ana Viktoriv. All rights reserved.
//

import Foundation
import UIKit

class Coordinator {
    
    var window: UIWindow!
    
    init(window: UIWindow) {

        self.window = window
        
        setup()
    }
    
    func setup() {
        
        setupCurrentFlow()
        
//        var isUserAuth = true
//
//        isUserAuth = false
//
//        if isUserAuth {
//            setupAuthFlow()
//        } else {
//            setupCurrentFlow()
//        }
    }
    
//    private func setupAuthFlow() {
//        let window = self.window
//        
//        let loginVC = UIViewController() //LoginViewController()
//        let navController = UINavigationController(rootViewController: loginVC)
//        window!.rootViewController = navController
//        window!.makeKeyAndVisible()
//    }
    
    private func setupCurrentFlow() {
        let window = self.window
        
        /*
         let storyboard = UIStoryboard(name: "Main", bundle: nil)
         if let viewController = storyboard.instantiateViewController(withIdentifier: "BookingDetailsViewController") as? BookingDetailsViewController {
         }*/
        
        let currentVC = ListViewController()
        let navController = UINavigationController(rootViewController: currentVC)
        window!.rootViewController = navController
        window!.makeKeyAndVisible()
        window!.backgroundColor = UIColor.red
        
        //make navigationbar transparent
        navController.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navController.navigationBar.shadowImage = UIImage()
        navController.navigationBar.isTranslucent = true
        
        // ajust title vertically
        navController.navigationBar.setTitleVerticalPositionAdjustment(5, for: .default)
        
        //change title font
//        let attributes = [NSAttributedStringKey.font: UIFont(name: "Zing Sans Rust Regular", size: 28.5)!, NSAttributedStringKey.foregroundColor: UIColor.black]
//        UINavigationBar.appearance().titleTextAttributes = attributes
    }
}
