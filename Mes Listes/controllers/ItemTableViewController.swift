//
//  ItemTableViewController.swift
//  Mes Listes
//
//  Created by Anastasiia Tanczak on 24/06/2018.
//  Copyright © 2018 Ana Viktoriv. All rights reserved.
//

import UIKit
import RealmSwift
import UserNotifications
import EventKit
import SwipeCellKit

class ItemTableViewController: UIViewController {
    //MARK: - Constants
    private let textFieldPlaceholderText = "Type your item here..."
    private let textFieldHeight: CGFloat = 40
    private let textFieldAndPlusButtonPadding: CGFloat = 10
    private let subviewTextFiledPaddingRightLeft: CGFloat = 5
    private let distanceBetweenTextfieldAndTableView: CGFloat = 10
    private let borderSubView: CGFloat = 1
    private let settingsAlertTitleCalendar = "We need your permission"
    private let settingsAlertMessageCalendar = "Change your settings"
    private let settingsAlertTitleNotification = "We need your permission"
    private let settingAlertMessageNotification = "Go to settings"
    private var chosenNameforCalendar = ""
    private var notificationTitle = ""
    private var notificationBody = ""
    //private var rowForSelectedItem = 0
    
    //MARK: - Properties
    let realm = try! Realm()
    var items : Results <Item>?
    
    var nameOfTheSelectedListe = ""
    
    var isSwipeRightEnabled = true
    let backgroundImage = #imageLiteral(resourceName: "background-image")

    let eventStore = EKEventStore()
    
    let backgroundImageView = UIImageView()
    let subviewForTextFieldAndPlusButton = UIView()
    let textFieldItems = UITextField()
    let plusButton = UIButton()
    let tableView = UITableView()
    
    var selectedListe : Liste? {
        didSet {
            loadItems()
        }
    }

    //MARK: - Life Cycle
    
