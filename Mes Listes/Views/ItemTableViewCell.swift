//
//  ItemTableViewCell.swift
//  Mes Listes
//
//  Created by Anastasiia Tanczak on 18/08/2018.
//  Copyright © 2018 Ana Viktoriv. All rights reserved.
//

import UIKit
import SwipeCellKit

class ItemTableViewCell: SwipeTableViewCell {
    
    //MARK: - Constants
    private let paddingLeading: CGFloat = 24
    private let paddingTrailing: CGFloat = 13
    private let leadingTrailingPaddingTitlelabel: CGFloat = 13
    private let paddingTopBottom: CGFloat = 13
    private let iconViewWidthHeight: CGFloat = 12
    private let upperTransparentBorder: CGFloat = 1
    private let photoButtonHeight: CGFloat = 20
    private let photoButtonWidth: CGFloat = 25

    //MARK: - Views
    var backgroundCellView = UIView()
    let iconView = UIImageView()
    let titleLabel = UILabel()

    
    //MARK: - Implementation
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCellView()
        setupLayout()
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
        titleLabel.text = ""
        titleLabel.textAlignment = .left
        titleLabel.font = UIFont.preferredFont(forTextStyle: .body)
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.numberOfLines = 0
        backgroundCellView.addSubview(titleLabel)
        
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
            iconView.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor)
        ])
        
    
        //titleLabel
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: backgroundCellView.topAnchor, constant: paddingTopBottom),
            titleLabel.bottomAnchor.constraint(equalTo: backgroundCellView.bottomAnchor, constant: -paddingTopBottom),
            titleLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor , constant: leadingTrailingPaddingTitlelabel ),
            titleLabel.trailingAnchor.constraint(equalTo: backgroundCellView.trailingAnchor, constant: -paddingTrailing)
            ])
        
    }
    
    //MARK: - DIFFERENT METHODS
    
    func fillWith(model: Item?) {
                if let item = model {
        
                    if item.done == true {
                        let attributedString = NSMutableAttributedString.init(string: item.title)
                        attributedString.addAttribute(.strikethroughStyle, value: 2, range: NSRange.init(location: 0, length: item.title.count))
                        attributedString.addAttribute(.foregroundColor, value: UIColor.lightGray , range: NSRange.init(location: 0, length: item.title.count))
                        titleLabel.attributedText = attributedString
                        
                        iconView.image = #imageLiteral(resourceName: "gray-circle-icon")
        
                    }else{
                        let attributedString = NSMutableAttributedString.init(string: item.title)
                        attributedString.addAttribute(.strikethroughStyle, value: 0, range: NSRange.init(location: 0, length: item.title.count))
                        titleLabel.attributedText = attributedString
                        
                        iconView.image = #imageLiteral(resourceName: "black-emty-circle-icon")
                    }
                    
                }else{
                    titleLabel.text = "You haven't created an item yet"
                }
        
        
    }
    
    override func prepareForReuse() {
        titleLabel.text = nil
        iconView.image = nil
    }
}
