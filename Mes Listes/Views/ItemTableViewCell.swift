//
//  ItemTableViewCell.swift
//  Mes Listes
//
//  Created by Anastasiia Tanczak on 18/08/2018.
//  Copyright © 2018 Ana Viktoriv. All rights reserved.
//

import UIKit
import SwipeCellKit

protocol ItemCellProtocol: class
{
    func cellDidTapOnButton(at index: IndexPath)
    func updateTableView ()
    func changeItemTitleAndSaveItToRealm(at index: IndexPath,newTitle newImput: String)
    
   // func makeSelectedRowVisibleWhenEdited(at index: IndexPath,_ textView: UITextView)
    //    func tableViewCell(singleTapActionDelegatedFrom cell: ItemTableViewCell)
    //    func tableViewCell(doubleTapActionDelegatedFrom cell: ItemTableViewCell)
}

class ItemTableViewCell: SwipeTableViewCell, UITextViewDelegate {
    
    //MARK: - Constants
    private let paddingLeading: CGFloat = 24
    private let paddingTrailing: CGFloat = 13
    private let leadingTrailingPaddingTitlelabel: CGFloat = 13
    private let paddingTopBottom: CGFloat = 13
    private let iconViewWidthHeight: CGFloat = 12
    private let upperTransparentBorder: CGFloat = 1
    private let photoButtonHeightWidth: CGFloat = 27
    
    //MARK: - Properties
    weak var itemDelegate: ItemCellProtocol?
    var indexpath: IndexPath?
    //private var tapCounter = 0
    
    //MARK: - Views
    var backgroundCellView = UIView()
    let iconView = UIImageView()
    let titleTextView = UITextView()
    let photoButton = UIButton()
    
    
    //MARK: - Implementation
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCellView()
        setupLayout()
        titleTextView.delegate = self
        //
        //        let tap = UITapGestureRecognizer(target: self, action: #selector(tapAction))
        //        addGestureRecognizer(tap)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func setupCellView () {
        
        contentView.isOpaque = false
        contentView.backgroundColor = UIColor.clear
        
        backgroundCellView.backgroundColor = .white
        backgroundCellView.alpha = 0.7
        addSubview(backgroundCellView)
        
        //iconview
        
        iconView.contentMode = .scaleAspectFit
        backgroundCellView.addSubview(iconView)
        
        //titlelabel
        titleTextView.text = ""
        titleTextView.textAlignment = .left
        titleTextView.font = UIFont.preferredFont(forTextStyle: .body)
        titleTextView.adjustsFontForContentSizeCategory = true
        titleTextView.isScrollEnabled = false
        titleTextView.returnKeyType = UIReturnKeyType.done
        backgroundCellView.addSubview(titleTextView)
        
        //photoButton
        photoButton.addTarget(self, action: #selector(photoButtonAction), for: .touchUpInside)
        backgroundCellView.addSubview(photoButton)
    }
    
