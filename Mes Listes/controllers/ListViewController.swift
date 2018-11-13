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
    let cellHeight: CGFloat = 70
    let titleFontSize: CGFloat = 28.5
    
    //MARK: - Properties
    let backgroundImageView: UIImageView = UIImageView()
    let tableView = UITableView()
    let backgroundImage = #imageLiteral(resourceName: "background-image")
    
    let realm = try! Realm()
    var lists : Results <Liste>?
    var chosenRow = 0
    var chosenNameforCalendar = ""
    var isSwipeRightEnabled = true
    
    
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadData(_:)), name: NSNotification.Name("ReloadNotification"), object: nil)
        

       
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
    
    @objc func reloadData(_ notification: Notification?) {
        tableView.reloadData()
        print("the size does change but not shows")
    }
    
    private func setupNavigationBar () {
        
        let title = "meslistes"
        self.title = title
        let attributes = [NSAttributedString.Key.font: UIFont(name: "Zing Sans Rust Regular", size: titleFontSize)!, NSAttributedString.Key.foregroundColor: UIColor.black]
        navigationController?.navigationBar.titleTextAttributes = attributes
        var rightImage = UIImage(named: "plus-icon")
        rightImage = rightImage?.withRenderingMode(.alwaysOriginal)
        let rightNavigationButton = UIBarButtonItem(image: rightImage, style: .plain, target: self, action: #selector (rightBarButtonAction))
       
        self.navigationItem.setRightBarButton(rightNavigationButton, animated: false)
        
    }
    
    //MARK: - Button ACTIONS
    @objc func rightBarButtonAction () {
        
        let userTextInputVC = UserTextInputViewController()
        userTextInputVC.createListe = createListe
        userTextInputVC.modalPresentationStyle = .overCurrentContext
        
        self.present(userTextInputVC, animated: true, completion: nil)
    }
    
    @objc func leftBarButtonAction () {
        
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
        tableView.register(ListeTableViewCell.self, forCellReuseIdentifier: "ListeTableViewController")
        
        tableView.backgroundColor = UIColor.clear
        
//        tableView.estimatedRowHeight  = 100
//        tableView.rowHeight = UITableView.automaticDimension

        tableView.separatorColor = UIColor.init(red: 251/255, green: 251/255, blue: 251/255, alpha: 1)
        tableView.separatorStyle = .singleLine
        tableView.separatorInset = .zero
    
        //tableView - separator height?
        view.addSubview(tableView)
        
    }

//    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
//        tableView.reloadData()
//        print("the font won't change")
//    }
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
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListeTableViewController", for: indexPath) as! ListeTableViewCell
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
            let strikeOut = SwipeAction(style: .default, title: nil) { (action, indexPath) in
                self.strikeOut(at: indexPath)
            }
            strikeOut.image = #imageLiteral(resourceName: "strikeout-icon")
            strikeOut.backgroundColor = self.colorize(hex: 0xF0D6E2)
            
            //REMINDER
            let setReminder = SwipeAction(style: .default, title: nil) { action, indexPath in
                self.updateModelByAddingAReminder(at: indexPath)
                let cell: SwipeTableViewCell = tableView.cellForRow(at: indexPath) as! SwipeTableViewCell
                cell.hideSwipe(animated: true)
            }
            setReminder.image = UIImage(named: "reminder-icon")
            setReminder.backgroundColor = self.colorize(hex: 0xF0D6E2)
            
            //CALENDAR
            let addEventToCalendar = SwipeAction(style: .default, title: nil) { (action, indexPath) in
                self.addEventToCalendar(at: indexPath)
                let cell: SwipeTableViewCell = tableView.cellForRow(at: indexPath) as! SwipeTableViewCell
                cell.hideSwipe(animated: true)
            }
            addEventToCalendar.image = #imageLiteral(resourceName: "calendar-icon")
            addEventToCalendar.backgroundColor = self.colorize(hex: 0xF0D6E2)
            
            return[strikeOut, setReminder, addEventToCalendar]
            
        }else{
            //DELETE
            let deleteAction = SwipeAction(style: .destructive, title: nil) { action, indexPath in
                self.deleteListe(at: indexPath)
            }
            deleteAction.image = #imageLiteral(resourceName: "trash-icon")
            deleteAction.backgroundColor = self.colorize(hex: 0xF25D61)
            
            return [deleteAction]
        }
        
    }
    //makes different expansion styles possible (such as deleting by swiping till it disappears)
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeTableOptions {
        
        var options = SwipeTableOptions()
        
        
        //diferent expansion styles
        options.expansionStyle = orientation == .left ? .selection : .destructive
        options.minimumButtonWidth = 70.0
        
        return options
    }
    
    func updateModelByAddingAReminder(at indexpath: IndexPath) {
        
        chosenRow = indexpath.row
        
        let dpVC = DatePickerPopupViewController()
        dpVC.modalPresentationStyle = .overCurrentContext
        dpVC.setReminder = setReminder
        self.present(dpVC, animated: true, completion: nil)
        tableView.reloadData()
    }
    
    //sends the notification to user to remind the list
    func setReminder (_ components: DateComponents) ->(){
        
        let content = UNMutableNotificationContent()
        content.title = "Don't forget!!!"
        content.body = lists![chosenRow].name
        content.sound = UNNotificationSound.default
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: "TestIdentifier", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { (error) in
            if let error = error {
                print(" We had an error: \(error)")
            }
        }
    }
    
    //deletes the list
    func deleteListe (at indexpath: IndexPath) {
        if let listForDeletion = self.lists?[indexpath.row]{
            do {
                try self.realm.write {
                    self.realm.delete(listForDeletion)
                }
            } catch{
                print("Error deleting category\(error)")
            }
        }
    }
    
    func addEventToCalendar(at indexpath: IndexPath) {
        
        chosenRow = indexpath.row
        chosenNameforCalendar = lists![indexpath.row].name
        
        let dpVC = DatePickerPopupViewController()
        dpVC.modalPresentationStyle = .overCurrentContext
        
        
        dpVC.dateForCalendar = true
        
        dpVC.saveEventToCalendar = saveEventToCalendar
        self.present(dpVC, animated: true, completion: nil)
        tableView.reloadData()
    }
    
    func saveEventToCalendar(_ date: Date) ->(){
        
        let eventStore = EKEventStore()
        
        eventStore.requestAccess(to: .event) { (granted, error) in
            if granted {
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
                
            }else{
                print("error getting access to calendar\(error!)")
            }
        }
    }
    
    //strikes out the text
    
    func strikeOut(at indexPath: IndexPath) {
        
        if let itemForUpdate = self.lists?[indexPath.row] {
            
            //changing the done property
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
//    ///adds icon to a liste and saves iconName in Realm
//    func addIconNameToListe (_ iconName: String)->() {
//        let newListe = Liste()
//        newListe.iconName = iconName
//        sa
//    }

    
    
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
        
        if let isAppAlreadyLaunchedOnce = defaults.string(forKey: "isAppAlreadyLaunchedOnce"){
            print("App already launched : \(isAppAlreadyLaunchedOnce)")
            return true
        }else{
            defaults.set(true, forKey: "isAppAlreadyLaunchedOnce")
            print("App launched first time")
            return false
        }
    }
}


