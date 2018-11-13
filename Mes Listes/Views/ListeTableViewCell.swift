//
//  ListeTableViewCell.swift
//  Mes Listes
//
//  Created by Anastasiia Tanczak on 17/08/2018.
//  Copyright © 2018 Ana Viktoriv. All rights reserved.
//

import UIKit
import SwipeCellKit

class ListeTableViewCell: SwipeTableViewCell {
    
    //MARK: - Constants
    private let paddingLeadingTrailing: CGFloat = 30
    private let distanceBetweenIconViewAndTitlelabel: CGFloat = 30
    private let paddingTopBottom: CGFloat = 20
    private let iconViewWidthHeight: CGFloat = 40
    private let upperTransparentBorder: CGFloat = 1

    //MARK: - Views
    var backgroundCellView = UIView()
    var iconView = UIImageView()
    var titleLabel = UILabel()

    //MARK: - Implementation
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
     
        setupCellView()
        setupLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func setupCellView () {

        contentView.isOpaque = false
        contentView.backgroundColor = UIColor.clear
        
        backgroundCellView.backgroundColor = .white
        contentView.addSubview(backgroundCellView)
        
        //titleLabel
        titleLabel.text = ""
        titleLabel.textAlignment = .left
        titleLabel.font = UIFont.preferredFont(forTextStyle: .body)
        titleLabel.adjustsFontForContentSizeCategory = true
        
        backgroundCellView.addSubview(titleLabel)
        
        //iconView
        iconView.image = nil
        iconView.contentMode = .scaleAspectFit
        backgroundCellView.addSubview(iconView)
    }
    
    
    private func setupLayout() {
        
        // backgroundCellView
        backgroundCellView.translatesAutoresizingMaskIntoConstraints = false
   
        NSLayoutConstraint.activate([
            backgroundCellView.topAnchor.constraint(equalTo: topAnchor, constant: upperTransparentBorder),
            backgroundCellView.bottomAnchor.constraint(equalTo: bottomAnchor),
            backgroundCellView.leadingAnchor.constraint(equalTo: leadingAnchor),
            backgroundCellView.trailingAnchor.constraint(equalTo: trailingAnchor)
            ])
        
        // iconView Layout
        iconView.translatesAutoresizingMaskIntoConstraints = false

        
        NSLayoutConstraint.activate([

            iconView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: paddingLeadingTrailing),
            iconView.heightAnchor.constraint(equalToConstant: iconViewWidthHeight),
            iconView.widthAnchor.constraint(equalToConstant: iconViewWidthHeight),
            iconView.centerYAnchor.constraint(equalTo: backgroundCellView.centerYAnchor)

            ])
 
        //titleLabel Layout
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        //titleLabel.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
       
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: distanceBetweenIconViewAndTitlelabel),
            titleLabel.trailingAnchor.constraint(equalTo: backgroundCellView.trailingAnchor, constant: -paddingLeadingTrailing),
            titleLabel.centerYAnchor.constraint(equalTo: iconView.centerYAnchor)
            ])
        
    }

    
    func fillWith(model: Liste?) {
       
        if let liste = model {
            //set icon
            if let listeIconName = liste.iconName {
                iconView.image = UIImage(named: listeIconName)
            }else{
                iconView.image = #imageLiteral(resourceName: "empty-big-circle")
                iconView.contentMode = .center
            }
            
            //set title
            if liste.done == true {
                let attributedString = NSMutableAttributedString.init(string: liste.name.uppercased())
                attributedString.addAttribute(.strikethroughStyle, value: 2, range: NSRange.init(location: 0, length: liste.name.count))
                attributedString.addAttribute(.foregroundColor, value: UIColor.lightGray , range: NSRange.init(location: 0, length: liste.name.count))
                titleLabel.attributedText = attributedString
            } else {
                let attributedString = NSMutableAttributedString.init(string: liste.name.uppercased())
                attributedString.addAttribute(.strikethroughStyle, value: 0, range: NSRange.init(location: 0, length: liste.name.count))
                titleLabel.attributedText = attributedString
            }
            
            // delete this code if there are 3 hardcoded listes
        } else {
            titleLabel.text = "You haven't created a list yet"
        }
        
        
    }
    
    //MARK: - OTHERS
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    override func prepareForReuse() {
        titleLabel.text = nil
        iconView.image = nil
        
    }

}
