//
//  ItemViewController.swift
//  segue and swipe
//
//  Created by Anastasiia Tanczak on 16/06/2018.
//  Copyright © 2018 Ana Viktoriv. All rights reserved.
//

import UIKit
import RealmSwift
import UserNotifications
import EventKit
import SwipeCellKit
import SnapKit

class ListViewController: UIViewController {
    
    //MARK: - Constants
    private let cellHeight: CGFloat = 70
    private let minimumSwipeCellWidth: CGFloat = 70.0
    private let timeIntervalForEndDate: Double = 3600
    
    private let settingsAlertTitleCalendar = "We need your permission"
    private let settingsAlertMessageCalendar = "Change your settings"
    private var notificationTitle = "Don't forget!"
    private var notificationBody = ""
    private let settingsAlertTitleNotification = "We need your permission"
    private let settingAlertMessageNotification = "Go to settings"
    private let navigationTitle = "meslistes"
    private let cellIdentifier = "ListeTableViewController"
    var rightNavigationBarImage = UIImage(named: "plus-icon")
    
    private let navigationBarTitleAttributes = [NSAttributedString.Key.font: UIFont(name: "Zing Sans Rust Regular", size: 28.5)!, NSAttributedString.Key.foregroundColor: UIColor.black]
    
    private let swipeCellBackgroundColorForDefault = UIColor.init(red: 240/255, green: 214/255, blue: 226/255, alpha: 1)
    private let swipeCellBackGroundColorForDestructive = UIColor.init(red: 242/255, green: 93/255, blue: 97/255, alpha: 1)
    private let separatorCustomColor = UIColor.init(red: 251/255, green: 251/255, blue: 251/255, alpha: 1)
    
    private let backgroundImage = #imageLiteral(resourceName: "background-image")
    private let strikeOutImage = #imageLiteral(resourceName: "strikeout-icon")
    private let reminderImage = UIImage(named: "reminder-icon")
    private let addEventToCalendarImage = #imageLiteral(resourceName: "calendar-icon")
    private let deleteImage = #imageLiteral(resourceName: "trash-icon")
    
    //MARK: - Properties
    let backgroundImageView: UIImageView = UIImageView()
    let tableView = UITableView()
    
    
    let realm = try! Realm()
    var lists : Results <Liste>?
    //var chosenRow = 0
    var chosenNameforCalendar = ""
    var notificationTitleForReminder = ""
    var isSwipeRightEnabled = true
    
    
    let eventStore = EKEventStore()
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
    
        setupNavigationBar()
        setupView()
        setupLayout()
        
        if isAppAlreadyLaunchedOnce() {
            loadLists()
        }else{
            threeHardCodedExamples()
            loadLists()
        }
    }

    
    private func setupNavigationBar () {
        
        self.title = navigationTitle
        navigationController?.navigationBar.titleTextAttributes = navigationBarTitleAttributes
        rightNavigationBarImage = rightNavigationBarImage?.withRenderingMode(.alwaysOriginal)
        let rightNavigationButton = UIBarButtonItem(image: rightNavigationBarImage, style: .plain, target: self, action: #selector (rightBarButtonAction))
        self.navigationItem.setRightBarButton(rightNavigationButton, animated: false)
    }
    
    //MARK: - Button ACTIONS
    @objc func rightBarButtonAction () {
        
        let userTextInputVC = UserTextInputViewController()
        userTextInputVC.createListe = createListe
        userTextInputVC.modalPresentationStyle = .overCurrentContext
        
        self.present(userTextInputVC, animated: true, completion: nil)
    }
    
    //MARK: - Layout
    private func setupView () {
        
        // backgroundImageView
        backgroundImageView.image = backgroundImage
        backgroundImageView.contentMode = .scaleAspectFill
        view.addSubview(backgroundImageView)
        
        //tableView
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ListeTableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        tableView.backgroundColor = UIColor.clear
        tableView.separatorColor = separatorCustomColor
        tableView.separatorStyle = .singleLine
        tableView.separatorInset = .zero
        
        view.addSubview(tableView)
    }
    
    private func setupLayout() {
        
        backgroundImageView.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
            ])
    }
    
    
    //MARK: - REALM FUNCTIONS
    
    //saves data into database
    func save(list: Liste) {
        do {
            try realm.write {
                realm.add(list)
            }
        } catch {
            print("Error saving massage\(error)")
        }
    }
    
    //retrieves data from the database
    func loadLists () {
        lists = realm.objects(Liste.self)
        lists = lists?.sorted(byKeyPath: "name", ascending: true)
        tableView.reloadData()
    }
}