    override func viewWillAppear(_ animated: Bool) {
    }
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        setupNavigationBar()
        setupViews()
        setupLayout()
        
    }
    

    private func setupNavigationBar () {
        
        let title = selectedListe?.name.uppercased() ?? "meslistes"
        self.title = title
        
      let attributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 19, weight: .light), NSAttributedString.Key.foregroundColor: UIColor.black]
        navigationController?.navigationBar.titleTextAttributes = attributes
        
        let leftNavigationButton = UIBarButtonItem(image: #imageLiteral(resourceName: "back-button-icon") , style: .plain, target: self, action: #selector(leftBarButtonAction))
        leftNavigationButton.tintColor = .black
        
        leftNavigationButton.imageInsets  = .init(top: 0, left: -4, bottom: 0, right: 0)
        self.navigationItem.setLeftBarButton(leftNavigationButton, animated: false)

    }
    
    private func setupViews () {
        
        
        // backgroundImageView
        backgroundImageView.image = backgroundImage
        backgroundImageView.contentMode = .scaleAspectFill
        view.addSubview(backgroundImageView)
        
        //subviewForTextField
        subviewForTextFieldAndPlusButton.backgroundColor = .clear
        subviewForTextFieldAndPlusButton.layer.borderColor = UIColor.white.cgColor
        subviewForTextFieldAndPlusButton.layer.cornerRadius = 10
        subviewForTextFieldAndPlusButton.layer.borderWidth = 1

        view.addSubview(subviewForTextFieldAndPlusButton)
        
        //textField
        textFieldItems.backgroundColor = .clear
        textFieldItems.placeholder = textFieldPlaceholderText
        textFieldItems.delegate = self
        textFieldItems.returnKeyType = UIReturnKeyType.next

        textFieldItems.becomeFirstResponder()
        subviewForTextFieldAndPlusButton.addSubview(textFieldItems)
        
        //plusButton
        plusButton.setImage(#imageLiteral(resourceName: "plus-icon-gray"), for: .normal)
        plusButton.addTarget(self, action: #selector(plusButtonAction), for: .touchUpInside)
        subviewForTextFieldAndPlusButton.addSubview(plusButton)
        
        //tableView
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ItemTableViewCell.self, forCellReuseIdentifier: "ItemTableViewCell")
        tableView.backgroundColor = UIColor.clear
        tableView.separatorColor = UIColor.white
        tableView.separatorStyle = .singleLine
        tableView.separatorInset = .init(top: 0, left: 0, bottom: 0, right: 0)
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableView.automaticDimension
        view.addSubview(tableView)
    }
    
    private func setupLayout() {
        
        backgroundImageView.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor)
        
        //subViewTextField
        subviewForTextFieldAndPlusButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            subviewForTextFieldAndPlusButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            subviewForTextFieldAndPlusButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: subviewTextFiledPaddingRightLeft),
            subviewForTextFieldAndPlusButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -subviewTextFiledPaddingRightLeft),
            subviewForTextFieldAndPlusButton.heightAnchor.constraint(equalToConstant: textFieldHeight + 2 * borderSubView)
            ])
        
        
        //textField
        textFieldItems.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            textFieldItems.topAnchor.constraint(equalTo: subviewForTextFieldAndPlusButton.topAnchor, constant: borderSubView),
            textFieldItems.leadingAnchor.constraint(equalTo: subviewForTextFieldAndPlusButton.leadingAnchor, constant: textFieldAndPlusButtonPadding),
            textFieldItems.heightAnchor.constraint(equalToConstant: textFieldHeight)
            ])
        
        //plusButton
        plusButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            plusButton.topAnchor.constraint(equalTo: textFieldItems.topAnchor),
            plusButton.bottomAnchor.constraint(equalTo: textFieldItems.bottomAnchor),
            plusButton.leadingAnchor.constraint(equalTo: textFieldItems.trailingAnchor),
            plusButton.widthAnchor.constraint(equalTo: plusButton.heightAnchor),
            plusButton.trailingAnchor.constraint(equalTo: subviewForTextFieldAndPlusButton.trailingAnchor),
            ])
        
        //tableView
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: subviewForTextFieldAndPlusButton.bottomAnchor, constant: distanceBetweenTextfieldAndTableView),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
            ])
        
    }
    
    //MARK: - ACTIONS
    @objc func plusButtonAction () {
        createItem()
    }
    
    @objc func leftBarButtonAction () {
        let attributes = [NSAttributedString.Key.font: UIFont(name: "Zing Sans Rust Regular", size: 28.5)!, NSAttributedString.Key.foregroundColor: UIColor.black]
        navigationController?.navigationBar.titleTextAttributes = attributes
        _ = navigationController?.popToRootViewController(animated: true)
        
    }
    
    //MARK: - Different Methods REALM
    
    func createItem (){
        userInputHandeled()
        tableView.reloadData()
    }
    func userInputHandeled(){
        if textFieldItems.text != "" && textFieldItems.text != nil {
            
            if let currentListe = self.selectedListe {
                
                do {
                    try self.realm.write {
                        let newItem = Item()
                        newItem.title = textFieldItems.text!
                        currentListe.items.append(newItem)
                    }
                }catch{
                    print("Error saving item\(error)")
                }
            }
            textFieldItems.text = ""
            
        }else if textFieldItems.text == "" && textFieldItems.text != nil{
            //TODO: - Textfield empty
            
        }else{
            print("text field is nill")
        }
    }
        
    
    //retrieves data from the database
    func loadItems () {
        items = selectedListe?.items.sorted(byKeyPath: "title", ascending: true)
        tableView.reloadData()
    }
    
    //MARK: - EVENTKIT AND CALENDAR METHODS
    
    func goToPopupAndSaveEvent () {
        //popup
        
        let dpVC = DatePickerPopupViewController()
        dpVC.modalPresentationStyle = .overCurrentContext
        dpVC.dateForCalendar = true
        dpVC.saveEventToCalendar = saveEventToCalendar
        self.present(dpVC, animated: true, completion: nil)
        
        
    }
    func saveEventToCalendar(_ date: Date) ->(){
        
        
        let event = EKEvent(eventStore: eventStore)
        
        event.title = self.chosenNameforCalendar
        event.startDate = date
        event.endDate = date.addingTimeInterval(3600)
        event.calendar = eventStore.defaultCalendarForNewEvents
        do  {
            try eventStore.save(event, span: .thisEvent)
        }catch{
            print("error saving the event\(error)")
        }
    }
    
    func checkCalendarAuthorizationStatus() {
        
        
        let status = EKEventStore.authorizationStatus(for: EKEntityType.event)
        
        switch (status) {
        case EKAuthorizationStatus.notDetermined:
            // This happens on first-run
            firstTimeAccessToCalendar()
        case EKAuthorizationStatus.authorized:
            // Things are in line with being able to show the calendars in the table view
            goToPopupAndSaveEvent()
        case EKAuthorizationStatus.restricted, EKAuthorizationStatus.denied:
            // We need to help them give us permission
            
            goToSettingsAllert(alertTitle: settingsAlertTitleCalendar, alertMessage: settingsAlertMessageCalendar)
        }
    }
    
    func firstTimeAccessToCalendar () {
        
        eventStore.requestAccess(to: .event) {[weak self] (granted, error) in
            if granted {
                self?.goToPopupAndSaveEvent()
            }else{
                self?.goToSettingsAllert(alertTitle: self!.settingsAlertTitleCalendar, alertMessage: self!.settingsAlertMessageCalendar)
            }
        }
    }
    
    
    func goToSettingsAllert (alertTitle: String, alertMessage: String) {
        
        let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
        
        let settingsAction = UIAlertAction(title: "Settings", style: .default) { (action) in
            guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else {
                return
            }
            if UIApplication.shared.canOpenURL(settingsURL) {
                UIApplication.shared.open(settingsURL, completionHandler: { (success) in
                    print("Settings opened: \(success)")
                })
            }
        }
        alert.addAction(settingsAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    //MARK: - NOTIFICATION CENTER MATHODS (REMINDERS)
    
    func getNotificationSettingStatus () {
        
        UNUserNotificationCenter.current().getNotificationSettings {[weak self] (settings) in
            
            switch settings.authorizationStatus {
            case .authorized:
                self!.goToPopupAndSetReminder()
                
            case .denied:
                self!.goToSettingsAllert(alertTitle: self!.settingsAlertTitleNotification, alertMessage: self!.settingAlertMessageNotification)
            case .notDetermined:
                print("casenotDetermined is highly unlikely")
            case .provisional:
                print("caseProvisional is highly unlikely")
            }
        }
    }
    
    
    
    func goToPopupAndSetReminder () {
        let dpVC = DatePickerPopupViewController()
        dpVC.dateForCalendar = false
        dpVC.modalPresentationStyle = .overCurrentContext
        dpVC.setReminder = setReminder
        self.present(dpVC, animated: true, completion: nil)
    }
    // sends the notification to user to remind the list
    func setReminder (_ components: DateComponents) ->(){
        
        let content = UNMutableNotificationContent()
        content.title = notificationTitle
        content.body = notificationBody
        content.sound = UNNotificationSound.default
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: "TestIdentifier", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { (error) in
            if let error = error {
                print(" We had an error: \(error)")
            }
        }
    }
    
}
// MARK: - TABLE VIEW DELEGATE METHODS DATA SOURCE
extension ItemTableViewController: UITableViewDelegate, UITableViewDataSource {
   
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //textFieldItems.resignFirstResponder()
        //        let currentItem = items?[indexPath.row]
        //        if currentItem?.hasNote == true {
        //            performSegue(withIdentifier: "goToNote", sender: self)
        //        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return items?.count ?? 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemTableViewCell", for: indexPath) as! ItemTableViewCell
        cell.delegate = self
        cell.fillWith(model: items?[indexPath.row])
        cell.titleLabel.font = UIFont.preferredFont(forTextStyle: .body)
        cell.titleLabel.adjustsFontForContentSizeCategory = true
        cell.backgroundColor = UIColor.clear
        cell.titleLabel.numberOfLines = 0
        
        return cell
    }
    
}

    //MARK: - METHODS FOR SWIPE ACTIONS
