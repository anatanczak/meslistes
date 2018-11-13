//
//  DatePickerPopupViewController.swift
//  Mes Listes
//
//  Created by Anastasiia Tanczak on 18/06/2018.
//  Copyright © 2018 Ana Viktoriv. All rights reserved.
//

import UIKit



class DatePickerPopupViewController: UIViewController {
    
    

    //MARK: - Constants
    private let titleLabelTextOptions = ["calendar":"Add to calendar", "reminder":"Add to reminder"]
    private let mainViewHeight: CGFloat = 217
    private let mainViewWidth: CGFloat = 300
    private let titleLabelHeight: CGFloat = 40
    private let buttonHeight: CGFloat = 45
    private let titleLabelBackgroundColor = UIColor.init(red: 240/255, green: 214/255, blue: 226/255, alpha: 1)
    private let alertViewGrayColor = UIColor(red: 224.0/255.0, green: 224.0/255.0, blue: 224.0/255.0, alpha: 1)
    
    //MARK: - VARIABLES
    var dateForCalendar = false
    var setReminder: ((_ components: DateComponents) -> ())?
    var saveEventToCalendar: ((_ date: Date) ->())?

    
    
    //MARK: - views
    let titleLabel = UILabel()
    let datePicker = UIDatePicker()
    let okButton = UIButton()
    let cancelButton = UIButton()
    
    let backgroundColorView: UIView = UIView()
    
    let mainView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.layer.cornerRadius = 10
        view.clipsToBounds = true
        return view
    }()
    
    
    
    lazy var buttonStackView: UIStackView  = {
        let stackView = UIStackView(arrangedSubviews: [cancelButton,
                                                       okButton])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 0
        return stackView
    }()
    
   
    //MARK: - LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupLayouts()

    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UIView.animate(withDuration: 1) {
            self.backgroundColorView.alpha = 1.0
            self.mainView.snp.updateConstraints({ (make) in
            })
        }
        self.view.layoutIfNeeded()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        cancelButton.addBorder(side: .Top, color: alertViewGrayColor, width: 1)
        cancelButton.addBorder(side: .Right, color: alertViewGrayColor, width: 0.5)
        okButton.addBorder(side: .Top, color: alertViewGrayColor, width: 1)
        okButton.addBorder(side: .Left, color: alertViewGrayColor, width: 0.5)
    }
    
    
    private func setupViews () {
        
        //backgroundColorView
        backgroundColorView.backgroundColor = UIColor.black.withAlphaComponent(0.34)
        backgroundColorView.isOpaque = false
        backgroundColorView.alpha = 0.0
        view.addSubview(backgroundColorView)
        
        //mainview
        view.addSubview(mainView)
        
        //titleLabel
        
        titleLabel.backgroundColor = titleLabelBackgroundColor
        titleLabel.textAlignment = .center
        if dateForCalendar == true{
            titleLabel.text = titleLabelTextOptions["calendar"]
        }else{
            titleLabel.text = titleLabelTextOptions["reminder"]
        }
        mainView.addSubview(titleLabel)
        
        //datePicker
        mainView.addSubview(datePicker)
        
        //save button
        okButton.setTitle("OK", for: .normal)
        okButton.backgroundColor = UIColor.clear
        okButton.setTitleColor(UIColor.black, for: .normal)
        okButton.addTarget(self, action: #selector(oKButtonAction), for: .touchUpInside)
        
        
        //cancel button
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.setTitleColor(UIColor.black, for: .normal)
        cancelButton.backgroundColor = UIColor.clear
        cancelButton.addTarget(self, action: #selector(cancelButtonAction), for: .touchUpInside)
        mainView.addSubview(buttonStackView)
    }
    
    private func setupLayouts () {
        //backgroundColorView
        backgroundColorView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            backgroundColorView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundColorView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundColorView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundColorView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
            ])
        
        //mainView
        mainView.translatesAutoresizingMaskIntoConstraints = false
        
         NSLayoutConstraint.activate([
            mainView.heightAnchor.constraint(equalToConstant: mainViewHeight),
            mainView.widthAnchor.constraint(equalToConstant: mainViewWidth),
            mainView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            mainView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
             ])
        
        //titleLabel
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.heightAnchor.constraint(equalToConstant: titleLabelHeight),
           titleLabel.leadingAnchor.constraint(equalTo: mainView.leadingAnchor),
           titleLabel.trailingAnchor.constraint(equalTo: mainView.trailingAnchor),
           titleLabel.topAnchor.constraint(equalTo: mainView.topAnchor)
            ])
        
        //datePicker
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
             datePicker.topAnchor.constraint(equalTo: titleLabel.bottomAnchor),
             datePicker.bottomAnchor.constraint(equalTo: buttonStackView.topAnchor),
             datePicker.leadingAnchor.constraint(equalTo: view.leadingAnchor),
             datePicker.trailingAnchor.constraint(equalTo: view.trailingAnchor)
            ])
        
        //buttonStackView
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            buttonStackView.heightAnchor.constraint(equalToConstant: buttonHeight),
            buttonStackView.leadingAnchor.constraint(equalTo: mainView.leadingAnchor),
            buttonStackView.trailingAnchor.constraint(equalTo: mainView.trailingAnchor),
            buttonStackView.bottomAnchor.constraint(equalTo: mainView.bottomAnchor)
            ])
        

        
    }
    
    //MARK: - ACTIONS
    @objc func oKButtonAction(_ sender: UIButton) {
        if dateForCalendar == true {
            saveEventToCalendar!(datePicker.date)
        }else{
            let components = datePicker.calendar.dateComponents([.day, .month, .year, .hour, .minute], from: datePicker.date)
            setReminder!(components)
        }
        dismiss(animated: true, completion: nil)
        
    }
    
    @objc func cancelButtonAction () {
        
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            guard let `self` = self else { return }
            self.backgroundColorView.alpha = 0.0
        }) { [weak self]  (isComplete) in
            guard let `self` = self else { return }
            self.dismiss(animated: true, completion: nil)
        }
        
    }
}
