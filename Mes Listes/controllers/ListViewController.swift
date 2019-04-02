//
//  ItemViewController.swift
//  segue and swipe
//
//  Created by Anastasiia Tanczak on 16/06/2018.
//  Copyright © 2018 Ana Viktoriv. All rights reserved.
//

import UIKit
//import RealmSwift
import UserNotifications
import EventKit
import SwipeCellKit
import StoreKit

class ListViewController: UIViewController {
    
    
    
    private let cellIdentifier = "ListeTableViewController"
    var chosenNameforCalendar = ""

    //MARK: - Properties
    let backgroundImageView: UIImageView = UIImageView()
    let tableView = UITableView()
    
    let helperRealmManager = HelperRealmManager()

    var isSwipeRightEnabled = true
  
    let eventStore = EKEventStore()
   
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        setupView()
        setupLayout()
        
        countAppLaunchesSwitchOnThem()
    }
  
    private func setupNavigationBar () {
        
        self.title = NavigationBar.title
        navigationController?.navigationBar.titleTextAttributes = NavigationBar.titleAttributes
        NavigationBar.rightButtonImage = NavigationBar.rightButtonImage?.withRenderingMode(.alwaysOriginal)
        let rightNavigationButton = UIBarButtonItem(image: NavigationBar.rightButtonImage, style: .plain, target: self, action: #selector (rightBarButtonAction))
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
        self.view.layer.contents = ImageInListController.background.cgImage

        //tableView
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ListeTableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        tableView.backgroundColor = UIColor.clear
        tableView.separatorColor = Color.separatorCustomColor
        tableView.separatorStyle = .singleLine
        tableView.separatorInset = .zero
        
        view.addSubview(tableView)
    }
    
    private func setupLayout() {
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
            ])
    }
}

//MARK: - TableView DataSource and Delegate
extension ListViewController: UITableViewDelegate, UITableViewDataSource {
    
    // delegate methods
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let lists = helperRealmManager.lists else { return }
        