extension ItemTableViewController: SwipeTableViewCellDelegate {

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {

        if orientation == .left {
            guard isSwipeRightEnabled else { return nil }
            
            //STRIKE OUT
            let strikeOut = SwipeAction(style: .default, title: nil) { (action, indexPath) in
                self.strikeOut(at: indexPath)
                tableView.reloadRows(at: [indexPath], with: .automatic)
            }
            strikeOut.image = #imageLiteral(resourceName: "strikeout-item-icon")
            strikeOut.backgroundColor = self.colorize(hex: 0xF0D6E2)
            
             //REMINDER
            let setReminder = SwipeAction(style: .default, title: nil) { action, indexPath in
                self.updateModelByAddingAReminder(at: indexPath)
                let cell: SwipeTableViewCell = tableView.cellForRow(at: indexPath) as! SwipeTableViewCell
                cell.hideSwipe(animated: true)
            }
            setReminder.image = #imageLiteral(resourceName: "reminder-item-icon")
            setReminder.backgroundColor = self.colorize(hex: 0xF0D6E2)
            
             //CALENDAR
            let addEventToCalendar = SwipeAction(style: .default, title: nil) { (action, indexPath) in
                self.addEventToCalendar(at: indexPath)
                let cell: SwipeTableViewCell = tableView.cellForRow(at: indexPath) as! SwipeTableViewCell
                cell.hideSwipe(animated: true)
            }
            addEventToCalendar.image = #imageLiteral(resourceName: "calendar-item-icon")
            addEventToCalendar.backgroundColor = self.colorize(hex: 0xF0D6E2)
            
            return[strikeOut, setReminder, addEventToCalendar]
            
        }else{
             //DELETE
            let deleteAction = SwipeAction(style: .destructive, title: nil) { action, indexPath in
                self.updateModel(at: indexPath)
            }
            deleteAction.image = #imageLiteral(resourceName: "delete-item-icon")
            deleteAction.backgroundColor = self.colorize(hex: 0xF25D61)
            
            //take photo
            let takePhotoAction = SwipeAction(style: .default, title: nil) { (action, indexpath) in
                //take photo action
                print("photo has been taken")
                
                let cell: SwipeTableViewCell = tableView.cellForRow(at: indexPath) as! SwipeTableViewCell
                cell.hideSwipe(animated: true)
                
            }
            takePhotoAction.backgroundColor = self.colorize(hex: 0xB9CDD6)
            takePhotoAction.image = #imageLiteral(resourceName: "camera-icon")
            return [deleteAction, takePhotoAction]
        }
        
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeTableOptions {
        
        var options = SwipeTableOptions()

        
        //diferent expansion styles
        options.expansionStyle = orientation == .left ? .selection : .destructive
        options.minimumButtonWidth = 45.0
        return options
    }
    
    func updateModel(at indexpath: IndexPath) {
        if let itemForDeletion = self.items?[indexpath.row] {
            do {
                try self.realm.write {
                    self.realm.delete(itemForDeletion)
                }
            }catch{
                print("Error deleting item\(error)")
            }
        }
    }
    
    func updateModelByAddingAReminder(at indexpath: IndexPath) {
        
//        rowForSelectedItem = indexpath.row
        notificationTitle = items![indexpath.row].title
        
        getNotificationSettingStatus()
    }
    

    
    func addEventToCalendar(at indexpath: IndexPath) {
        
//        rowForSelectedItem = indexpath.row
        chosenNameforCalendar = items![indexpath.row].title
        
        checkCalendarAuthorizationStatus()
    }
    
    
    //strikes out the text
    func strikeOut(at indexPath: IndexPath) {
        if let currentItem = self.items?[indexPath.row] {
            do {
                try realm.write {
                    currentItem.done = !currentItem.done
                }
            }catch{
                print("error updating realm\(error)")
            }
        }
    }
}


//MARK: - TextField Method

extension ItemTableViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == textFieldItems {
        createItem()
        return true
        }
        return false
    }
}

extension ItemTableViewController {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.textFieldItems.resignFirstResponder()
        self.textFieldItems.text = ""
    }
}

    


