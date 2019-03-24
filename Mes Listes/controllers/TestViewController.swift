//
//  TestViewController.swift
//  Mes Listes
//
//  Created by Anastasiia Tanczak on 23/03/2019.
//  Copyright © 2019 Ana Viktoriv. All rights reserved.
//

import UIKit

class TestViewController: UIViewController {
    
    let button = UIButton()
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
       view.backgroundColor = .yellow
        button.backgroundColor = .red
        button.addTarget(self, action: #selector(action), for: .touchUpInside)
        
        view.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: 50),
            button.heightAnchor.constraint(equalToConstant: 50),
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.centerYAnchor.constraint(equalTo: view.centerYAnchor)
            ])
        
    }
    
    @objc func  action () {
    print ("dismissed")
        self.dismiss(animated: true, completion: nil)
    }

}