        let itemVC = ItemTableViewController()
        itemVC.selectedListe = lists[indexPath.row]
        self.show(itemVC, sender: self)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return ListConctollerCellMesurements.cellHeight
    }
    
    // data source methhods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return helperRealmManager.lists?.count ?? 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! ListeTableViewCell
        cell.delegate = self
        cell.fillWith(model: helperRealmManager.lists?[indexPath.row])
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
            strikeOut.image = ImageInListController.strikeOutForSwipeCell
            strikeOut.backgroundColor = Color.swipeCellBackgroundColorForDefault
            
            //REMINDER
            let setReminder = SwipeAction(style: .default, title: nil) { [weak self](action, indexPath) in
                self?.addReminder(at: indexPath)
                let cell: SwipeTableViewCell = tableView.cellForRow(at: indexPath) as! SwipeTableViewCell
                cell.hideSwipe(animated: true)
            }
            setReminder.image = ImageInListController.reminderForSwipeCell
            setReminder.backgroundColor = Color.swipeCellBackgroundColorForDefault
            
            //CALENDAR
            let addEventToCalendar = SwipeAction(style: .default, title: nil) {[weak self] (action, indexPath) in
                self?.addEventToCalendar(at: indexPath)
                let cell: SwipeTableViewCell = tableView.cellForRow(at: indexPath) as! SwipeTableViewCell
                cell.hideSwipe(animated: true)
            }
            addEventToCalendar.image = ImageInListController.addEventToCalendarForSwipeCell
            addEventToCalendar.backgroundColor = Color.swipeCellBackgroundColorForDefault
            
            return[strikeOut, setReminder, addEventToCalendar]
            
        }else{
            let changeTextAction = SwipeAction(style: .default, title: nil) { [weak self](action, indexpath) in
                self?.goToUserInputPopupAndChangeName(at: indexPath)
                let cell: SwipeTableViewCell = tableView.cellForRow(at: indexPath) as! SwipeTableViewCell
                cell.hideSwipe(animated: true)
            }
            changeTextAction.backgroundColor = Color.swipeCellBackgroundColorForDefault
            changeTextAction.image = ImageInListController.changeTitleForSwipeCell
            
            //DELETE
            let deleteAction = SwipeAction(style: .destructive, title: nil) {[weak self] (action, indexPath) in
                self?.deleteListe(at: indexPath)
            }
            deleteAction.image = ImageInListController.deleteForSwipeCell
            deleteAction.backgroundColor = Color.swipeCellBackGroundColorForDestructive
            
            return [deleteAction, changeTextAction]
        }
        
    }
    
    //makes different expansion styles possible (such as deleting by swiping till it disappears)
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeTableOptions {
        
        var options = SwipeTableOptions()
      
        //diferent expansion styles
        options.expansionStyle = orientation == .left ? .selection : .destructive
        options.minimumButtonWidth = ListConctollerCellMesurements.minimumSwipeCellWidth
        return options
    }
    
    func addReminder(at indexpath: IndexPath) {
        NotificationReminder.body = helperRealmManager.lists![indexpath.row].name
        getNotificationSettingStatus()
    }
    
    //deletes the list
    func deleteListe (at indexpath: IndexPath) {
        helperRealmManager.deleteListAndItsItems(atRow: indexpath.row)
    }
    
    func goToUserInputPopupAndChangeName (at indexPath: IndexPath) {

        if let chosenListeToUpdate = helperRealmManager.lists?[indexPath.row] {
            
            let userTextInputVC = UserTextInputViewController()
            userTextInputVC.changeName = changeName(_:_:_:)
            userTextInputVC.changingNameAndIcon = true
            userTextInputVC.listeToUpdate = chosenListeToUpdate
            userTextInputVC.modalPresentationStyle = .overCurrentContext
            
            self.present(userTextInputVC, animated: true, completion: nil)
        }
        
    }
    
    func addEventToCalendar(at indexpath: IndexPath) {
        chosenNameforCalendar = helperRealmManager.lists![indexpath.row].name
        checkCalendarAuthorizationStatus()
    }
    
    //strikes out the text
    func strikeOut(at indexPath: IndexPath) {
        helperRealmManager.updateIsDone(forListAtRow: indexPath.row)
        tableView.reloadData()
    }
    
    //MARK: - DIFFERENT METHODS
    func countAppLaunchesSwitchOnThem () {
        let currentCount = appLaunchCount()
        
        switch currentCount {
        case 1:
            threeHardCodedExamples()
            helperRealmManager.loadLists()
            tableView.reloadData()
        case 10, 50, 100:
            promtForReview()
            helperRealmManager.loadLists()
            tableView.reloadData()
        default:
            helperRealmManager.loadLists()
            tableView.reloadData()
        }
    }
    
    func appLaunchCount() -> Int {
        var currentCount = UserDefaults.standard.integer(forKey: "launchCount")
        currentCount += 1
        UserDefaults.standard.set(currentCount, forKey: "launchCount")
        return currentCount
    }
    
    func promtForReview() {
        if #available(iOS 10.3, *) {
            SKStoreReviewController.requestReview()
        }
    }
    
    ///creates a liste and saves it in Realm
    func createListe (_ liste: Liste) ->() {
        helperRealmManager.save(list: liste)
        tableView.reloadData()
    }
    
    ///changes the list's name and the icon
    func changeName (_ liste: Liste, _ newName: String, _ newIconName: String ) ->() {
        helperRealmManager.changeListName(liste, newName, newIconName)
        tableView.reloadData()
    }
    
    func threeHardCodedExamples () {
        let firstListe = Liste()
        firstListe.name = ListNames.name1
        firstListe.iconName = Icons.gray[3]
        helperRealmManager.save(list: firstListe)
        
        let secondListe = Liste()
        secondListe.name = ListNames.name2
        secondListe.iconName = Icons.gray[0]
        helperRealmManager.save(list: secondListe)
        
        let thirdListe = Liste()
        thirdListe.name = ListNames.name3
        thirdListe.iconName = Icons.gray[2]
        helperRealmManager.save(list: thirdListe)
        
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
        event.endDate = date.addingTimeInterval(TimeIntervals.timeIntervalForEndDate)
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
            goToSettingsAllert(alertTitle: SettingsAlert.title, alertMessage: SettingsAlert.message)
        }
    }
    
    func firstTimeAccessToCalendar () {
        
        eventStore.requestAccess(to: .event) {[weak self] (granted, error) in
            guard let `self` = self else {return}
            
            if granted {
                self.goToPopupAndSaveEvent()
            }else{
                self.goToSettingsAllert(alertTitle: SettingsAlert.title, alertMessage: SettingsAlert.message)
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
        
        DispatchQueue.main.async { [weak self] in
            self?.present(alert, animated: true, completion: nil)
        }
    }
    
    //MARK: - NOTIFICATION CENTER MATHODS (REMINDERS)
    
    func getNotificationSettingStatus () {
        
        UNUserNotificationCenter.current().getNotificationSettings {[weak self] (settings) in
            guard let `self` = self else {return}
            
            switch settings.authorizationStatus {
            case .authorized:
                DispatchQueue.main.async {
                    // UI work here
                    self.goToPopupAndSetReminder()
                }  
            case .denied, .notDetermined, .provisional:
                self.goToSettingsAllert(alertTitle: SettingsAlert.title, alertMessage: SettingsAlert.message)
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
        content.title = NotificationReminder.title
        content.body = NotificationReminder.body
        content.sound = UNNotificationSound.default
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: content.body, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { (error) in
            print(request.identifier)
            
            if let error = error {
                print(" We had an error: \(error)")
                
            }
        }
    }
}
