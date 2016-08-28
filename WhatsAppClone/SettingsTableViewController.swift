//
//  SettingsTableViewController.swift
//  WhatsAppClone
//
//  Created by Frezy Stone Mboumba on 7/13/16.
//  Copyright © 2016 Frezy Stone Mboumba. All rights reserved.
//

import UIKit
import FirebaseStorage
import FirebaseDatabase
import FirebaseAuth

class SettingsTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userBioLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!

    var user: User!
    override func viewDidLoad() {
        super.viewDidLoad()
        userImageView.layer.cornerRadius = userImageView.layer.frame.width/2
        
        
        
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        let userRef = FIRDatabase.database().reference().child("users").queryOrderedByChild("uid").queryEqualToValue(FIRAuth.auth()!.currentUser!.uid)
        
        userRef.observeEventType(.Value, withBlock: { (snapshot) in
            
            for userInfo in snapshot.children {
                
                self.user = User(snapshot: userInfo as! FIRDataSnapshot)
                
            }
            
            if let user = self.user {
                
                self.usernameLabel.text = user.username
                self.userBioLabel.text = user.biography

                FIRStorage.storage().referenceForURL(user.photoURL).dataWithMaxSize(1 * 1024 * 1024, completion: { (imgData, error) in
                    if let error = error {
                        let alertView = SCLAlertView()
                        alertView.showError("OOPS", subTitle: error.localizedDescription)
                        
                    }else{
                        
                        dispatch_async(dispatch_get_main_queue(), {
                            if let data = imgData {
                                self.userImageView.image = UIImage(data: data)
                            }
                        })
                    }
                    
                })
                
                
            }
            
            
            
        }) { (error) in
            let alertView = SCLAlertView()
            alertView.showError("OOPS", subTitle: error.localizedDescription)
            
        }
        
    }
    

    
    func deleteAccount(){
        
        
        let alertView1 = SCLAlertView()
        alertView1.addButton("Delete") { 
            Void in
            let currentUserRef = FIRDatabase.database().reference().child("users").queryOrderedByChild("uid").queryEqualToValue(FIRAuth.auth()!.currentUser!.uid)
            
            currentUserRef.observeEventType(.Value, withBlock: { (snapshot) in
                
                for user in snapshot.children {

                let currentUser = User(snapshot: user as! FIRDataSnapshot)
                    
                currentUser.ref?.removeValueWithCompletionBlock({ (error, ref) in
                    if error == nil {
                        
                        FIRAuth.auth()?.currentUser?.deleteWithCompletion({ (error) in
                            if error == nil {
                                
                                print("account successfully deleted!")
                                dispatch_async(dispatch_get_main_queue(), {
                                    let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("Login") as! LoginViewController
                                    self.presentViewController(vc, animated: true, completion: nil)
                                    
                                })
                                
                            }else {
                                let alertView = SCLAlertView()
                                alertView.showError("OOPS", subTitle: error!.localizedDescription)
                                
                            }
                        })
                        
                    }else {
                        let alertView = SCLAlertView()
                        alertView.showError("OOPS", subTitle: error!.localizedDescription)
                        
                    }
                })
                
                
            }}) { (error) in
                let alertView = SCLAlertView()
                alertView.showError("OOPS", subTitle: error.localizedDescription)
                
            }
            

        }
        alertView1.showWarning("Warning", subTitle: "Are you sure that you want to delete your Account?")
        
        
        
        
    }
    
    func resetPassword(){
        let email = FIRAuth.auth()!.currentUser!.email!
         AuthenticationService().resetPassword(email)
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 1 && indexPath.row == 0  {
            deleteAccount()
        }else if indexPath.section == 1 && indexPath.row == 1 {
            resetPassword()
        }
    }
    
    

}
