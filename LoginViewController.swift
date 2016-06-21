//
//  LoginViewController.swift
//  ParseStarterProject-Swift
//
//  Created by Muthu Venkatesh on 6/1/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import Parse

class LoginViewController: UIViewController {

    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var validation: UILabel!
    
    @IBAction func login(sender: AnyObject) {
        if let username = username.text {
            if let password = password.text {
                if username == "" || password == ""{
                    if #available(iOS 8.0, *) {
                        let alert = UIAlertController(title: "Error logging in", message: "Please Enter the Username and Password", preferredStyle: UIAlertControllerStyle.Alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) in
                            self.dismissViewControllerAnimated(true, completion: nil)
                        }))
                        self.presentViewController(alert, animated: true, completion: nil)
                        
                    } else {
                        // Fallback on earlier versions
                    }
                }else{
                    loading()
                    login(username, password: password)
                }
            }
        }
        
    }
    
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
    
    override func viewDidAppear(animated: Bool) {
        if PFUser.currentUser() != nil{
            performSegueWithIdentifier("login", sender: self)
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
    
    func login(username: String, password: String){
        PFUser.logInWithUsernameInBackground(username, password: password, block: { (user: PFUser?, error: NSError?) in
                if user != nil {
                    self.activityIndicator.stopAnimating()
                    UIApplication.sharedApplication().endIgnoringInteractionEvents()
                    print("Login successful...")
                    self.performSegueWithIdentifier("login", sender: self)
                    //pass to main view controller
                }else{
                    print("Login unsuccessful...\(error)")
                    self.validation.text = "Invalid Username or Password"
                }
            })

        
    }
    
    
    @IBAction func unwindToLogin(segue: UIStoryboardSegue) {
        
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
