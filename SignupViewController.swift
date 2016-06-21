//
//  SignupViewController.swift
//  ParseStarterProject-Swift
//
//  Created by Muthu Venkatesh on 6/1/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import Parse

class SignupViewController: UIViewController {
    
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var phone: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var rePassword: UITextField!
    
    @IBAction func redo(sender: AnyObject) {
        email.text = ""
        username.text = ""
        phone.text = ""
        password.text = ""
        rePassword.text = ""
    }
    @IBAction func signup(sender: AnyObject) {
        if let email = email.text where emailValidation(email) {
            if let username = username.text where usernameValidation(username) {
                if let password = password.text where passwordValidation(password){
                    if let phone = phone.text where phoneValidation(phone){
                        loading()
                        newUser(username, email: email, password: password, phone: phone)
                    }else{
                        alert("Phone number")
                    }
                }else{
                    alert("Password")
                }
            }else{
                alert("Username")
            }
        }else{
            alert("Email")
        }
    }
    
//    var signup: Bool = false
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "background.jpg")!)
        // Do any additional setup after loading the view.
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func emailValidation(email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluateWithObject(email)
    }
    
    func usernameValidation(username: String) -> Bool {
        let usernameRegex =  "^[a-zA-Z0-9_]{1,}$"
            /*
                ^ is the beginning of the string anchor
                $ is the end of the string anchor
                [...] is a character class definition
                * is "zero-or-more" repetition
             */
        return NSPredicate(format: "SELF MATCHES %@", usernameRegex).evaluateWithObject(username)
    }
    
    func passwordValidation(password: String) -> Bool {
        if password == rePassword.text! {
            let passwordRegex = "^.{6,10}$"
            return NSPredicate(format: "SELF MATCHES %@", passwordRegex).evaluateWithObject(password)
        }
        return false
    }
    
    func phoneValidation(phone: String) -> Bool {
        let phoneRegex = "^(?=[0-9]*$)(?:.{0}|.{10})$"
            /*
                ^       Start of string
                (?=     Assert that the following regex can be matched here:
                [0-9]*  any number of digits (and nothing but digits)
                $       until end of string
                )       (End of lookahead)
                (?:     Match either
                .{0}    0 characters
                |       or
                .{10}   10 characters
                )       (End of alternation)
                $       End of string
            */
        return NSPredicate(format: "SELF MATCHES %@", phoneRegex).evaluateWithObject(phone)
    }
    
    func alert(field: String){
        if #available(iOS 8.0, *) {
            let alert = UIAlertController(title: "Signup Failed", message: "\(field) is invalid", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { (action) in
                self.navigationController?.popViewControllerAnimated(true)
                //Depending on the segue used, there are different steps
//                self.dismissViewControllerAnimated(true, completion: nil)
            }))
            print("Before present..\(self)")
            self.presentViewController(alert, animated: true, completion: nil)
        } else {
            // Fallback on earlier versions
        }
    }
    
    func loading(){
        activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 50, 50))
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
    }
    
    func newUser(username: String!, email: String!, password: String!, phone: String){
        print("Inside new user..")
        let user = PFUser()
        user.username = username
        user.email = email
        user.password = password
        user["phone"] = phone
        user.signUpInBackgroundWithBlock { (succeeded: Bool, error: NSError?) in
            if error != nil{
                print("Error in creating new user.. \(error)")
            }else if succeeded{
                self.activityIndicator.stopAnimating()
                UIApplication.sharedApplication().endIgnoringInteractionEvents()
//                self.signup = true
                print("Signup successful")
                if #available(iOS 8.0, *) {
                    let alert = UIAlertController(title: "Signup Successful", message: "Please Login to continue", preferredStyle: UIAlertControllerStyle.Alert)
                    //            let login: LoginViewController = LoginViewController()
                    alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) in
                        self.dismissViewControllerAnimated(true, completion: nil)
                        //                self.presentViewController(login, animated: true, completion: nil)
                        
                        //Withour presenting the login view controller itself the controller passes to login page after dismissing
                    }))
                    self.presentViewController(alert, animated: true, completion: nil)
                } else {
                    // Fallback on earlier versions
                }
            }
        }
        
        //performSegueWithIdentifier("signupSuccess", sender: self)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