    func setupLayout () {
        // backgroundCellView
        backgroundCellView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            backgroundCellView.topAnchor.constraint(equalTo: topAnchor, constant: upperTransparentBorder),
            backgroundCellView.bottomAnchor.constraint(equalTo: bottomAnchor),
            backgroundCellView.leadingAnchor.constraint(equalTo: leadingAnchor),
            backgroundCellView.trailingAnchor.constraint(equalTo: trailingAnchor),
            ])
        
        iconView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            iconView.leadingAnchor.constraint(equalTo: backgroundCellView.leadingAnchor, constant: paddingLeading),
            iconView.heightAnchor.constraint(equalToConstant: iconViewWidthHeight),
            iconView.widthAnchor.constraint(equalToConstant: iconViewWidthHeight),
            iconView.centerYAnchor.constraint(equalTo: titleTextView.centerYAnchor)
            ])
        
        //titleLabel
        titleTextView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleTextView.topAnchor.constraint(equalTo: backgroundCellView.topAnchor, constant: paddingTopBottom),
            titleTextView.bottomAnchor.constraint(equalTo: backgroundCellView.bottomAnchor, constant: -paddingTopBottom),
            titleTextView.leadingAnchor.constraint(equalTo: iconView.trailingAnchor , constant: leadingTrailingPaddingTitlelabel ),
            //titleLabel.trailingAnchor.constraint(equalTo: backgroundCellView.trailingAnchor, constant: -paddingTrailing)
            ])
        
        //photoButton
        photoButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            photoButton.widthAnchor.constraint(equalToConstant: photoButtonHeightWidth),
            photoButton.heightAnchor.constraint(equalToConstant: photoButtonHeightWidth),
            photoButton.leadingAnchor.constraint(equalTo: titleTextView.trailingAnchor , constant: leadingTrailingPaddingTitlelabel ),
            photoButton.trailingAnchor.constraint(equalTo: backgroundCellView.trailingAnchor, constant: -paddingTrailing),
            photoButton.centerYAnchor.constraint(equalTo: titleTextView.centerYAnchor)
            ])
        
    }
    
    //MARK: - DIFFERENT METHODS
    @objc func photoButtonAction ()
    {
        if let indexPathUnwrapped = indexpath {
            itemDelegate?.cellDidTapOnButton(at: indexPathUnwrapped)
        }
    }
    func fillWith(model: Item?) {
        if let item = model {
            
            if item.done == true {
                let attributedString = NSMutableAttributedString.init(string: item.title)
                attributedString.addAttribute(.strikethroughStyle, value: 2, range: NSRange.init(location: 0, length: item.title.count))
                attributedString.addAttribute(.foregroundColor, value: UIColor.lightGray , range: NSRange.init(location: 0, length: item.title.count))
                titleTextView.attributedText = attributedString
                
                iconView.image = #imageLiteral(resourceName: "gray-circle-icon")
                
            }else{
                let attributedString = NSMutableAttributedString.init(string: item.title)
                attributedString.addAttribute(.strikethroughStyle, value: 0, range: NSRange.init(location: 0, length: item.title.count))
                titleTextView.attributedText = attributedString
                
                iconView.image = #imageLiteral(resourceName: "black-emty-circle-icon")
            }
            
            if item.hasImage == true
            {
                photoButton.isHidden = false
                //retireve the image and add it as the background
                let image = getImage(imageName: item.imageName)
                photoButton.setImage(image, for: .normal)
            }
            else
            {
                photoButton.isHidden = true
            }
        }else{
            titleTextView.text = "You haven't created an item yet"
        }
        
        
    }
    
    func getImage(imageName : String)-> UIImage {
        let fileManager = FileManager.default
        // Here using getDirectoryPath method to get the Directory path
        let imagePath = (self.getDirectoryPath() as NSString).appendingPathComponent(imageName)
        if fileManager.fileExists(atPath: imagePath){
            return UIImage(contentsOfFile: imagePath)!
        }else{
            print("No Image available")
            return UIImage.init(named: "placeholder.png")! // Return placeholder image here
        }
    }
    
    func getDirectoryPath() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    
    
    //       @objc func tapAction() {
    //
    //            if tapCounter == 0 {
    //                DispatchQueue.global(qos: .background).async {
    //                    usleep(250000)
    //                    if self.tapCounter > 1 {
    //                        self.doubleTapAction()
    //                    } else {
    //                        self.singleTapAction()
    //                    }
    //                    self.tapCounter = 0
    //                }
    //            }
    //            tapCounter += 1
    //        }
    //
    //        func singleTapAction() {
    //            itemDelegate?.tableViewCell(singleTapActionDelegatedFrom: self)
    //        }
    //
    //        func doubleTapAction() {
    //            itemDelegate?.tableViewCell(doubleTapActionDelegatedFrom: self)
    //        }
    
    
    
    override func prepareForReuse() {
        titleTextView.text = nil
        iconView.image = nil
        photoButton.setBackgroundImage(nil, for: .normal)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
         if let indexPathUnwrapped = indexpath {
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        
        
        if let indexPathUnwrapped = indexpath {
            
            titleTextView.constraints.forEach {[weak self] (constraint) in
                if constraint.firstAttribute == .height {
                    
                    //!!!Need to change size here somehow
                    let size = CGSize(width: 60, height: CGFloat.infinity)
                    let estimatedSize = titleTextView.sizeThatFits(size)
                    constraint.constant = estimatedSize.height
                    
                    let textinput = titleTextView.text
                    
                    self!.itemDelegate?.changeItemTitleAndSaveItToRealm(at: indexPathUnwrapped, newTitle: textinput!)
                    self!.itemDelegate?.updateTableView()
                    titleTextView.becomeFirstResponder()
                    
                }
            }
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n"  // Recognizes enter key in keyboard
        {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
}

