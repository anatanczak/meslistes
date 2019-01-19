//
//  UserTextInputViewController.swift
//  Mes Listes
//
//  Created by Anastasiia Tanczak on 18/08/2018.
//  Copyright © 2018 Ana Viktoriv. All rights reserved.
//

import UIKit

class UserTextInputViewController: UIViewController {
   
    //MARK: Constants
    
    
    let iconNamesArray = ["todo-icon", "star-icon", "airplane-icon", "shopping-cart-icon", "home-icon", "clothes-icon", "gift-icon", "bag-icon", "light-bulb-icon", "sport-icon", "cooking-icon", "book-icon"]
    
    let roseIconNamesArray = ["todo-icon-rose", "star-icon-rose", "airplane-icon-rose", "shopping-cart-icon-rose", "home-icon-rose", "clothes-icon-rose", "gift-icon-rose", "bag-icon-rose", "light-bulb-icon-rose", "sport-icon-rose", "cooking-icon-rose", "book-icon-rose"]
    let alertViewGrayColor = UIColor(red: 224.0/255.0, green: 224.0/255.0, blue: 224.0/255.0, alpha: 1)
    
    let textFieldPlaceHolderTextLitteral = "name your new list..."
    let textFieldPlaceholderTextColor = UIColor.init(red: 140/255, green: 140/255, blue: 140/255, alpha: 1)
    let textFieldLeftPadding: CGFloat = 10
    let textFieldBorderWidth: CGFloat = 0.5
    let textFieldBorderColor = UIColor.init(red: 200/255, green: 199/255, blue: 204/255, alpha: 1)
    let textFieldFontSize: CGFloat = 18
    
    let iconTitleLabelName = "Chose your own icon"
    let iconTitleLabelTextColor = UIColor.init(red: 180/255, green: 206/255, blue: 215/255, alpha: 1)
    
    
    //MARK: - GLOBAL VARIABLES
    
    var createListe: ((_ liste: Liste)->())?
    /// property that indicates the icon name to be shown if any icon was selected
    var iconName: String?
    var selectedIndexPath: IndexPath?

    
    //MARK: - Views
    
    let backgroundColorView: UIView = UIView()
    
    let mainView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.layer.cornerRadius = 10
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

    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let itemWidthHeight = 40
        
        layout.itemSize = CGSize(width: itemWidthHeight, height: itemWidthHeight)
        layout.minimumLineSpacing = 2
        layout.minimumInteritemSpacing = 1
        
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.white
        
        return collectionView
    }()
    
    let textFieldForInput = UITextField()
    let iconTitleLabel = UILabel()
    let subViewForCollectionView = UIView()
    
    //var collectionView: UICollectionView?
    let okButton = UIButton()
    let cancelButton = UIButton()
    
    

    //MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        //setupCollectionView()
        setupLayouts()
        textFieldForInput.becomeFirstResponder()
    
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

    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
    }
    
    private func setupViews () {
   
        backgroundColorView.backgroundColor = UIColor.black.withAlphaComponent(0.34)
        backgroundColorView.isOpaque = false
        backgroundColorView.alpha = 0.0
        view.addSubview(backgroundColorView)
        
        //mainview
        view.addSubview(mainView)
        
        //textField
        textFieldForInput.delegate = self
        textFieldForInput.attributedPlaceholder = NSAttributedString(string: textFieldPlaceHolderTextLitteral, attributes: [
            .foregroundColor: textFieldPlaceholderTextColor,
            .font: UIFont.systemFont(ofSize: textFieldFontSize, weight: .light),
            ])
       // textFieldForInput.adjustsFontForContentSizeCategory = true
        textFieldForInput.setLeftPaddingPoints(textFieldLeftPadding)
        textFieldForInput.backgroundColor = .clear
        textFieldForInput.layer.borderWidth = textFieldBorderWidth
        textFieldForInput.layer.borderColor = textFieldBorderColor.cgColor
        textFieldForInput.font = UIFont.systemFont(ofSize: textFieldFontSize, weight: .light)
        textFieldForInput.returnKeyType = .done

//        //iconTitleLabel
//        iconTitleLabel.text = iconTitleLabelName
//        //iconTitleLabel.textAlignment = .center
//        iconTitleLabel.backgroundColor = .clear
//        iconTitleLabel.textColor = iconTitleLabelTextColor
//        iconTitleLabel.font = UIFont.preferredFont(forTextStyle: .body)
//        iconTitleLabel.adjustsFontForContentSizeCategory = true
        
//        //subViewForCollectionView
//        subViewForCollectionView.backgroundColor = .clear
//
        // collectionView
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        
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


        [textFieldForInput, buttonStackView, collectionView].forEach { mainView.addSubview($0) }
        //mainView.addSubview()
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
        mainView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mainView.heightAnchor.constraint(greaterThanOrEqualToConstant: 1),
            mainView.widthAnchor.constraint(equalToConstant: 270),
            mainView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            mainView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: -100)
            ])
        
        //textFieldForInput
        textFieldForInput.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textFieldForInput.topAnchor.constraint(equalTo: mainView.topAnchor, constant: 10),
            textFieldForInput.leadingAnchor.constraint(equalTo: mainView.leadingAnchor, constant: 16),
            textFieldForInput.trailingAnchor.constraint(equalTo: mainView.trailingAnchor, constant: -16)
            ])
        
        //collectionView
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.heightAnchor.constraint(equalToConstant: 83),
            collectionView.topAnchor.constraint(equalTo: textFieldForInput.bottomAnchor, constant: 10),
            collectionView.leadingAnchor.constraint(equalTo: mainView.leadingAnchor, constant: 10),
            collectionView.trailingAnchor.constraint(equalTo: mainView.trailingAnchor, constant: -10)
            
            ])
        //buttonStackView
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            buttonStackView.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 10),
            buttonStackView.bottomAnchor.constraint(equalTo: mainView.bottomAnchor),
            buttonStackView.leadingAnchor.constraint(equalTo: mainView.leadingAnchor),
            buttonStackView.trailingAnchor.constraint(equalTo: mainView.trailingAnchor)
            ])
        
        
        
        
        
