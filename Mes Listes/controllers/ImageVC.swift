//
//  ImageVC.swift
//  Mes Listes
//
//  Created by Anastasiia Tanczak on 11/12/2018.
//  Copyright © 2018 Ana Viktoriv. All rights reserved.
//

import UIKit

class ImageVC: UIViewController, UIGestureRecognizerDelegate {
    //MARK: - Constants
    var imageName: String?
    
    let margins: CGFloat = 10

    
    //MARK: - Global Variables
    let backgroundColorView: UIView = UIView()
    let helperFileManager = HelperFileManager()
    
    let mainImageView: UIImageView = {
        let view = UIImageView()
        view.backgroundColor = UIColor.white
        return view
    }()
    

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupLayouts()
      swipeUpAndDown()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UIView.animate(withDuration: 0.3) {
            self.backgroundColorView.alpha = 1.0
        }
        self.view.layoutIfNeeded()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    
    private func setupViews () {
        
        backgroundColorView.backgroundColor = UIColor.black.withAlphaComponent(0.34)
        backgroundColorView.isOpaque = false
        backgroundColorView.alpha = 0.0
        view.addSubview(backgroundColorView)
        
        //mainview
        if let imageNameUnwrapped = imageName {
            let newImage = helperFileManager.getImage(imageName: imageNameUnwrapped)
            mainImageView.image = newImage
            //mainImageView.contentMode =
        }
        view.addSubview(mainImageView)
    }
    
    private func setupLayouts () {
        //backgroundColorView
        backgroundColorView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            backgroundColorView.topAnchor.constraint(equalTo: self.view.topAnchor),
            backgroundColorView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            backgroundColorView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            backgroundColorView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
            ])
        
        //mainView
        mainImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            mainImageView.leadingAnchor.constraint(equalTo: backgroundColorView.leadingAnchor , constant: margins),
            mainImageView.trailingAnchor.constraint(equalTo: backgroundColorView.trailingAnchor, constant: -margins),
            mainImageView.heightAnchor.constraint(equalTo: mainImageView.widthAnchor),

           // mainImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            mainImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
            ])
    }

    
    func swipeUpAndDown () {
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(swipeAction))
        swipe.delegate = self
        swipe.direction = .down
        //swipe.direction = .up
        self.view.addGestureRecognizer(swipe)
        
    }
    
    @objc func swipeAction () {
    self.dismiss(animated: true, completion: nil)
    }

}
