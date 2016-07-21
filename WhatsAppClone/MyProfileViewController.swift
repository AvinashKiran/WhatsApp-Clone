//
//  MyProfileViewController.swift
//  WhatsAppClone
//
//  Created by Frezy Stone Mboumba on 7/13/16.
//  Copyright © 2016 Frezy Stone Mboumba. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase

class MyProfileViewController: UIViewController {

    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var userCountryLabel: UILabel!
    @IBOutlet weak var userEmailLabel: UILabel!
    @IBOutlet weak var userBioLabel: UILabel!
    @IBOutlet weak var userImageView: CustomizableImageView!
    
    var dataBaseRef: FIRDatabaseReference! {
        
        return FIRDatabase.database().reference()
    }
    
    var storageRef: FIRStorage! {
        
        return FIRStorage.storage()
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        loadUserInfo()
    }
    
    func loadUserInfo(){
        
        let userRef = dataBaseRef.child("users/\(FIRAuth.auth()!.currentUser!.uid)")
        userRef.observeEventType(.Value, withBlock: { (snapshot) in
            
                let user = User(snapshot: snapshot)
                
                self.usernameLabel.text = user.username
                self.userCountryLabel.text = "Country: \(user.country)"
                self.userEmailLabel.text = "Email: \(user.email)"
                self.userBioLabel.text = user.biography
                
                let imageURL = user.photoURL
                
                self.storageRef.referenceForURL(imageURL).dataWithMaxSize(1 * 1024 * 1024, completion: { (data, error) in
                    if error == nil {
                        if let data = data {
                            dispatch_async(dispatch_get_main_queue(), {

                            self.userImageView.image = UIImage(data: data)
                      })  }
                        
                        
                        
                    }else {
                        
                        let alertView = SCLAlertView()
                        alertView.showError("😁OOPS😁", subTitle: error!.localizedDescription)
                    }
                })
                
                
                
                
                
                
            
            }) { (error) in
                
                let alertView = SCLAlertView()
                alertView.showError("😁OOPS😁", subTitle: error.localizedDescription)
        }
        
        
        
        
        
        
    }
    


    @IBAction func logOutAction(sender: AnyObject) {
   
        if FIRAuth.auth()!.currentUser != nil {
            do {
                try FIRAuth.auth()?.signOut()
                
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("Login")
                presentViewController(vc, animated: true, completion: nil)
                
            } catch let error as NSError {
                
                let alertView = SCLAlertView()
                alertView.showError("😁OOPS😁", subTitle: error.localizedDescription)
            }
        }
    
    
    }
}
