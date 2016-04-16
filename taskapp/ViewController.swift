//
//  ViewController.swift
//  taskapp
//
//  Created by tlsmooth89 on 4/16/16.
//  Copyright © 2016 yusuke.iwasaki. All rights reserved.
//

import UIKit
import RealmSwift

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var categorySearchTextField: UITextField!
    
    // Realm migration
    let realm: Realm = {
        var config = Realm.Configuration(schemaVersion: 1)
        Realm.Configuration.defaultConfiguration = config
        return try! Realm()
    }()
    
    // A list to store tasks from the DB
    var taskArray = try! Realm().objects(Task).sorted("date", ascending: false)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: UITableViewDataSource protocol methods
    // Method to return the number of data/cells
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskArray.count
    }
    
    // Method to return each cell's content
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // Getting reusable cells
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        
        // Setting a value to the cell
        let task = taskArray[indexPath.row]
        cell.textLabel?.text = task.title
        
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        let dateString:String = formatter.stringFromDate(task.date)
        cell.detailTextLabel?.text = dateString
        
        return cell
    }
    
    // MARK: UITableViewDelegate protocol methods
    // Method to be called when a cell is selected
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("cellSegue", sender: nil)
    }
    
    // Method to tell that the cell is deletable
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.Delete
    }
    
    // Method to be called when the Delete button is pressed
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            
            // Cancel the notification when the task is deleted
            let task = taskArray[indexPath.row]
            
            for notification in UIApplication.sharedApplication().scheduledLocalNotifications! {
                if notification.userInfo!["id"] as! Int == task.id {
                    UIApplication.sharedApplication().cancelLocalNotification(notification)
                    break
                }
            }
            
            // Deleting from the DB
            try! realm.write {
                self.realm.delete(self.taskArray[indexPath.row])
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
            }
        }
    }
    
    // Segue method
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let inputViewController:InputViewController = segue.destinationViewController as! InputViewController
        
        if segue.identifier == "cellSegue" {
            let indexPath = self.tableView.indexPathForSelectedRow
            inputViewController.task = taskArray[indexPath!.row]
        } else {
            let task = Task()
            task.date = NSDate()
            
            if taskArray.count != 0 {
                task.id = taskArray.max("id")! + 1
            }
            
            inputViewController.task = task
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    // Category Search Button method
    @IBAction func onCategorySearchButtonClick(sender: AnyObject) {
        taskArray = try! Realm().objects(Task).filter("category = '\(categorySearchTextField.text!)' ")
        
        viewWillAppear(true)
    }
}

