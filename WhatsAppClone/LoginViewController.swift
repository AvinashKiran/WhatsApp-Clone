//
//  ViewController.swift
//  Swift Academy
//
//  Created by Frezy Stone Mboumba on 7/8/16.
//  Copyright © 2016 Frezy Stone Mboumba. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Setting the delegates for the Textfields
        
        usernameTextField.delegate = self
        passwordTextField.delegate = self
        
        // Creating Tap Gesture to dismiss Keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(LoginViewController.dismissKeyboard(_:)))
        tapGesture.numberOfTapsRequired = 1
        view.addGestureRecognizer(tapGesture)
        
        // Creating Swipe Gesture to dismiss Keyboard
        let swipDown = UISwipeGestureRecognizer(target: self, action: #selector(LoginViewController.dismissKeyboard(_:)))
        swipDown.direction = .Down
        view.addGestureRecognizer(swipDown)
        
        view.bringSubviewToFront(loginView)
    }

    // Unwind Segue Action
    @IBAction func unwindToLogin(storyboard: UIStoryboardSegue){}
    
    
    // Dismissing the Keyboard with the Return Keyboard Button
    func dismissKeyboard(gesture: UIGestureRecognizer){
        self.view.endEditing(true)
    }
    
    // Dismissing the Keyboard with the Return Keyboard Button
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        usernameTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
   return true
    }
    
    // Moving the View down after the Keyboard appears
    func textFieldDidBeginEditing(textField: UITextField) {
        animateView(true, moveValue: 80)
    }

    // Moving the View down after the Keyboard disappears
    func textFieldDidEndEditing(textField: UITextField) {
        animateView(false, moveValue: 80)
    }
    
    
    // Move the View Up & Down when the Keyboard appears
    func animateView(up: Bool, moveValue: CGFloat){
        
        let movementDuration: NSTimeInterval = 0.3
        let movement: CGFloat = (up ? -moveValue : moveValue)
        UIView.beginAnimations("animateView", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(movementDuration)
        self.view.frame = CGRectOffset(self.view.frame, 0, movement)
        UIView.commitAnimations()
        
        
    }
 
    // Loging in the User
    @IBAction func loginAction(sender: AnyObject) {
    }

}

