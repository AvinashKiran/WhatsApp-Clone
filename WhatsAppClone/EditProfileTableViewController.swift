//
//  EditProfileTableViewController.swift
//  WhatsAppClone
//
//  Created by Frezy Stone Mboumba on 8/28/16.
//  Copyright © 2016 Frezy Stone Mboumba. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class EditProfileTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {

    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var countryTextField: UITextField!
    @IBOutlet weak var biographyTextField: UITextField!
    
    
    var databaseRef: FIRDatabaseReference! {
        
        return FIRDatabase.database().reference()
    }
    
    var storageRef: FIRStorageReference! {
        
        return FIRStorage.storage().reference()
    }

    
    var pickerView: UIPickerView!
    var countryArrays = [String]()
    var user: User!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        userImageView.layer.cornerRadius = userImageView.layer.frame.height/2
        
        for code in NSLocale.ISOCountryCodes() as [String]{
            let id = NSLocale.localeIdentifierFromComponents([NSLocaleCountryCode: code])
            let name = NSLocale(localeIdentifier: "en_EN").displayNameForKey(NSLocaleIdentifier, value: id) ?? "Country not found for code: \(code)"
            
            countryArrays.append(name)
            countryArrays.sortInPlace({ (name1, name2) -> Bool in
                name1 < name2
            })
        }
        usernameTextField.delegate = self
        emailTextField.delegate = self
        countryTextField.delegate = self
        biographyTextField.delegate = self
        
        pickerView = UIPickerView()
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.backgroundColor = UIColor.blackColor()
        countryTextField.inputView = pickerView
        
        
        
        let imageTapGesture = UITapGestureRecognizer(target: self, action: #selector(EditProfileTableViewController.choosePictureAction))
        imageTapGesture.numberOfTapsRequired = 1
        view.addGestureRecognizer(imageTapGesture)
        
        userImageView.userInteractionEnabled = true
        userImageView.addGestureRecognizer(imageTapGesture)
        
        
        // Creating Tap Gesture to dismiss Keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(EditProfileTableViewController.dismissKeyboard(_:)))
        tapGesture.numberOfTapsRequired = 1
        view.addGestureRecognizer(tapGesture)
       
        
        // Creating Swipe Gesture to dismiss Keyboard
        let swipDown = UISwipeGestureRecognizer(target: self, action: #selector(EditProfileTableViewController.dismissKeyboard(_:)))
        swipDown.direction = .Down
        view.addGestureRecognizer(swipDown)
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        fetchCurrentUserInfo()
    }
    
    // Dismissing all editing actions when User Tap or Swipe down on the Main View
    func dismissKeyboard(gesture: UIGestureRecognizer){
        self.view.endEditing(true)
    }

    
    
    func fetchCurrentUserInfo(){
        
        let userRef = FIRDatabase.database().reference().child("users").queryOrderedByChild("uid").queryEqualToValue(FIRAuth.auth()!.currentUser!.uid)
        
        userRef.observeEventType(.Value, withBlock: { (snapshot) in
            
            for userInfo in snapshot.children {
                
                self.user = User(snapshot: userInfo as! FIRDataSnapshot)
                
            }
            
            if let user = self.user {
                
                self.emailTextField.text = user.email
                self.usernameTextField.text = user.username
                self.biographyTextField.text = user.biography
                self.countryTextField.text = user.country
                
            }
            
            
            
        }) { (error) in
            let alertView = SCLAlertView()
            alertView.showError("OOPS", subTitle: error.localizedDescription)
            
        }

        
        
    }
    
    @IBAction func updateAction(sender: AnyObject) {
    
        let email = emailTextField.text!.lowercaseString
        let finalEmail = email.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        let country = countryTextField.text!
        let biography = biographyTextField.text!
        let username = usernameTextField.text!
        let userPicture = userImageView.image
        
        let imgData = UIImageJPEGRepresentation(userPicture!, 0.8)!
        
        if finalEmail.isEmpty || finalEmail.characters.count < 8 || country.isEmpty || biography.isEmpty || username.isEmpty {
            let alertView = SCLAlertView()
            alertView.showError("OOPS", subTitle: "Hey, it seems like you did not fill correctly the information")
            
            
        }else {
            
            let imagePath = "profileImage\(user.uid)/userPic.jpg"
            
            let imageRef = storageRef.child(imagePath)
            
            let metadata = FIRStorageMetadata()
            metadata.contentType = "image/jpeg"
            
            imageRef.putData(imgData, metadata: metadata) { (metadata, error) in
                if error == nil {
                    
                    FIRAuth.auth()!.currentUser!.updateEmail(finalEmail, completion: { (error) in
                        if error == nil {
                            print("email updated successfully")
                        }else {
                            let alertView =  SCLAlertView()
                            alertView.showError("😁OOPS😁", subTitle: error!.localizedDescription)
                            
                        }
                    })
                    
                    let changeRequest = FIRAuth.auth()!.currentUser!.profileChangeRequest()
                    changeRequest.displayName = username
                    
                    if let photoURL = metadata!.downloadURL(){
                        changeRequest.photoURL = photoURL
                    }
                    
                    changeRequest.commitChangesWithCompletion({ (error) in
                        if error == nil {
                            let user = FIRAuth.auth()!.currentUser!
                            
                            let userInfo = ["email": user.email!, "username": username, "country": country, "biography": biography, "uid": user.uid, "photoURL": String(user.photoURL!)]
                            
                            let userRef = self.databaseRef.child("users").child(user.uid)
                            
                            userRef.setValue(userInfo, withCompletionBlock: { (error, ref) in
                                if error == nil {
                                    self.navigationController?.popToRootViewControllerAnimated(true)
                                }else {
                                    let alertView =  SCLAlertView()
                                    alertView.showError("😁OOPS😁", subTitle: error!.localizedDescription)
                                    

                                }
                            })
                        }
                        else {
                            
                            let alertView =  SCLAlertView()
                            alertView.showError("😁OOPS😁", subTitle: error!.localizedDescription)
                            
                        }
                        
                    })
                }else {
                    
                    let alertView =  SCLAlertView()
                    alertView.showError("😁OOPS😁", subTitle: error!.localizedDescription)
                    
                    
                }
            }
            
          
            
        }

        
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        usernameTextField.resignFirstResponder()
        emailTextField.resignFirstResponder()
        countryTextField.resignFirstResponder()
        biographyTextField.resignFirstResponder()
        return true
    }
    
    func choosePictureAction() {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.allowsEditing = true
        
        let alertController = UIAlertController(title: "Add a Picture", message: "Choose From", preferredStyle: .ActionSheet)
        
        let cameraAction = UIAlertAction(title: "Camera", style: .Default) { (action) in
            pickerController.sourceType = .Camera
            self.presentViewController(pickerController, animated: true, completion: nil)
            
        }
        let photosLibraryAction = UIAlertAction(title: "Photos Library", style: .Default) { (action) in
            pickerController.sourceType = .PhotoLibrary
            self.presentViewController(pickerController, animated: true, completion: nil)
            
        }
        
        let savedPhotosAction = UIAlertAction(title: "Saved Photos Album", style: .Default) { (action) in
            pickerController.sourceType = .SavedPhotosAlbum
            self.presentViewController(pickerController, animated: true, completion: nil)
            
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Destructive, handler: nil)
        
        alertController.addAction(cameraAction)
        alertController.addAction(photosLibraryAction)
        alertController.addAction(savedPhotosAction)
        alertController.addAction(cancelAction)
        
        
        presentViewController(alertController, animated: true, completion: nil)
        
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 && indexPath.row == 0 {
            self.choosePictureAction()
        }
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        self.dismissViewControllerAnimated(true, completion: nil)
        self.userImageView.image = image
    }
    
   

    // MARK: - Picker view data source
    
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return countryArrays[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        countryTextField.text = countryArrays[row]
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return countryArrays.count
    }
    
    func pickerView(pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        
        let title = NSAttributedString(string: countryArrays[row], attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()])
        return title
    }
    
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    
}
