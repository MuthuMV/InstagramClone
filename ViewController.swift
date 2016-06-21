/**
* Copyright (c) 2015-present, Parse, LLC.
* All rights reserved.
*
* This source code is licensed under the BSD-style license found in the
* LICENSE file in the root directory of this source tree. An additional grant
* of patent rights can be found in the PATENTS file in the same directory.
*/

import UIKit
import Parse

class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var message: UITextField!
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    @IBAction func redo(sender: AnyObject) {
//        imageView.image = nil
//        message.text = ""
        let login = self.storyboard!.instantiateViewControllerWithIdentifier("login") as! LoginViewController
//        let login = LoginViewController()
        PFUser.logOutInBackgroundWithBlock { (error) in
            if error != nil {
                print(error)
            }else{
                if #available(iOS 8.0, *) {
                    self.showViewController(login, sender: nil)
                } else {
                    // Fallback on earlier versions
                }
//                self.showViewController(login, animated: true, completion: nil)
            }
        }
    }
    @IBAction func chooseImage(sender: AnyObject) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        imagePicker.allowsEditing = true
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }
    @IBAction func post(sender: AnyObject) {
        loading()
        let post = PFObject(className: "Posts")
        if let imageData = UIImagePNGRepresentation(imageView.image!) {
            if let message = message.text {
                post["userId"] = PFUser.currentUser()?.objectId
                post["date"] = NSDateFormatter.localizedStringFromDate(NSDate(), dateStyle: NSDateFormatterStyle.ShortStyle, timeStyle: NSDateFormatterStyle.ShortStyle)
                post["imageFile"] = PFFile(name: "image.png", data: imageData)
                post["message"] = message
                post.saveInBackgroundWithBlock({ (succeeded, error) in
                    self.activityIndicator.stopAnimating()
                    UIApplication.sharedApplication().endIgnoringInteractionEvents()
                    if error != nil {
                        print (error)
                        self.alert("Failed!", message: "Image not uploaded")
                    }else if succeeded {
                        self.alert("Success!", message: "Image uploaded successfully")
                    }
                })
            }
        }
        
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        print("Image selected...")
        self.dismissViewControllerAnimated(true, completion: nil)
        imageView.image = image
    }
    
    func loading(){
        activityIndicator = UIActivityIndicatorView(frame: self.view.frame)
        activityIndicator.backgroundColor = UIColor(white: 1.0, alpha: 0.5)
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
    }
    
    func alert(title: String, message: String){
        if #available(iOS 8.0, *) {
            let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { (action) in
                self.imageView.image = nil
                self.navigationController?.popViewControllerAnimated(true)
            }))
            self.presentViewController(alert, animated: true, completion: nil)
        } else {
            // Fallback on earlier versions
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.init(patternImage: UIImage(named: "background.jpg")!)
        // Do any additional setup after loading the view, typically from a nib.
     
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
