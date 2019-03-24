//
//  Constants.swift
//  Mes Listes
//
//  Created by Anastasiia Tanczak on 19/03/2019.
//  Copyright © 2019 Ana Viktoriv. All rights reserved.
//

import Foundation
import UIKit

enum ListConctollerCellMesurements {
    
     static let cellHeight: CGFloat = 70
     static let minimumSwipeCellWidth: CGFloat = 70.0
   
}

enum TimeIntervals {
 static let timeIntervalForEndDate: Double = 3600
}

enum SettingsAlert {
    static let title = "We need your permission"
    static let message = "Go to settings"
    static let settingActionTitle = "Settings"
    static let cancelActionTitle = "Cancel"
}

enum NotificationReminder {
    static var title = "A little reminder:"
    static var body = ""
}

enum NavigationBar {
    static let title = "meslistes"
    
    static var rightButtonImage = UIImage(named: "plus-icon")
    
    static let titleAttributes = [NSAttributedString.Key.font: UIFont(name: "Zing Sans Rust Regular", size: 28.5)!, NSAttributedString.Key.foregroundColor: UIColor.black]
}

enum ImageInListController {
    static let background = #imageLiteral(resourceName: "background-image")
    static let strikeOutForSwipeCell = #imageLiteral(resourceName: "strikeout-icon")
    static let reminderForSwipeCell = UIImage(named: "reminder-icon")
    static let addEventToCalendarForSwipeCell = #imageLiteral(resourceName: "calendar-icon")
    static let deleteForSwipeCell = #imageLiteral(resourceName: "trash-icon")
    static let changeTitleForSwipeCell = UIImage (named: "editTitle-icon")
}

enum Color {
    static let swipeCellBackgroundColorForDefault = UIColor.init(red: 240/255, green: 214/255, blue: 226/255, alpha: 1)
    static let swipeCellBackGroundColorForDestructive = UIColor.init(red: 242/255, green: 93/255, blue: 97/255, alpha: 1)
    static let separatorCustomColor = UIColor.init(red: 251/255, green: 251/255, blue: 251/255, alpha: 1)
}

enum ListNames {
    static var name1 = "Shopping list"
    static var name2 = "To do"
    static var name3 = "Travelpack"
}

enum Icons {
    static let gray = ["todo-icon", "star-icon", "airplane-icon", "shopping-cart-icon", "home-icon", "clothes-icon", "gift-icon", "bag-icon", "light-bulb-icon", "sport-icon", "cooking-icon", "book-icon"]
    
    static let rose = ["todo-icon-rose", "star-icon-rose", "airplane-icon-rose", "shopping-cart-icon-rose", "home-icon-rose", "clothes-icon-rose", "gift-icon-rose", "bag-icon-rose", "light-bulb-icon-rose", "sport-icon-rose", "cooking-icon-rose", "book-icon-rose"]
    
    static let standartIconName = "empty-big-circle"
}

enum TextFieldItems {
    static let placeholderText = "Type your item here..."
    static let height: CGFloat = 40
    static let distanceFromPlusButton: CGFloat = 10
    static let distanceFromTableView: CGFloat = 10
}

enum AlertCameraPhotoLibrary {
    static let cameraActionTitle = "Take picture with Camera"
    static let photoLibraryActionTitle = "Choose from Photo Library"
    static let cancelActionTitle = "Cancel"
}

enum NoCameraAlert {
    static let title = "Warning"
    static let message = "You don't have camera"
    static let okActionTitle = "OK"
}

