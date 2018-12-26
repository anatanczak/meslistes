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
import AVFoundation

class ItemTableViewController: UIViewController {
    //MARK: - Constants
    private let textFieldPlaceholderText = "Type your item here..."
    private let textFieldHeight: CGFloat = 40
    private let textFieldAndPlusButtonPadding: CGFloat = 10
    private let subviewTextFiledPaddingRightLeft: CGFloat = 5
    private let distanceBetweenTextfieldAndTableView: CGFloat = 10
    private let borderSubView: CGFloat = 1
    private let settingsAlertTitleCalendar = "The calendar permission was not authorized"
    private let settingsAlertMessageCalendar = "Please enable it in Settings to continue"
    private let settingsAlertTitleNotification = "Unable to use notifications"
    private let settingAlertMessageNotification = "Please go to Setting to change your preferences"
    private let settingAlertTitleCamera = "The camera permission was denied"
    private let settingAlertMessageCamera = "Please enable it in Settings to continue"
    private var chosenNameforCalendar = ""
    private var notificationTitle = ""
    private var notificationBody = ""
    //private var rowForSelectedItem = 0
    
    //MARK: - Properties
    let realm = try! Realm()
    var items : Results <Item>?
    
    //get access to shared instance of the file manager
    let fileManager = FileManager.default
    
    var nameOfTheSelectedListe = ""
    var selectedRowToAddTheImage: Int?
    
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
    
    private var imagePicker = UIImagePickerController()

    //MARK: - Life Cycle
    
    override func viewWillAppear(_ animated: Bool) {
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        guard let keyboardFrame = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue else { return }
        let convertedFrame = view.convert(keyboardFrame, from: nil)
        tableView.contentInset.bottom = convertedFrame.height + 50
    }

    @objc func keyboardWillHide(notification: Notification) {
        tableView.contentInset.bottom = 0
        tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
    }
    
    
    override func viewDidLoad() {
         super.viewDidLoad()
        

        setupNavigationBar()
        setupViews()
        setupLayout()
        
        imagePicker.delegate = self
        
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

        //textFieldItems.becomeFirstResponder()
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
                        newItem.id = UUID().uuidString
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

    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return items?.count ?? 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemTableViewCell", for: indexPath) as! ItemTableViewCell
        cell.delegate = self
        cell.itemDelegate = self
        cell.fillWith(model: items?[indexPath.row])
        cell.titleTextView.font = UIFont.preferredFont(forTextStyle: .body)
        cell.titleTextView.adjustsFontForContentSizeCategory = true
        cell.backgroundColor = UIColor.clear
        cell.indexpath = indexPath
        
        return cell
    }
    
}

//MARK: - ItemCell Button Actions

extension ItemTableViewController: ItemCellProtocol {
    
    func cellDidTapOnButton(at index: IndexPath) {
    
        print("buton tapped")
        if let currentItem = items?[index.row] {
            let imageVC = ImageVC()
            imageVC.imageName = currentItem.imageName
            imageVC.modalPresentationStyle = .overCurrentContext
            present(imageVC, animated: true)
        }
    }
    
    func changeItemTitleAndSaveItToRealm(at index: IndexPath, newTitle newImput: String) {
            if let currentItem = items?[index.row] {
                do {
                    try realm.write {
                        currentItem.title = newImput
                    }
                } catch {
                    print("error saving new title to realm\(error)")
                }
            }
    }
    
    func updateTableView() {
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    

    

    
    
//    func tableViewCell(doubleTapActionDelegatedFrom cell: ItemTableViewCell) {
//        //let indexPath = tableView.indexPath(for: cell)
//        DispatchQueue.main.sync {
//            //cell.backgroundCellView.backgroundColor = .black
//        }
//        
//        
//    }
//    func tableViewCell(singleTapActionDelegatedFrom cell: ItemTableViewCell) {
//        //let indexPath = tableView.indexPath(for: cell)
//         DispatchQueue.main.sync {
//        //cell.backgroundCellView.backgroundColor = .blue
//        }
//    }
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
                self.deleteItem(at: indexPath)
            }
            deleteAction.image = #imageLiteral(resourceName: "delete-item-icon")
            deleteAction.backgroundColor = self.colorize(hex: 0xF25D61)
            