//gets userInput from the textField
//    func userInputHandeled(){
//
//        if listTextField.text != "" {
//            let newList = Liste()
//            newList.name = listTextField.text!
//            self.save(list: newList)
//
//            DispatchQueue.main.async {
//                self.listTextField.resignFirstResponder()
//            }
//            listTextField.clearsOnBeginEditing = true
//            listTextField.text = ""
//            tableView.reloadData()

//        }









//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "goToItem" {
//            let destinationVC = segue.destination as! ItemTableViewController
//
//            if let indexPath = tableView.indexPathForSelectedRow {
//                destinationVC.selectedListe = lists?[indexPath.row]
//            }
//
//        }
//    }

//MARK: - GESTURE RECOGNIZER ADN TEXTFIELD METHODS
//hides the keyboard when tapped somewhere else
//    func hideKeyboardWhenTappedAround() {
//        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ListViewController.dismissKeyboard))
//        tap.cancelsTouchesInView = false
//        view.addGestureRecognizer(tap)
//        tap.delegate = self
//    }
//
//    @objc func dismissKeyboard() {
//        view.endEditing(true)
//    }

//function called by gestureRecognaizer and it returns false if it is a UIButton
//    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
//        // Don't handle button taps
//        print("false")
//        return !(touch.view is UIButton)
//
//    }
//    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
//
//        listTextField.text = ""
//        return true
//    }
//    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//
//        return true
//    }

