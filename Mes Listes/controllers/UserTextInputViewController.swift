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
    
    

    let alertViewGrayColor = UIColor(named: "userTextInputVCbuttonsBorder")
    
    let textFieldPlaceHolderTextLitteral = NSLocalizedString ("name your new list...", comment: "name your new list")
    let textFieldPlaceholderTextColor = UIColor.init(red: 140/255, green: 140/255, blue: 140/255, alpha: 1)
    let textFieldLeftPadding: CGFloat = 10
    let textFieldBorderWidth: CGFloat = 0.5
//DARK
    let textFieldBorderColor = UIColor.init(red: 200/255, green: 199/255, blue: 204/255, alpha: 1)
    let textFieldFontSize: CGFloat = 18
    
    
    //MARK: - GLOBAL VARIABLES
    
    var createListe: ((_ liste: Liste)->())?
    /// property that indicates the icon name to be shown if any icon was selected
    var iconName: String?
    var selectedIndexPath: IndexPath?
    ///property that indicats if the list name is being changed (true) or created for the fist time (false)
    var changingNameAndIcon = false
    var listeToUpdate: Liste?

    var changeName: ((_ liste: Liste, _ newName: String, _ newIconName: String )->())?
    
    //MARK: - Views
    
    let backgroundColorView: UIView = UIView()
    
   let mainView: UIView = {
        let view = UIView()
    view.backgroundColor = UIColor (named: "userTextInputVCbackgroundMainView")
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
        collectionView.backgroundColor = UIColor(named: "")
        
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
        setupLayouts()
        textFieldForInput.becomeFirstResponder()
    
    }

    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UIView.animate(withDuration: 1) {
            self.backgroundColorView.alpha = 1.0
        }
        }

    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
    }

    
    private func setupViews () {
   
        backgroundColorView.backgroundColor =
//  DDAAARRRKK
//           UIColor(named:"popUpListeScreen1")!.withAlphaComponent(0.34)
            UIColor.black.withAlphaComponent(0.5)
        backgroundColorView.isOpaque = false
        backgroundColorView.alpha = 0.0
        view.addSubview(backgroundColorView)
        
        //mainview
        view.addSubview(mainView)
        
        //textField
        textFieldForInput.delegate = self
        if changingNameAndIcon == true, let listeToUpdateUnwrapped = listeToUpdate {
            textFieldForInput.text = listeToUpdateUnwrapped.name
        }else{
        textFieldForInput.attributedPlaceholder = NSAttributedString(string: textFieldPlaceHolderTextLitteral, attributes: [
            .foregroundColor: textFieldPlaceholderTextColor,
            .font: UIFont.systemFont(ofSize: textFieldFontSize, weight: .light),
            ])
        }
       // textFieldForInput.adjustsFontForContentSizeCategory = true
        //TODO: Find out why this padding causes leaks and what it serves
        textFieldForInput.setLeftPaddingPoints(textFieldLeftPadding)
        textFieldForInput.backgroundColor = .clear
        textFieldForInput.layer.borderWidth = textFieldBorderWidth
        textFieldForInput.layer.borderColor = textFieldBorderColor.cgColor
        textFieldForInput.font = UIFont.systemFont(ofSize: textFieldFontSize, weight: .light)
        textFieldForInput.returnKeyType = .done

        // collectionView
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        
        //save button
        okButton.setTitle(NSLocalizedString("OK", comment: "OK"), for: .normal)
        okButton.backgroundColor = UIColor.clear
        okButton.setTitleColor(UIColor (named: "popUpButtonFont"), for: .normal)
        okButton.addTarget(self, action: #selector(oKButtonAction), for: .touchUpInside)


        //cancel button
        cancelButton.setTitle(NSLocalizedString("Cancel", comment: "Cancel"), for: .normal)
       cancelButton.setTitleColor(UIColor (named: "popUpButtonFont"), for: .normal)
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
        
    }


    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        cancelButton.addBorder(side: .Top, color: alertViewGrayColor!, width: 1)
        cancelButton.addBorder(side: .Right, color: alertViewGrayColor!, width: 0.5)
        okButton.addBorder(side: .Top, color: alertViewGrayColor!, width: 1)
        okButton.addBorder(side: .Left, color: alertViewGrayColor!, width: 0.5)
//   Border main View
//        mainView.addBorderMainView(side: .Top, color: alertViewGrayColor!, width: 1)
//        mainView.addBorderMainView(side: .Bottom, color: alertViewGrayColor!, width: 1)
//        mainView.addBorderMainView(side: .Left, color: alertViewGrayColor!, width: 1)
//        mainView.addBorderMainView(side: .Right, color: alertViewGrayColor!, width: 1)

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
            if changingNameAndIcon, let listeToUpdateUnwrapped = listeToUpdate {
                
                var temporaryIconName = Icons.standartIconName
                if let iconNameLocal = listeToUpdateUnwrapped.iconName {
                    temporaryIconName = iconNameLocal
                }
                if let iconNameLocal = iconName {
                    temporaryIconName = iconNameLocal
                }
                let temporaryListName = textFieldForInput.text!
                changeName!(listeToUpdateUnwrapped,temporaryListName, temporaryIconName)
        }else{
            let newListe = Liste()
            newListe.name = textFieldForInput.text!
            if let iconNameLocal = iconName {
                newListe.iconName = iconNameLocal
            }
            createListe!(newListe)
        }
            
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

   //if the user presses enter (return)
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
        cell.layer.contents = UIImage(named: Icons.gray[indexPath.row])?.cgImage
        cell.contentMode = .scaleAspectFit
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if let unwrappedSelectedIndexPath = selectedIndexPath {

            let cellToUnselect = collectionView.cellForItem(at: unwrappedSelectedIndexPath)

            cellToUnselect?.layer.contents = UIImage (named: Icons.gray[unwrappedSelectedIndexPath.row])?.cgImage
            cellToUnselect?.contentMode = .scaleAspectFit
        }
        let cell = collectionView.cellForItem(at: indexPath)
       
        cell?.layer.contents = UIImage(named: Icons.rose[indexPath.row])?.cgImage
        cell?.contentMode = .scaleAspectFit
        selectedIndexPath = indexPath
        iconName = Icons.gray[indexPath.row]
    }

}



