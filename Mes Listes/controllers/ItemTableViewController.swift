//
//  ItemTableViewController.swift
//  Mes Listes
//
//  Created by Anastasiia Tanczak on 24/06/2018.
//  Copyright © 2018 Ana Viktoriv. All rights reserved.
//

import UIKit
//import RealmSwift
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
    private let navigationBarTopInset: CGFloat = 0
    private let navigationBarBottomInset: CGFloat = 0
    private let navigationBarLeftInset: CGFloat = -4
    private let navigationBarRightInset: CGFloat = 0
    private let subviewForTextFieldAndPlusButtonCornerRadius: CGFloat = 10
    private let subviewForTextFieldAndPlusButtonBorderWidth: CGFloat = 1
    private let separatorInset: CGFloat = 0
    private let estimatedRowHeight: CGFloat = 100
    private let timeIntervalForCalendar: Double = 3600
    private let swipeCellMinimumButtonWidth: CGFloat = 45.0
    
    private let settingsAlertTitleCalendar = "The calendar permission was not authorized"
    private let settingsAlertMessageCalendar = "Please enable it in Settings to continue"
    private let settingsAlertTitleNotification = "Unable to use notifications"
    private let settingAlertMessageNotification = "Please go to Setting to change your preferences"
    private let settingAlertTitleCamera = "The camera permission was denied"
    private let settingAlertMessageCamera = "Please enable it in Settings to continue"
    private var chosenNameforCalendar = ""
    private var notificationTitle = ""
    private var notificationBody = ""
    
    private let leftNavigationBarButtonImage = #imageLiteral(resourceName: "back-button-icon")
    private let plusBottonImage = #imageLiteral(resourceName: "plus-icon-gray")
    private let backgroundImage = #imageLiteral(resourceName: "background-image")
    private let strikeOutImage = #imageLiteral(resourceName: "strikeout-item-icon")
    private let reminderImage = #imageLiteral(resourceName: "reminder-item-icon")
    private let addEventToCalendarImage = #imageLiteral(resourceName: "calendar-item-icon")
    private let deleteImage = #imageLiteral(resourceName: "delete-item-icon")
    private let takePhotoImage = #imageLiteral(resourceName: "camera-icon")
    private let changeTitleImage = UIImage(named: "editTitle-item-icon")
    
    private let swipeCellBackgroundColorCustomPink = UIColor.init(red: 240/255, green: 214/255, blue: 226/255, alpha: 1)
    private let swipeCellBackgroundColorCustomRed = UIColor.init(red: 242/255, green: 93/255, blue: 97/255, alpha: 1)
    private let swipeCellBackgroundColorCustomGray = UIColor.init(red: 185/255, green: 205/255, blue: 214/255, alpha: 1)
    
    private let navigationBarAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 19, weight: .light), NSAttributedString.Key.foregroundColor: UIColor.black]
    private let navigationBarAttributes2 = [NSAttributedString.Key.font: UIFont(name: "Zing Sans Rust Regular", size: 28.5)!, NSAttributedString.Key.foregroundColor: UIColor.black]
    
    //MARK: - Properties
    //let realm = try! Realm()
   
    
    //get access to shared instance of the file manager
    let helperFileManager = HelperFileManager()
    let helperRealmManager = HelperRealmManager()
    
    var nameOfTheSelectedListe = ""
    var selectedRowToAddTheImage: Int?
    
    ///indexPath to deselect when scroll begins
    var indexPathForCelectedCell: IndexPath?
    
    ///indexPath to change itemTitle
    var indexPathForItemToBEChanged: IndexPath?
   
    var isSwipeRightEnabled = true
    /// indexPath of the cell that has been swiped
    var indexPathForSwipedCell: IndexPath?

    let eventStore = EKEventStore()
    
    private let backgroundImageView = UIImageView()
    private let subviewForTextFieldAndPlusButton = UIView()
    private let textFieldItems = UITextField()
    private let plusButton = UIButton()
    private let tableView = UITableView()
    
    var selectedListe : Liste? {
        didSet {
            guard let listIsSet = selectedListe else {return}
            helperRealmManager.loadItems(for: listIsSet)
            tableView.reloadData()
        }
    }
    
    private var imagePicker = UIImagePickerController()

    //MARK: - Life Cycle
    
    override func viewWillAppear(_ animated: Bool) {
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        if tableView.indexPathsForVisibleRows?.isEmpty == false {
        guard let keyboardFrame = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue else { return }
        let convertedFrame = view.convert(keyboardFrame, from: nil)
        tableView.contentInset.bottom = convertedFrame.height + 50
    }
    }

    @objc func keyboardWillHide(notification: Notification) {
        if tableView.indexPathsForVisibleRows?.isEmpty == false {
            
        tableView.contentInset.bottom = 0
        tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
    }
    }
   
    override func viewDidLoad() {
         super.viewDidLoad()
        

        setupNavigationBar()
        setupViews()
        setupLayout()
        
        imagePicker.delegate = self
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        NotificationCenter.default.removeObserver(self)
    }


    private func setupNavigationBar () {
        
        let title = selectedListe?.name.uppercased() ?? "meslistes"
        self.title = title
        
        navigationController?.navigationBar.titleTextAttributes = navigationBarAttributes
        
        let leftNavigationButton = UIBarButtonItem(image: leftNavigationBarButtonImage , style: .plain, target: self, action: #selector(leftBarButtonAction))
        leftNavigationButton.tintColor = .black
        leftNavigationButton.imageInsets  = .init(top: navigationBarTopInset, left: navigationBarLeftInset, bottom: navigationBarBottomInset, right: navigationBarRightInset)
        
        self.navigationItem.setLeftBarButton(leftNavigationButton, animated: false)

    }
    
    private func setupViews () {

    self.view.layer.contents = backgroundImage.cgImage
//        // backgroundImageView
//        backgroundImageView.image = backgroundImage
//        backgroundImageView.contentMode = .scaleAspectFill
//
//        view.addSubview(backgroundImageView)
        
        //subviewForTextField
        subviewForTextFieldAndPlusButton.backgroundColor = .clear
        subviewForTextFieldAndPlusButton.layer.borderColor = UIColor.white.cgColor
        subviewForTextFieldAndPlusButton.layer.cornerRadius = subviewForTextFieldAndPlusButtonCornerRadius
        subviewForTextFieldAndPlusButton.layer.borderWidth = subviewForTextFieldAndPlusButtonBorderWidth

        view.addSubview(subviewForTextFieldAndPlusButton)
        
        //textField
        textFieldItems.backgroundColor = .clear
        textFieldItems.placeholder = textFieldPlaceholderText
        textFieldItems.delegate = self
        textFieldItems.returnKeyType = UIReturnKeyType.next

        //textFieldItems.becomeFirstResponder()
        subviewForTextFieldAndPlusButton.addSubview(textFieldItems)
        
        //plusButton
        plusButton.setImage(plusBottonImage, for: .normal)
        plusButton.addTarget(self, action: #selector(plusButtonAction), for: .touchUpInside)
        subviewForTextFieldAndPlusButton.addSubview(plusButton)
        
        //tableView
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ItemTableViewCell.self, forCellReuseIdentifier: "ItemTableViewCell")
        tableView.backgroundColor = UIColor.clear
        tableView.separatorColor = UIColor.white
        tableView.separatorStyle = .singleLine
        tableView.separatorInset = .init(top: separatorInset, left: separatorInset, bottom: separatorInset, right: separatorInset)
        tableView.estimatedRowHeight = estimatedRowHeight
        tableView.rowHeight = UITableView.automaticDimension
        view.addSubview(tableView)
        
    }
    
    private func setupLayout() {
        
       // backgroundImageView.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor)
        
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
        userInputHandeled()
    }
    
    @objc func leftBarButtonAction () {
        //TODO: Delete all empty items
//        if let itemsArray = items {
//            for item in itemsArray {
//                if item.title == "" {
//                    if item.hasImage {
//                        deleteImageFromDirectory(named: item.imageName)
//                    }
//                    
//                    do {
//                        try self.realm.write {
//                            self.realm.delete(item)
//                        }
//                    }catch{
//                        print("Error deleting items with empty titlmes\(error)")
//                }
//                }
//            }
//        }

        
        navigationController?.navigationBar.titleTextAttributes = navigationBarAttributes2
        _ = navigationController?.popToRootViewController(animated: true)
        
    }
    
    //MARK: - Different Methods REALM
    

    
    func userInputHandeled(){
        
        if textFieldItems.text != ""{
            guard let textInput = textFieldItems.text else {return}
            
            if  indexPathForItemToBEChanged != nil {
                
                if let itemToBeEdited = helperRealmManager.items?[indexPathForItemToBEChanged!.row]{
                    
                    helperRealmManager.changeItemTitle(for: itemToBeEdited, newTitle: textInput)
                    
                    indexPathForItemToBEChanged =  nil
                }
            }else{
                guard let currentListe = selectedListe else {return}
                helperRealmManager.createItem(in: currentListe, named: textInput)
            }
            
            textFieldItems.text = ""
            tableView.reloadData()
            
        }else{
            //TODO: - Textfield empty
            
        }
    }
        
    

    
    //Different Methods
    
    //MARK: - EVENTKIT AND CALENDAR METHODS
    
    func goToPopupAndSaveEvent () {
 
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
        event.endDate = date.addingTimeInterval(timeIntervalForCalendar)
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
       
        DispatchQueue.main.sync { [weak self] in
        self?.present(alert, animated: true, completion: nil)
        }
    }
    //MARK: - NOTIFICATION CENTER MATHODS (REMINDERS)
    
    func getNotificationSettingStatus () {
        
        UNUserNotificationCenter.current().getNotificationSettings {[weak self] (settings) in
            
            switch settings.authorizationStatus {
            case .authorized:
                DispatchQueue.main.sync {
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
   
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return helperRealmManager.items?.count ?? 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemTableViewCell", for: indexPath) as! ItemTableViewCell
        cell.delegate = self
        cell.itemDelegate = self
        cell.fillWith(model: helperRealmManager.items?[indexPath.row])
        cell.titleTextView.font = UIFont.preferredFont(forTextStyle: .body)
        cell.titleTextView.adjustsFontForContentSizeCategory = true
        cell.titleTextView.isEditable = false
        cell.backgroundColor = UIColor.clear
       
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    
}

//MARK: - ItemCell Button Actions

extension ItemTableViewController: ItemCellProtocol {
    
    func cellDidTapOnButton(at index: IndexPath) {

        if let currentItem = helperRealmManager.items?[index.row] {
            let imageVC = ImageVC()
            imageVC.imageName = currentItem.imageName
            imageVC.modalPresentationStyle = .overCurrentContext
            present(imageVC, animated: true)
        }
    }
    

    func getIdexPath (for cell: ItemTableViewCell) -> IndexPath? {
        return tableView.indexPath(for: cell)
    }
    
    func getImageForButton (named imageName: String) -> UIImage {
        let image = helperFileManager.getImage(imageName: imageName)
        return image
    }
    
}

    //MARK: - METHODS FOR SWIPE ACTIONS
extension ItemTableViewController: SwipeTableViewCellDelegate {

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {

        indexPathForSwipedCell = indexPath
        self.textFieldItems.resignFirstResponder()
        
        if orientation == .left {
            guard isSwipeRightEnabled else { return nil }
            
            //STRIKE OUT
            let strikeOut = SwipeAction(style: .default, title: nil) { [weak self] (action, indexPath) in
                self?.strikeOut(at: indexPath)
                tableView.reloadRows(at: [indexPath], with: .automatic)
            }
            strikeOut.image = strikeOutImage
            strikeOut.backgroundColor = swipeCellBackgroundColorCustomPink
            
             //REMINDER
            let setReminder = SwipeAction(style: .default, title: nil) {[weak self] (action, indexPath) in
                self?.updateModelByAddingAReminder(at: indexPath)
                let cell: SwipeTableViewCell = tableView.cellForRow(at: indexPath) as! SwipeTableViewCell
                cell.hideSwipe(animated: true)
            }
            setReminder.image = reminderImage
            setReminder.backgroundColor = swipeCellBackgroundColorCustomPink
            
             //CALENDAR
            let addEventToCalendar = SwipeAction(style: .default, title: nil) {[weak self] (action, indexPath) in
                self?.addEventToCalendar(at: indexPath)
                let cell: SwipeTableViewCell = tableView.cellForRow(at: indexPath) as! SwipeTableViewCell
                cell.hideSwipe(animated: true)
            }
            addEventToCalendar.image = addEventToCalendarImage
            addEventToCalendar.backgroundColor = swipeCellBackgroundColorCustomPink
            
            return[strikeOut, setReminder, addEventToCalendar]
            
        }else{
             //DELETE
            let deleteAction = SwipeAction(style: .destructive, title: nil) {[weak self] (action, indexPath) in
                self?.deleteItem(at: indexPath)
            }
            deleteAction.image = deleteImage
            deleteAction.backgroundColor = swipeCellBackgroundColorCustomRed
            
            //take photo
            let takePhotoAction = SwipeAction(style: .default, title: nil) {[weak self] (action, indexpath) in
              
                self!.selectedRowToAddTheImage = indexPath.row
                self!.takePhotoAndSaveIt()
                
                let cell: SwipeTableViewCell = tableView.cellForRow(at: indexPath) as! SwipeTableViewCell
                cell.hideSwipe(animated: true)
            }
            takePhotoAction.backgroundColor = swipeCellBackgroundColorCustomGray
            takePhotoAction.image = takePhotoImage
            
            //edit title
            let editTitleAction = SwipeAction(style: .default, title: nil) {[weak self] (action, indexpath) in
                self?.showTitleToChangeInTextField(at: indexPath)
                let cell: SwipeTableViewCell = tableView.cellForRow(at: indexPath) as! SwipeTableViewCell
                cell.hideSwipe(animated: true)
            }
            editTitleAction.backgroundColor = swipeCellBackgroundColorCustomGray
            editTitleAction.image = changeTitleImage
            
            return [deleteAction, takePhotoAction, editTitleAction]
        }
        
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeTableOptions {
        
        var options = SwipeTableOptions()

        
        //diferent expansion styles
        options.expansionStyle = orientation == .left ? .selection : .destructive
        options.minimumButtonWidth = swipeCellMinimumButtonWidth
        return options
    }
    
    func deleteItem(at indexpath: IndexPath) {
        indexPathForItemToBEChanged = nil
        textFieldItems.text = ""
        
        helperRealmManager.deleteItemFromRealm(at: indexpath.row)
    }
    
    func updateModelByAddingAReminder(at indexpath: IndexPath) {
        
        notificationTitle = helperRealmManager.items![indexpath.row].title
        getNotificationSettingStatus()
    }
    

    
    func addEventToCalendar(at indexpath: IndexPath) {

        chosenNameforCalendar = helperRealmManager.items![indexpath.row].title
        checkCalendarAuthorizationStatus()
    }
    
    
    //strikes out the text
    func strikeOut(at indexPath: IndexPath) {
       helperRealmManager.updateIsDoneForItem(at: indexPath.row)
    }
    
    func showTitleToChangeInTextField(at indexPath: IndexPath) {
        if let currentItem = helperRealmManager.items?[indexPath.row] {
            indexPathForItemToBEChanged = indexPath
            textFieldItems.text = currentItem.title
            textFieldItems.becomeFirstResponder()
        }
    }
    
}



extension ItemTableViewController: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        return true
    }
        
    func textFieldDidBeginEditing(_ textField: UITextField) {
        //self.tableView.setEditing(false, animated: true)
    }
    

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == textFieldItems {
        userInputHandeled()
        return true
        }
        return false
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        //userInputHandeled()
        textField.text = ""
        indexPathForItemToBEChanged = nil
        return true
    }
}

extension ItemTableViewController {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        print(scrollView)
        
        self.textFieldItems.resignFirstResponder()
        self.textFieldItems.text = ""
        if let indexPath = indexPathForCelectedCell {
        tableView.deselectRow(at: indexPath, animated: true)
        }
        //tableView.reloadData()
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

            present(alert, animated: true, completion: nil)

        
    }
    
    func openCamera(){
        
            if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerController.SourceType.camera)){
                
                imagePicker.sourceType = UIImagePickerController.SourceType.camera
                imagePicker.allowsEditing = true
                
                present(imagePicker, animated: true, completion: nil)
                
            }else{
                let alert  = UIAlertController(title: "Warning", message: "You don't have camera", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                present(alert, animated: true, completion: nil)
            }
        
    }
    
    func openGallery()
    {
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }
    
    func checkForCameraAuthorizationStaturs ()
    {
        let cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch cameraAuthorizationStatus
        {
        case .notDetermined: requestCameraPermission()
        case .authorized:
           DispatchQueue.main.async {[weak self] in
            self?.openCamera()
            }
        case .restricted, .denied: goToSettingsAllert(alertTitle: settingAlertTitleCamera, alertMessage: settingAlertMessageCamera)
        }
    }

    func requestCameraPermission() {
        AVCaptureDevice.requestAccess(for: .video, completionHandler: {[weak self] accessGranted in
            guard accessGranted == true else { return }
            DispatchQueue.main.async {[weak self] in
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
        let itemID = getItemID()
        //chose random name for the image
        
        if let itemIDString = itemID {
            
            let nameForSavedImage = helperFileManager.saveImageToDocumentDirectory(named: image, for: itemIDString)
            
            if let selectedRow = selectedRowToAddTheImage
            {
                helperRealmManager.saveImageNameAsStringToRealm(named: nameForSavedImage, at: selectedRow)
            }
            tableView.reloadData()
        }
    }
}

//MARK: - Saving Photo functions realm

extension ItemTableViewController
{
    func getItemID () -> String? {
        if let selectedRow = selectedRowToAddTheImage {
            if let currentItem = helperRealmManager.items?[selectedRow] {
                let itemID = currentItem.id
                return itemID
            }
        }
        return nil
    }
}
    




    