//        backgroundColorView.snp.makeConstraints { (make) in
//            make.left.top.right.bottom.equalToSuperview()
//        }
//
//        mainView.snp.makeConstraints { (make) in
//           // make.top.equalToSuperview().offset(self.view.bounds.height/2)
//            make.centerX.equalToSuperview()
//            make.centerY.equalToSuperview().offset(-100)
//            //make.size.equalTo(CGSize(width: 270, height: 200))
//        }
//        textFieldForInput.snp.makeConstraints { (make) in
//            make.centerX.equalToSuperview()
//            make.top.equalToSuperview().offset(16.0)
//            make.left.equalToSuperview().offset(16)
//            make.right.equalToSuperview().offset(-16)
//            make.width.equalTo(238)
//            make.height.equalTo(24)
//        }
//        collectionView?.snp.makeConstraints({ [weak self]  (make) in
//            guard let `self` = self else { return }
//            make.top.equalTo(self.textFieldForInput.snp.bottom).offset(10)
//            make.left.equalToSuperview().offset(10.0)
//            make.centerX.equalToSuperview()
//            make.height.equalTo(83)
//        })
//        buttonStackView.snp.makeConstraints { [weak self] (make) in
//            guard let `self` = self else { return }
//            make.left.bottom.right.equalToSuperview()
//            make.top.equalTo(self.collectionView!.snp.bottom).offset(10)
//            make.height.equalTo(44)
//        }
    }

    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        cancelButton.addBorder(side: .Top, color: alertViewGrayColor, width: 1)
        cancelButton.addBorder(side: .Right, color: alertViewGrayColor, width: 0.5)
        okButton.addBorder(side: .Top, color: alertViewGrayColor, width: 1)
        okButton.addBorder(side: .Left, color: alertViewGrayColor, width: 0.5)
    }

    //MARK: - Button Actions
    @objc func oKButtonAction () {
        saveInput()
    }
    
    @objc func cancelButtonAction () {
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            guard let `self` = self else { return }
            self.backgroundColorView.alpha = 0.0
        }) { [weak self]  (isComplete) in
            guard let `self` = self else { return }
            self.dismiss(animated: true, completion: nil)
            self.textFieldForInput.resignFirstResponder()
        }
    }
    
    func saveInput () {
        
        if textFieldForInput.text != "" && textFieldForInput.text != nil {
            let newListe = Liste()
            newListe.name = textFieldForInput.text!
            if let iconNameLocal = iconName {
                newListe.iconName = iconNameLocal
            }
            createListe!(newListe)
            
            UIView.animate(withDuration: 0.3, animations: { [weak self] in
                guard let `self` = self else { return }
                self.backgroundColorView.alpha = 0.0
            }) { [weak self]  (isComplete) in
                guard let `self` = self else { return }
                self.dismiss(animated: true, completion: nil)
                self.textFieldForInput.resignFirstResponder()
            }
        }else if textFieldForInput.text == "" && textFieldForInput.text != nil{
            UIView.animate(withDuration: 2, animations: { [weak self] in
                guard let `self` = self else { return }
                self.textFieldForInput.backgroundColor = UIColor.init(red: 240/255, green: 214/255, blue: 226/255, alpha: 1)
                self.view.layoutIfNeeded()
            })
            
            UIView.animate(withDuration: 2, animations: { [weak self] in
                guard let `self` = self else { return }
                self.textFieldForInput.backgroundColor = .clear
                self.view.layoutIfNeeded()
            })
            
        }else{
            print("text field is nill")
        }
    }
}

//MARK: - TextFieldDelegate
extension UserTextInputViewController: UITextFieldDelegate {

   
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            
            if textField == textFieldForInput {
                saveInput()
                return true
            }
            return false

    }
}

//MARK: - UICollectionViewDelegate and DataSource
extension UserTextInputViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 12
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        cell.layer.contents = UIImage(named: iconNamesArray[indexPath.row])?.cgImage
        cell.contentMode = .scaleAspectFit
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if let unwrappedSelectedIndexPath = selectedIndexPath {

            let cellToUnselect = collectionView.cellForItem(at: unwrappedSelectedIndexPath)

            cellToUnselect?.layer.contents = UIImage (named: iconNamesArray[unwrappedSelectedIndexPath.row])?.cgImage
            cellToUnselect?.contentMode = .scaleAspectFit
        }
        let cell = collectionView.cellForItem(at: indexPath)
       
        cell?.layer.contents = UIImage(named: roseIconNamesArray[indexPath.row])?.cgImage
        cell?.contentMode = .scaleAspectFit
        selectedIndexPath = indexPath
        iconName = iconNamesArray[indexPath.row]
    }

}