//MARK: - TableView DataSource and Delegate
extension ListViewController: UITableViewDelegate, UITableViewDataSource {
    
    // delegate methods
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        let itemVC = ItemTableViewController()
        
        if let selectedListWithValue = lists?[indexPath.row] {
            itemVC.selectedListe = selectedListWithValue
        }
        
        self.show(itemVC, sender: self)
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }
    
    // data source methhods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lists?.count ?? 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! ListeTableViewCell
        cell.delegate = self
        cell.fillWith(model: lists?[indexPath.row])
        cell.titleLabel.font = UIFont.preferredFont(forTextStyle: .body)
        cell.titleLabel.adjustsFontForContentSizeCategory = true
        cell.selectionStyle = .none
        cell.backgroundColor = UIColor.clear
        return cell
    }
}

//MARK: - METHODS FOR SWIPE ACTIONS
extension ListViewController: SwipeTableViewCellDelegate {
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        
        if orientation == .left {
            guard isSwipeRightEnabled else { return nil }
            
            //STRIKE OUT
            let strikeOut = SwipeAction(style: .default, title: nil) {[weak self](action, indexPath) in
                self?.strikeOut(at: indexPath)
            }
            strikeOut.image = strikeOutImage
            strikeOut.backgroundColor = self.swipeCellBackgroundColorForDefault
            
            //REMINDER
            let setReminder = SwipeAction(style: .default, title: nil) { [weak self](action, indexPath) in
                self?.addReminder(at: indexPath)
                let cell: SwipeTableViewCell = tableView.cellForRow(at: indexPath) as! SwipeTableViewCell
                cell.hideSwipe(animated: true)
            }
            setReminder.image = reminderImage
            setReminder.backgroundColor = self.swipeCellBackgroundColorForDefault
            
            //CALENDAR
            let addEventToCalendar = SwipeAction(style: .default, title: nil) {[weak self] (action, indexPath) in
                self?.addEventToCalendar(at: indexPath)
                let cell: SwipeTableViewCell = tableView.cellForRow(at: indexPath) as! SwipeTableViewCell
                cell.hideSwipe(animated: true)
            }
            addEventToCalendar.image = addEventToCalendarImage
            addEventToCalendar.backgroundColor = self.swipeCellBackgroundColorForDefault
            
            return[strikeOut, setReminder, addEventToCalendar]
            
        }else{
            let changeTextAction = SwipeAction(style: .default, title: nil) { [weak self](action, indexpath) in
                self?.goToUserInputPopupAndChangeName(at: indexPath)
                let cell: SwipeTableViewCell = tableView.cellForRow(at: indexPath) as! SwipeTableViewCell
                cell.hideSwipe(animated: true)
            }
            changeTextAction.backgroundColor = self.swipeCellBackgroundColorForDefault
            
            //DELETE
            let deleteAction = SwipeAction(style: .destructive, title: nil) {[weak self] (action, indexPath) in
                self?.deleteListe(at: indexPath)
            }
            deleteAction.image = deleteImage
            deleteAction.backgroundColor = self.swipeCellBackGroundColorForDestructive
            
            return [deleteAction, changeTextAction]
        }
        
    }
    
    //makes different expansion styles possible (such as deleting by swiping till it disappears)
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeTableOptions {
        
        var options = SwipeTableOptions()
        
        
        //diferent expansion styles
        options.expansionStyle = orientation == .left ? .selection : .destructive
        options.minimumButtonWidth = minimumSwipeCellWidth
        return options
    }
    
    func addReminder(at indexpath: IndexPath) {
        notificationTitle = lists![indexpath.row].name
        getNotificationSettingStatus()
    }
    
    //deletes the list
    func deleteListe (at indexpath: IndexPath) {
        if let listForDeletion = self.lists?[indexpath.row]{
            let items : Results <Item> = listForDeletion.items.sorted(byKeyPath: "title", ascending: true)
            do {
                try self.realm.write {
                    for item in items {
                        if item.hasImage {
                            deleteImageFromDirectory(named: item.imageName)
                        }
                        self.realm.delete(item)
                    }
                    self.realm.delete(listForDeletion)
                }
            } catch{
                print("Error deleting category\(error)")
            }
        }
    }
    
    func deleteImageFromDirectory (named name: String) {
        let imagePath = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(name)
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: imagePath) {
            do {
                try fileManager.removeItem(atPath: imagePath)
            } catch {
                print(error)
            }
        }
    }
    
    func goToUserInputPopupAndChangeName (at indexPath: IndexPath) {
        
        if let chosenListeToUpdate = lists?[indexPath.row] {
            
            let userTextInputVC = UserTextInputViewController()
            userTextInputVC.changeName = changeName(_:_:_:)
            userTextInputVC.changingNameAndIcon = true
            userTextInputVC.listeToUpdate = chosenListeToUpdate
            userTextInputVC.modalPresentationStyle = .overCurrentContext
            
            self.present(userTextInputVC, animated: true, completion: nil)
        }
        
    }
    
    func addEventToCalendar(at indexpath: IndexPath) {
        chosenNameforCalendar = lists![indexpath.row].name
        checkCalendarAuthorizationStatus()
    }
    
    //strikes out the text
    func strikeOut(at indexPath: IndexPath) {
        if let itemForUpdate = self.lists?[indexPath.row] {
            do {
                try realm.write {
                    itemForUpdate.done = !itemForUpdate.done
                }
            }catch{
                print("error updating relm\(error)")
            }
            tableView.reloadData()
        }
    }
    
    //MARK: - DIFFERENT METHODS
    
    ///creates a liste and saves it in Realm
    func createListe (_ liste: Liste) ->() {
        save(list: liste)
        tableView.reloadData()
    }
    
    ///changes the list's name and the icon
    func changeName (_ liste: Liste, _ newName: String, _ newIconName: String ) ->() {
        do {
            try realm.write {
                liste.name = newName
                liste.iconName = newIconName
            }
        } catch {
            print("Error saving massage\(error)")
        }
        tableView.reloadData()
    }
    
    func threeHardCodedExamples () {
        let fisrtListe = Liste()
        fisrtListe.name = "Shopping list"
        fisrtListe.iconName = "shopping-cart-icon"
        save(list: fisrtListe)
        
        let secondListe = Liste()
        secondListe.name = "To do"
        secondListe.iconName = "todo-icon"
        save(list: secondListe)
        
        let thirdListe = Liste()
        thirdListe.name = "Travelpack"
        thirdListe.iconName = "airplane-icon"
        save(list: thirdListe)
        
    }
    
    //Checks if the app is being launched for the first time
    func isAppAlreadyLaunchedOnce()->Bool{
        let defaults = UserDefaults.standard
        
        if defaults.string(forKey: "isAppAlreadyLaunchedOnce") != nil{
            return true
        }else{
            defaults.set(true, forKey: "isAppAlreadyLaunchedOnce")
            return false
        }
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
        event.endDate = date.addingTimeInterval(timeIntervalForEndDate)
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
        
        let settingsAction = UIAlertAction(title: "Settings", style: .default) {(action) in
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
                DispatchQueue.main.async {
                    // UI work here
                    self!.goToPopupAndSetReminder()
                }  
            case .denied:
                self!.goToSettingsAllert(alertTitle: self!.settingsAlertTitleNotification, alertMessage: self!.settingAlertMessageNotification)
            case .notDetermined:
                print("casenotDetermined is highly unlikely")
                self!.goToSettingsAllert(alertTitle: self!.settingsAlertTitleNotification, alertMessage: self!.settingAlertMessageNotification)
            case .provisional:
                print("caseProvisional is highly unlikely")
                self!.goToSettingsAllert(alertTitle: self!.settingsAlertTitleNotification, alertMessage: self!.settingAlertMessageNotification)
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
