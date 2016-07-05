//
//  FeedsTableViewController.swift
//  ParseStarterProject-Swift
//
//  Created by Muthu Venkatesh on 6/3/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import Parse

class Post {
    var username: String
    var postImage: UIImage
    var postMessage: String
    
    init (username: String, postImage: UIImage, postMessage: String){
        self.username = username
        self.postImage = postImage
        self.postMessage = postMessage
    }
}

class FeedsTableViewController: UITableViewController {

    var posts = [Post]()
    var activityIndicator = UIActivityIndicatorView()
    var refresher: UIRefreshControl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "background.jpg")!)
        feeds()
        activityIndicator.stopAnimating()
//        UIApplication.sharedApplication().endIgnoringInteractionEvents()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return posts.count
    }
    
    func feeds() {
        refresh()
        loading()
        let query = PFQuery(className: "UsersConnections")
        query.whereKey("Follower", equalTo: (PFUser.currentUser()?.objectId)!)
        query.findObjectsInBackgroundWithBlock({ (followings, error) in
            if error != nil {
                print(error)
            }else{
                if let followings = followings {
                    for following in followings {
                        let query = PFQuery(className: "Posts")
                        query.whereKey("userId", equalTo: following["Following"])
                        query.findObjectsInBackgroundWithBlock({ (objects, error) in
                            if error != nil {
                                print(error)
                            }else {
                                if let objects = objects {
                                    for object in objects {
                                        let postPic = object.valueForKey("imageFile")! as! PFFile
                                        postPic.getDataInBackgroundWithBlock({ (imageData: NSData?, error: NSError?) in
                                            if error != nil {
                                                print(error)
                                            }else{
                                                let image = UIImage(data: imageData!)
                                                let query = PFUser.query()
                                                query?.getObjectInBackgroundWithId((object.valueForKey("userId") as? String)!, block: { (users, error) in
                                                    if error != nil{
                                                        print(error)
                                                    }else{
                                                        if let user = users?.valueForKey("username") {
                                                            let post = Post(username: user as! String, postImage: image!, postMessage: (object.valueForKey("message") as? String)!)
                                                            self.posts.append(post)
                                                        }
                                                    }
                                                    self.tableView.reloadData()
                                                })
                                            }
                                        })
                                    }
                                }
                            }
                        })
                    }
                }
            }
        })
        self.refresher.endRefreshing()
    }
    
    func loading() {
        activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 50, 50))
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        activityIndicator.startAnimating()
//        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
    }
    
    func refresh() {
        refresher.attributedTitle = NSAttributedString(string: "Pull to Refresh")
        refresher.addTarget(self, action: #selector(feeds), forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(refresher)
//        feeds()
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("feedCell", forIndexPath: indexPath) as! FeedTableViewCell
        cell.username.text = posts[indexPath.row].username
        cell.imagePost.image = posts[indexPath.row].postImage
        cell.message.text = posts[indexPath.row].postMessage
        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

