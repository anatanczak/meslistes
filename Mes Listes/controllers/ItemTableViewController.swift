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
import Photos

class ItemTableViewController: UIViewController {
    
    //MARK: - Constants
    let subviewTextFiledPaddingRightLeft: CGFloat = 5
    
    private let borderSubView: CGFloat = 1
    
    //!!!!!!!NavigationBarImageInsets
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
    
    
    private var chosenNameforCalendar = ""
    
    
    private let leftNavigationBarButtonImage = #imageLiteral(resourceName: "back-button-icon")
    private let plusBottonImage = #imageLiteral(resourceName: "plus-icon-gray")
    private let backgroundImage = #imageLiteral(resourceName: "background-image")
    private let strikeOutImage = #imageLiteral(resourceName: "strikeout-item-icon")
    private let reminderImage = #imageLiteral(resourceName: "reminder-item-icon")
    private let addEventToCalendarImage = #imageLiteral(resourceName: "calendar-item-icon")
    private let deleteImage = #imageLiteral(resourceName: "delete-item-icon")
    private let takePhotoImage = #imageLiteral(resourceName: "camera-icon")
    private let changeTitleImage = UIImage(named: "editTitle-item-icon")
    
    
    private let navigationBarAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 19, weight: .light),
                                           // DDDAAAARRRKK
        NSAttributedString.Key.foregroundColor:
            UIColor (named: "popUpButtonFont")]
    //    NSAttributedString.Key.foregroundColor: UIColor.black]
    private let navigationBarAttributes2 = [NSAttributedString.Key.font: UIFont(name: "Zing Sans Rust Regular", size: 28.5)!,
                                            // DDAAARRRRKKK
        NSAttributedString.Key.foregroundColor:
            UIColor (named: "popUpButtonFont")]
    
    //NSAttributedString.Key.foregroundColor: UIColor.black]
    
    //MARK: - Properties
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
        
        navigationController?.navigationBar.titleTextAttributes = navigationBarAttributes as [NSAttributedString.Key : Any]
        
        let leftNavigationButton = UIBarButtonItem(image: leftNavigationBarButtonImage , style: .plain, target: self, action: #selector(leftBarButtonAction))
        // DAAAARRRKKKKK
        leftNavigationButton.tintColor = UIColor (named: "popUpButtonFont")
        
        //            .black
        leftNavigationButton.imageInsets  = .init(top: navigationBarTopInset, left: navigationBarLeftInset, bottom: navigationBarBottomInset, right: navigationBarRightInset)
        
        self.navigationItem.setLeftBarButton(leftNavigationButton, animated: false)
        
    }
    
    private func setupViews () {
        
        //        self.view.layer.contents = backgroundImage.cgImage
        //        self.view.layer.contentsGravity = .center
        
        
        // backgroundImageView
        backgroundImageView.image = backgroundImage
        backgroundImageView.contentMode = .scaleAspectFill
        
        view.addSubview(backgroundImageView)
        
        //subviewForTextField
        subviewForTextFieldAndPlusButton.backgroundColor = .clear
        
        //  DDAAAARRRRKKKK
        subviewForTextFieldAndPlusButton.layer.borderColor = UIColor(named: "separatorCustomColor")?.cgColor 
        //            UIColor.white.cgColor
        
        subviewForTextFieldAndPlusButton.layer.cornerRadius = subviewForTextFieldAndPlusButtonCornerRadius
        subviewForTextFieldAndPlusButton.layer.borderWidth = subviewForTextFieldAndPlusButtonBorderWidth
        
        view.addSubview(subviewForTextFieldAndPlusButton)
        
        //textField
        textFieldItems.backgroundColor = .clear
        textFieldItems.placeholder = TextFieldItems.placeholderText
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
        tableView.separatorColor = Color.separatorCustomColor
        tableView.separatorStyle = .singleLine
        tableView.separatorInset = .init(top: separatorInset, left: separatorInset, bottom: separatorInset, right: separatorInset)
        tableView.estimatedRowHeight = estimatedRowHeight
        tableView.rowHeight = UITableView.automaticDimension
        view.addSubview(tableView)
        
    }
    
    private func setupLayout() {
        
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        
        backgroundImageView.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor)
        
        //subViewTextField
        subviewForTextFieldAndPlusButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            subviewForTextFieldAndPlusButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            subviewForTextFieldAndPlusButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: subviewTextFiledPaddingRightLeft),
            subviewForTextFieldAndPlusButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -subviewTextFiledPaddingRightLeft),
            subviewForTextFieldAndPlusButton.heightAnchor.constraint(equalToConstant: TextFieldItems.height + 2 * borderSubView)
        ])
        
        
        //textField
        textFieldItems.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            textFieldItems.topAnchor.constraint(equalTo: subviewForTextFieldAndPlusButton.topAnchor, constant: borderSubView),
            textFieldItems.leadingAnchor.constraint(equalTo: subviewForTextFieldAndPlusButton.leadingAnchor, constant: TextFieldItems.distanceFromPlusButton),
            textFieldItems.heightAnchor.constraint(equalToConstant: TextFieldItems.height)
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
            tableView.topAnchor.constraint(equalTo: subviewForTextFieldAndPlusButton.bottomAnchor, constant: TextFieldItems.distanceFromTableView),
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
        
        
        navigationController?.navigationBar.titleTextAttributes = navigationBarAttributes2 as [NSAttributedString.Key : Any]
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
            
            goToSettingsAllert()
        @unknown default:
            print("unknown case of authorisationStatus")
        }
    }
    
    func firstTimeAccessToCalendar () {
        
        eventStore.requestAccess(to: .event) {[weak self] (granted, error) in
            if granted {
                self?.goToPopupAndSaveEvent()
            }else{
                self?.goToSettingsAllert()
            }
        }
    }
    
    
    func goToSettingsAllert () {
        
        let alert = UIAlertController(title: SettingsAlert.title, message: SettingsAlert.message, preferredStyle: .alert)
        
        let settingsAction = UIAlertAction(title: SettingsAlert.settingActionTitle, style: .default) { (action) in
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
        
        let cancelAction = UIAlertAction(title: SettingsAlert.cancelActionTitle, style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        
        DispatchQueue.main.async { [weak self] in
            self?.present(alert, animated: true, completion: nil)
        }
    }
    //MARK: - NOTIFICATION CENTER MATHODS (REMINDERS)
    
    func getNotificationSettingStatus () {
        
        UNUserNotificationCenter.current().getNotificationSettings {[weak self] (settings) in
            
            switch settings.authorizationStatus {
            case .authorized:
                DispatchQueue.main.async {
                    self!.goToPopupAndSetReminder()
                }
            case .denied, .provisional,.notDetermined:
                self!.goToSettingsAllert()
            @unknown default:
                print("unknown case of authorisationStatus")
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
        content.title = NotificationReminder.title
        content.body = NotificationReminder.body
        content.sound = UNNotificationSound.default
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: NotificationReminder.body, content: content, trigger: trigger)
        
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
        
        //        DARRRRK color of text cell'u
        //        cell.titleTextView.textColor = UIColor (named: "itemsVCcellTextColour")
        
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
            strikeOut.backgroundColor = Color.swipeCellBackgroundColorForDefault
            
            //REMINDER
            let setReminder = SwipeAction(style: .default, title: nil) {[weak self] (action, indexPath) in
                self?.updateModelByAddingAReminder(at: indexPath)
                let cell: SwipeTableViewCell = tableView.cellForRow(at: indexPath) as! SwipeTableViewCell
                cell.hideSwipe(animated: true)
            }
            setReminder.image = reminderImage
            setReminder.backgroundColor = Color.swipeCellBackgroundColorForDefault
            
            //CALENDAR
            let addEventToCalendar = SwipeAction(style: .default, title: nil) {[weak self] (action, indexPath) in
                self?.addEventToCalendar(at: indexPath)
                let cell: SwipeTableViewCell = tableView.cellForRow(at: indexPath) as! SwipeTableViewCell
                cell.hideSwipe(animated: true)
            }
            addEventToCalendar.image = addEventToCalendarImage
            addEventToCalendar.backgroundColor = Color.swipeCellBackgroundColorForDefault
            
            return[strikeOut, setReminder, addEventToCalendar]
            
        }else{
            //DELETE
            let deleteAction = SwipeAction(style: .destructive, title: nil) {[weak self] (action, indexPath) in
                self?.deleteItem(at: indexPath)
            }
            deleteAction.image = deleteImage
            deleteAction.backgroundColor = Color.swipeCellBackGroundColorForDestructive
            
            //take photo
            let takePhotoAction = SwipeAction(style: .default, title: nil) {[weak self] (action, indexpath) in
                guard let `self` = self else {return}
                
                self.selectedRowToAddTheImage = indexPath.row
                
                
                self.alertToChoseCameraOrPhotoLibrary()
                
                let cell: SwipeTableViewCell = tableView.cellForRow(at: indexPath) as! SwipeTableViewCell
                cell.hideSwipe(animated: true)
            }
            takePhotoAction.backgroundColor = Color.swipeCellBackgroundColorForDefault
            takePhotoAction.image = takePhotoImage
            
            //edit title
            let editTitleAction = SwipeAction(style: .default, title: nil) {[weak self] (action, indexpath) in
                self?.showTitleToChangeInTextField(at: indexPath)
                let cell: SwipeTableViewCell = tableView.cellForRow(at: indexPath) as! SwipeTableViewCell
                cell.hideSwipe(animated: true)
            }
            editTitleAction.backgroundColor = Color.swipeCellBackgroundColorForDefault
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
        
        NotificationReminder.body = helperRealmManager.items![indexpath.row].title
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
    
    
    func alertToChoseCameraOrPhotoLibrary (){
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: AlertCameraPhotoLibrary.cameraActionTitle, style: .default, handler: { [weak self] (action) in
            self?.checkForCameraAuthorizationStaturs()
        }))
        
        alert.addAction(UIAlertAction(title: AlertCameraPhotoLibrary.photoLibraryActionTitle, style: .default, handler: { [weak self] (action) in
            self?.checkPhotoLibraryAuthorization()
        }))
        
        alert.addAction(UIAlertAction(title: AlertCameraPhotoLibrary.cancelActionTitle, style: .cancel, handler: nil))
        
        DispatchQueue.main.async {[weak self] in
            self?.present(alert, animated: true, completion: nil)
        }
        
        
        
    }
    
    func openCamera(){
        
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerController.SourceType.camera)){
            
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            imagePicker.allowsEditing = true
            
            
            present(imagePicker, animated: true, completion: nil)
            
        }else{
            let alert  = UIAlertController(title: NoCameraAlert.title, message: NoCameraAlert.message , preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: NoCameraAlert.okActionTitle, style: .default, handler: nil))
            
            DispatchQueue.main.async {[weak self] in
                self?.present(alert, animated: true, completion: nil)
            }
        }
        
    }
    
    func openPhotoLibrary(){
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }
    
    func checkForCameraAuthorizationStaturs (){
        
        let cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch cameraAuthorizationStatus{
        case .notDetermined: requestCameraPermission()
        case .authorized:
            DispatchQueue.main.async {[weak self] in
                self?.openCamera()
            }
        case .restricted, .denied: goToSettingsAllert()
        @unknown default:
            print("unknown case of authorisationStatus")
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
        print("image taken")
        guard let image = info[.editedImage] as? UIImage else {
            print("No image found")
            return
        }
        
        savePhotoFromImagePicker(named: image)
    }
    
    
    
    func savePhotoFromImagePicker (named image: UIImage) {
        if let selectedRow = selectedRowToAddTheImage{
            
            if let items = helperRealmManager.items {
                
                if items[selectedRow].hasImage {
                    print("--->item has image and it will change")
                    helperFileManager.deleteImageFromDirectory(named: items[selectedRow].imageName)
                    helperFileManager.saveImageToDocumentDirectory(named: image, for: items[selectedRow].imageName)
                }else{
                    print("--->item doesn't have image yet")
                    let itemID = getItemID()
                    //chose random name for the image
                    if let itemIDString = itemID {
                        let nameForImage = "\(itemIDString).png"
                        helperFileManager.saveImageToDocumentDirectory(named: image, for: nameForImage)
                        helperRealmManager.saveImageNameAsStringToRealm(named: nameForImage, at: selectedRow)
                    }
                }
                tableView.reloadData()
            }
        }
    }
    
    func checkPhotoLibraryAuthorization () {
        let status = PHPhotoLibrary.authorizationStatus()
        
        switch status {
        case .notDetermined: requestPhotoLibraryPermission()
        case .authorized: DispatchQueue.main.async {[weak self] in self?.openPhotoLibrary() }
        case .restricted, .denied: goToSettingsAllert()
        @unknown default:
            print("unknown case of authorisationStatus")
        }
    }
    
    func requestPhotoLibraryPermission() {
        PHPhotoLibrary.requestAuthorization { (status) in
            if status == PHAuthorizationStatus.authorized {
                DispatchQueue.main.async {[weak self] in
                    self?.openPhotoLibrary()
                }
            }
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