            //take photo
            let takePhotoAction = SwipeAction(style: .default, title: nil) {[weak self] (action, indexpath) in
                //take photo action
                print("photo has been taken")
               
                self!.selectedRowToAddTheImage = indexPath.row
                self!.takePhotoAndSaveIt()
                
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
    
    func deleteItem(at indexpath: IndexPath) {
        if let itemForDeletion = self.items?[indexpath.row] {
            if itemForDeletion.hasImage {
                deleteImageFromDirectory(named: itemForDeletion.imageName)
            }
            
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

//MARK: - UIImagePicker extension
extension ItemTableViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    func takePhotoAndSaveIt ()
    {
        alertToChoseCameraOrPhotoLibrary()
    }
    
    func alertToChoseCameraOrPhotoLibrary ()
    {
        let alert = UIAlertController(title: "Chose image", message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { [weak self] (action) in
            self!.checkForCameraAuthorizationStaturs()
        }))
        
        alert.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { [weak self] (action) in
            self!.openGallery()
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func openCamera()
    {
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerController.SourceType.camera))
        {
            
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        }
        else
        {
            let alert  = UIAlertController(title: "Warning", message: "You don't have camera", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func openGallery()
    {
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        imagePicker.allowsEditing = true
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func checkForCameraAuthorizationStaturs ()
    {
        let cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch cameraAuthorizationStatus
        {
        case .notDetermined: requestCameraPermission()
        case .authorized: openCamera()
        case .restricted, .denied: goToSettingsAllert(alertTitle: settingAlertTitleCamera, alertMessage: settingAlertMessageCamera)
        }
    }

    func requestCameraPermission() {
        AVCaptureDevice.requestAccess(for: .video, completionHandler: {[weak self] accessGranted in
            guard accessGranted == true else { return }
            DispatchQueue.main.sync {
                self!.openCamera()
            }
        })
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        guard let image = info[.editedImage] as? UIImage else {
            print("No image found")
            return
        }
        
        // print out the image size as a test
        saveImageToDocumentDirectory(named: image)
        tableView.reloadData()
        
    }
}

//MARK: - File Manager and Saving Photo functions

extension ItemTableViewController
{
    func saveImageToDocumentDirectory (named image: UIImage)
    {

        //get the url for the users home directory
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        //get the URL as a string
        //let documetnPath = documentsURL.path
        
        let itemID = getItemID()
        //chose random name for the image
        
        if let itemIDString = itemID {
            
            let nameForImage = "\(itemIDString).png"
            
            //create the variable that stores the name
            let filePath = documentsURL.appendingPathComponent("\(nameForImage)")
            
            //save the name to realm
            saveImageNameAsStringToRealm(nameForImage)
            
            //write data
            do {
                try UIImage.pngData(image)()!.write(to: filePath)
            } catch {
                print(error)
            }
        }
    }
    
    func deleteImageFromDirectory (named name: String) {
        let imagePath = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(name)
        if fileManager.fileExists(atPath: imagePath) {
            do {
                try fileManager.removeItem(atPath: imagePath)
            } catch {
                print(error)
            }
        }
    }
    
    func saveImageNameAsStringToRealm (_ imageName: String)
    {
        if let selectedRow = selectedRowToAddTheImage
        {
            if let currentItem = self.items?[selectedRow]
            {
                do {
                    try realm.write
                    {
                        currentItem.hasImage = true
                        currentItem.imageName = imageName
                    }
                }
                catch
                {
                    print("error updating realm\(error)")
                }
            }
        }
    }
    
    func getItemID () -> String? {
        if let selectedRow = selectedRowToAddTheImage {
            if let currentItem = self.items?[selectedRow] {
                let itemID = currentItem.id
                return itemID
            }
        }
        return nil
    }
        
}
    




    


