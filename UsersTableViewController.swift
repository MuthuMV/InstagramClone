//
//  UsersTableViewController.swift
//  ParseStarterProject-Swift
//
//  Created by Muthu Venkatesh on 6/2/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import Parse

class UsersTableViewController: UITableViewController {
    
    var users: [String] = []
    var usersId: [String] = []
    var connection: [String: Bool] = [:]
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    var refresher: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "background.jpg")!)

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        usersLoad()
    }
    
    func usersLoad() {
        loading()
        let query = PFUser.query()
        query?.findObjectsInBackgroundWithBlock({ (objects, error) in
            if error != nil {
                print(error)
            }else{
                self.usersId.removeAll()
                self.users.removeAll()
                self.connection.removeAll()
                if let objects = objects {
                    for user in objects {
                        if let user = user as? PFUser{
                            if user.objectId! != PFUser.currentUser()?.objectId{
                                self.users.append(user.username!)
                                self.usersId.append(user.objectId!)
                                
                                //Creating the connection of followers
                                let query = PFQuery(className: "UsersConnections")
                                query.whereKey("Follower", equalTo: (PFUser.currentUser()!.objectId)!)
                                query.whereKey("Following", equalTo: user.objectId!)
                                query.findObjectsInBackgroundWithBlock({ (objects, error) in
                                    if error != nil {
                                        print(error)
                                    }else{
                                        if let objects = objects where objects.count > 0 {
                                            self.connection[user.objectId!] = true
                                        }else{
                                            self.connection[user.objectId!] = false
                                        }
                                    }
                                    if self.users.count == self.connection.count {
                                        self.tableView.reloadData()
                                        self.activityIndicator.stopAnimating()
                                        UIApplication.sharedApplication().endIgnoringInteractionEvents()
                                    }
                                })
                            }
                        }
                    }
                }
            }
        })
    }
    
    func refresh() {
        refresher = UIRefreshControl()
        refresher.attributedTitle = NSAttributedString(string: "Pull to Refresh")
        refresher.addTarget(self, action: #selector(usersLoad), forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(refresher)
        usersLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("userCell", forIndexPath: indexPath)
        cell.textLabel?.text = users[indexPath.row]
        //Retaining the following status of the current user
        if connection[usersId[indexPath.row]] == true {
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
        }
        return cell
    }
 
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        
        if cell?.accessoryType == UITableViewCellAccessoryType.None {
            //Following an user
            cell?.accessoryType = UITableViewCellAccessoryType.Checkmark
            connection[usersId[indexPath.row]] = true
            let query = PFObject(className: "UsersConnections")
            query["Follower"] = PFUser.currentUser()?.objectId
            query["Following"] = usersId[indexPath.row]
            query.saveInBackground()
        }else if cell?.accessoryType == UITableViewCellAccessoryType.Checkmark {
            //Unfollowing an user
            cell?.accessoryType = UITableViewCellAccessoryType.None
            connection[usersId[indexPath.row]] = false
            let query = PFQuery(className: "UsersConnections")
            query.whereKey("Follower", equalTo: (PFUser.currentUser()?.objectId)!)
            query.whereKey("Following", equalTo: usersId[indexPath.row])
            query.findObjectsInBackgroundWithBlock({ (objects, error) in
                if error != nil{
                    print(error)
                }else{
                    if let objects = objects {
                        for object in objects {
                            print("unfollowing the user/..")
                            object.deleteInBackground()
                        }
                    }
                }
            })
            
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
