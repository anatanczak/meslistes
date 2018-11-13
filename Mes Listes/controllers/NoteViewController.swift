//
//  NoteViewController.swift
//  Mes Listes
//
//  Created by Anastasiia Tanczak on 04/07/2018.
//  Copyright © 2018 Ana Viktoriv. All rights reserved.
//

import UIKit
import RealmSwift

class NoteViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //MARK: - GLOBAL VARIABLES
    var currentItem: Item?
    let realm = try! Realm()
    let imagePicker = UIImagePickerController()
    var addedImage: UIImage?
    var imageName = ""
    var arrayOfImagesFromRealm = [UIImage]()
    var arrayOfImageNamesFromRealm = [String]()
    
    let backgroundView = UIView()
    let textView = UITextView()
    let deleteButton = UIButton()
    let fontButton = UIButton()
    let photoLibraryButton = UIButton()
    let cameraButton = UIButton()
    
    var rightNavigationButton: UIBarButtonItem?
    
    lazy var buttonStackView: UIStackView  = {
        let stackView = UIStackView(arrangedSubviews: [deleteButton, fontButton, photoLibraryButton, cameraButton])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 0
        return stackView
    }()
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupViews()
        setupLayouts()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    private func setupNavigationBar () {
        self.title = currentItem?.title ?? "meslistes"
        
        let attributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 19, weight: .light), NSAttributedString.Key.foregroundColor: UIColor.black]
        navigationController?.navigationBar.titleTextAttributes = attributes
        
        rightNavigationButton = UIBarButtonItem(title: "OK", style: .plain, target: self, action: #selector(rightBarButtonAction))
       
        self.navigationItem.setRightBarButton(rightNavigationButton, animated: false)
        rightNavigationButton?.isEnabled = false
        rightNavigationButton?.tintColor = .clear
        
        
        let leftNavigationButton = UIBarButtonItem(image: #imageLiteral(resourceName: "back-button-icon") , style: .plain, target: self, action: #selector(leftBarButtonAction))
        leftNavigationButton.tintColor = .black
        
        leftNavigationButton.imageInsets  = .init(top: 0, left: -4, bottom: 0, right: 0)
        self.navigationItem.setLeftBarButton(leftNavigationButton, animated: false)
    }
    
    private func setupViews () {
        backgroundView.backgroundColor = .white

        textView.font = UIFont.systemFont(ofSize: 19, weight: .light)
        textView.delegate = self
        if let noteExists = currentItem?.noteInput {
            textView.text = noteExists
        }
        
//        textView.text = "write your notes here..."
//        textView.textColor = .lightGray
        
        deleteButton.setImage(#imageLiteral(resourceName: "trash-for-note-icon"), for: .normal)
        deleteButton.addTarget(self, action: #selector(deleteButtonAction), for: .touchUpInside)
        
        fontButton.setImage(#imageLiteral(resourceName: "change-font-icon"), for: .normal)
        fontButton.addTarget(self, action: #selector(fontButtonAction), for: .touchUpInside)
        
        photoLibraryButton.setImage(#imageLiteral(resourceName: "photolibrary-for-note-icon"), for: .normal)
        photoLibraryButton.addTarget(self, action: #selector(photoLibraryButtonAction), for: .touchUpInside)
        
        cameraButton.setImage(#imageLiteral(resourceName: "camera-for-note-icon"), for: .normal)
        cameraButton.addTarget(self, action: #selector(cameraButonAction), for: .touchUpInside)
        
        [backgroundView, textView, buttonStackView].forEach {view.addSubview($0)}
    }

    private func setupLayouts () {
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        textView.translatesAutoresizingMaskIntoConstraints = false
        
        let statusBarHeight: CGFloat = 20.0
        let navigationBarHeight = (self.navigationController?.navigationBar.frame.height)!
        let textViewHeight = self.view.bounds.height - (statusBarHeight + navigationBarHeight + 42)
    
        
        NSLayoutConstraint.activate([
            backgroundView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            textView.heightAnchor.constraint(equalToConstant: textViewHeight),
            textView.bottomAnchor.constraint(equalTo: buttonStackView.topAnchor),
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            buttonStackView.heightAnchor.constraint(equalToConstant: 25),
            buttonStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            buttonStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            buttonStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -17)
            
            ])
    }
    
    //MARK: - ACTIONS
    @objc func rightBarButtonAction () {
        if textView.text != "" && textView.text != nil {
            
            do {
                try realm.write {
                    currentItem?.hasNote = true
                    currentItem?.noteInput = textView.text
                }
            }catch{
                print("error updating realm\(error)")
            }

        
        }
        rightNavigationButton?.isEnabled = false
        rightNavigationButton?.tintColor = .clear
        textView.resignFirstResponder()
    }
    
    @objc func leftBarButtonAction () {
       _ = navigationController?.popViewController(animated: true)
    }
    
    @objc func deleteButtonAction () {
        
    }
    
    @objc func fontButtonAction () {
        
    }
    
    @objc func photoLibraryButtonAction () {
        
    }
    
    @objc func cameraButonAction () {
        
    }
}
//MARK: - UITextViewDelegate
extension NoteViewController: UITextViewDelegate {
    
    
    func textViewDidBeginEditing(_ textView: UITextView){
        rightNavigationButton?.isEnabled = true
        rightNavigationButton?.tintColor = .black
    }
    
    func textViewDidEndEditing(_ textView: UITextView){

    }
    
}







//    //MARK: - OUTLETS
//    @IBOutlet weak var doneButtonPressed: UIButton!
//
//    @IBOutlet weak var nameLabel: UILabel!
//
//    @IBOutlet weak var textView: UITextView!
//
//
//    //MARK: - IBACTIONS
//    @IBAction func doneButtonPressed(_ sender: Any) {
//        if doneButtonPressed.titleLabel?.text == "Save"{
//       // saveUserInput()
//        dismiss(animated: true, completion: nil)
//        }else{
//            textView.resignFirstResponder()
//        }
//    }
//
//    @IBAction func cancelButtonPressed(_ sender: UIButton) {
//        dismiss(animated: true, completion: nil)
//    }
//
//    @IBAction func deleteButtonPressed(_ sender: UIButton) {
//
//    }
//
//    @IBAction func shareButtonPressed(_ sender: UIButton) {
//
//    }
//
//    @IBAction func fontButtonPressed(_ sender: UIButton) {
//
//    }
//
//
//    @IBAction func photoLibraryButtonPressed(_ sender: UIButton) {
//      //  openPhotoLibrary()
//    }
//
//
//    @IBAction func photoButtonPressed(_ sender: UIButton) {
////    1. create a string from the date to ID the image
////         let date = Date()
////         let dateFormatter = DateFormatter()
////         dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
////        imageName = "\n" + dateFormatter.string(from: date) + "\n"
////
//////         2. get the cursor position
////        var cursorPosition1: Int
////        getCursor()
////
////
//////         3. add this ID string to the text (and the new line sign)
//////         ( - > if the use button in ImagePicker was tapped the sting stays
//////          - > esle delete it from the text)
////
//////         4. insert image instead of the ID string
////
////        openCamera()
////
////        getImagesAndPutThemInArray()
////
////
//    }
//
//    //MARK: - VEIW DID LOAD
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//
//    }
//}
//
////    //MARK: - REALM FUNCTIONS
////    func saveUserInput () {
////        if let selectedItem = currentItem {
////            do {
////                try realm.write {
////                    selectedItem.noteInput = textView.text
////                }
////            }catch{
////                print("error updating realm\(error)")
////            }
////        }
////    }
////
////
////    ///saves images to realm
////
////    func saveImagesToRealm (_ nameofImage: String) {
////        if let selectedItem = currentItem {
////            do {
////                try realm.write {
////                    selectedItem.imagenames.append(nameofImage)
////                    print("saving nameOfImageToRealm-->\(selectedItem.imagenames)")
////                }
////            }catch{
////                print("error updating realm\(error)")
////            }
////        }
////    }
////
////    //MARK: - WORKING WITH CAMERA AND IMAGES
////
////    func openCamera(){
////        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)){
////            imagePicker.sourceType = UIImagePickerControllerSourceType.camera
////            imagePicker.allowsEditing = false
////            imagePicker.delegate = self
////            self.present(imagePicker, animated: true, completion: nil)
////        }
////        else{
////            let alert  = UIAlertController(title: "Warning", message: "You don't have camera", preferredStyle: .alert)
////            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
////            self.present(alert, animated: true, completion: nil)
////        }
////    }
////
////    //Choose image from camera roll
////    func openPhotoLibrary(){
////        imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
////        //If you dont want to edit the photo then you can set allowsEditing to false
////        imagePicker.allowsEditing = true
////        imagePicker.delegate = self
////        self.present(imagePicker, animated: true, completion: nil)
////    }
////
////    // retrieve image from the picker
////    func imagePickerController (_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
////
////        if let originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage{
////            /* you get image from picker -> image put ro textView */
////            addedImage = originalImage
////            textView.text!.append(contentsOf: imageName)
////            attachImagesToText(image: originalImage)
////
////            /* in background thread need save image and all logic that is not related to UI*/
////            DispatchQueue.global().async { [weak self] in
////                guard let `self` = self else { return }
////                self.saveImage(the: self.addedImage!, called: self.imageName)
////                self.saveImagesToRealm(self.imageName)
////            }
////        }
////
////        //Dismiss the UIImagePicker after selection
////        picker.dismiss(animated: true, completion: nil)
////    }
////
////    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
////        print("Picker Cancelled")
////        imagePicker.dismiss(animated: true, completion: nil)
////
////    }
////
////    /// save the image to the documents directory
////    func saveImage (the imageToSave: UIImage, called imageName: String) {
////
////        //creates an instance of the FileManager
////        let fileManager = FileManager.default
////
////        //get the image path
////        let imagePath = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(imageName)
////        //get the image we took with camera
////        let image = addedImage
////        let orientedImage = image!.upOrientationImage()
////
////        //get the PNG data for this image
////        let data = UIImagePNGRepresentation(orientedImage!)
////
////        //store it in the document directory
////        fileManager.createFile(atPath: imagePath as String, contents: data, attributes: nil)
////
////    }
////
////    func getImagesAndPutThemInArray () {
////        let fileManager = FileManager.default
////        if let selectedItem = currentItem {
////            for nameOfImage in selectedItem.imagenames {
////                let imagePath = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(nameOfImage)
////                if fileManager.fileExists(atPath: imagePath){
////                    let newImage = UIImage(contentsOfFile: imagePath)
////                    arrayOfImagesFromRealm.append(newImage!)
////                    arrayOfImageNamesFromRealm.append(nameOfImage)
////
////                    print("-->gettingImagesFromRealm\(arrayOfImageNamesFromRealm)\(arrayOfImagesFromRealm)")
////                }else{
////                    print("Panic! No Image!")
////
////                }
////                print(nameOfImage)
////            }
////        }
////    }
////
////    // attaching an image to the text
////
////    func attachImagesToText(image: UIImage) {
////
////        let fullStringFromTextView = textView.text!
////
////        let fullString = NSMutableAttributedString(string: textView.text!)
////
////        let image1Attachment = NSTextAttachment()
////        image1Attachment.image = image
////        print()
////
////        let newWidth = self.view.bounds.size.width - 10
////        let newHeight = ((image1Attachment.image?.size.height)! * newWidth)/(image1Attachment.image?.size.width)!
////
////        image1Attachment.bounds = CGRect(x: 0, y: image1Attachment.bounds.origin.y, width: newWidth, height: newHeight)
////
////        let image1String = NSAttributedString(attachment: image1Attachment)
////        fullString.append(image1String)
////        textView.attributedText = fullString
////
////
////
//
//
////        let fullString = NSMutableAttributedString(string: textView.text!)
////        let image1Attachment = NSTextAttachment()
////        image1Attachment.image = arrayOfIamgesFromRealm[0]
////       // image1Attachment.setImageHeight(height: 230)
////        let newWidth = self.view.bounds.size.width - 10
////       let newHeight = ((image1Attachment.image?.size.height)! * newWidth)/(image1Attachment.image?.size.width)!
////        print((image1Attachment.image?.size.height)!)
////        print((image1Attachment.image?.size.width)!)
////        image1Attachment.bounds = CGRect(x: 0, y: image1Attachment.bounds.origin.y, width: newWidth, height: newHeight)
////
////        let image1String = NSAttributedString(attachment: image1Attachment)
////        fullString.append(image1String)
////        textView.attributedText = fullString
//
////    }
////
////    //MARK: - DIFFERENT METHODS
////
////}
////
//////MARK: - TEXT METHODS
////extension NoteViewController: UITextViewDelegate {
////
////    func textViewDidBeginEditing(_ textView: UITextView) {
////        // what happens when the user touches the textView
////        print("save")
////        doneButtonPressed.setTitle("Done", for: .normal)
////
////    }
////
////    func textViewDidEndEditing(_ textView: UITextView) {
////        // what happens when the user finishes editing the textView
////        doneButtonPressed.setTitle("Save", for: .normal)
////        getCursor()
////    }
////
////    // makes the text in a textview not to hide behind the keyboard
////    @objc func updateTextView (notification: Notification){
////        let userInfo = notification.userInfo!
////
////        let keyboardEndFrameScreenCoordinates = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
////
////        let keyboardEndFrame = self.view.convert(keyboardEndFrameScreenCoordinates, to: view.window)
////
////        if notification.name == Notification.Name.UIKeyboardWillHide {
////            textView.contentInset = UIEdgeInsets.zero
////        }else{
////            textView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardEndFrame.height, right: 0)
////            textView.scrollIndicatorInsets = textView.contentInset
////        }
////
////        textView.scrollRangeToVisible(textView.selectedRange)
////    }
////
////    func getCursor () {
////        let startPosition: UITextPosition = textView.beginningOfDocument
////        let endPosition: UITextPosition = textView.endOfDocument
////        let selectedRange: UITextRange? = textView.selectedTextRange
////
////        if let selectedRange = textView.selectedTextRange {
////            let cursorPosition = textView.offset(from: startPosition, to: selectedRange.start)
////
////            print("-->CursorPosition is\(cursorPosition)")
////        }
////    }
////
////}
//
////extension NSTextAttachment {
////    func setImageHeight(height: CGFloat) {
////        guard let image = image else { return }
////        let ratio = image.size.width / image.size.height
////
////
//////        bounds = CGRect(x: bounds.origin.x, y: bounds.origin.y, width: ratio * height, height: height)
//////bounds = CGRect(x: 0, y: bounds.origin.y, width: wi, height: <#T##CGFloat#>)
////        //(bounds.origin.x, bounds.origin.y, ratio * height, height)
////    }
////}
//
////extension UIImage {
////    func upOrientationImage() -> UIImage? {
////        switch imageOrientation {
////        case .up:
////            return self
////        default:
////            UIGraphicsBeginImageContextWithOptions(size, false, scale)
////            draw(in: CGRect(origin: .zero, size: size))
////            let result = UIGraphicsGetImageFromCurrentImageContext()
////            UIGraphicsEndImageContext()
////            return result
////        }
////    }
////}




