//
//  SentMemesTableViewController.swift
//  MemeMeV2
//
//  Created by Michael Miller on 1/24/16.
//  Copyright © 2016 MikeMiller. All rights reserved.
//

import UIKit
import CoreData

class SentMemesTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    //MARK: OUTLETS
    //the delegate and datasource are set as soon as the tableview outlet is set
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
        }
    }
    //MARK: PROPERTIES
    //added convenience property for quickly accessing shared core data context
    var sharedContext: NSManagedObjectContext {
        return CoreDataStack.sharedInstance.managedObjectContect
    }
    
    //MARK: CUSTOM METHODS
    ///this method is the action attached to the "+" button in the navigation bar and causes a segue to occur (prepareForSegue is invoked here, but because the destination view controller doesn't need to be set up when adding a new meme, no setup specific to the "showMemeEditorFromTable" segue identifier occurs in the prepareForSegue call)
    func addMeme() {
        performSegueWithIdentifier("showMemeEditorFromTable", sender: nil)
    }
    
    ///this method was added as part of the core data conversion, and retrieves all memes from the persistent store for initial loading
    func loadAllMemes() -> [MemeObject] {
        
        let fetchRequest = NSFetchRequest(entityName: "MemeObject")
        
        //sort descriptor added below to the fetch request in order to ensure that the memes are returned with the newest meme on TOP of the table (without this sort descriptor, the memes appear to return with newest at the bottom, which is equivaleqnt to a sort on "date" with ascending = true); my references for sort descriptors: https://www.hackingwithswift.com/read/38/5/loading-core-data-objects-using-nsfetchrequest-and-nssortdescrip and https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/CoreData/nsfetchedresultscontroller.html#//apple_ref/doc/uid/TP40001075-CH8-SW1
        
        let sortByDate = NSSortDescriptor(key: "date", ascending: false)
        fetchRequest.sortDescriptors = [sortByDate]
        
        do {
            return try sharedContext.executeFetchRequest(fetchRequest) as! [MemeObject]
        } catch let error as NSError {
            callAlert("Error loading memes from disk", message: error.localizedDescription, handler: nil)
            return [MemeObject]()
        }
            }
    
    ///this method creates an alert with a specific title, message, and completion handler (as a note, the only time a completion handler is provided is when the user selects an activity from the share meme menu; in this casae the "OK" button then leads to a dismissal of the meme editor)
    func callAlert(title: String, message: String, handler: ((UIAlertAction) -> Void)?) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: handler))
        presentViewController(ac, animated: true, completion: nil)
    }
    
    //MARK: DELEGTE METHODS
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        //sets up the prototype cell's display settings
        let cell = tableView.dequeueReusableCellWithIdentifier("memeCell") as! MemeTableViewCell
        cell.tableCellImageView.layer.borderWidth = 1
        cell.tableCellImageView.layer.borderColor = UIColor.blackColor().CGColor
        cell.tableCellImageView.layer.cornerRadius = 5
        cell.tableCellImageView.clipsToBounds = true
        cell.tableCellImageView.contentMode = .ScaleAspectFill

        //sets the data of each cell using the shared saved memes array; note that the imageview of the cell is being updated to the memed image as retrieved using the "getImage" method on the meme object using the "Memed" ImageType (this method and type are both defined as part of the MemeObject class), as well as the global "getDateFromMeme" function which is defined in the functions.swift file (and also used by the collection view)
        let memeCollection = Memes.sharedInstance.savedMemes
        cell.tableCellTopLabel.text = memeCollection[indexPath.row].topText
        cell.tableCellBottomLabel.text = memeCollection[indexPath.row].bottomText
        cell.tableCellDateLabel.text = "Shared on " + getDateFromMeme(memeCollection[indexPath.row])
        cell.tableCellImageView.image = memeCollection[indexPath.row].getImage(MemeObject.ImageType.Memed)
        
        return cell
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Memes.sharedInstance.savedMemes.count
    }
    
    //this delegate method allows the user to delete a meme (either by swiping left on the table cell OR by clicking the "Edit" button and using the the red delete circles), thus removing the two associated image files from the file disk (using the removeFileAtPath method), removes the meme from the shared [MemeObject] array, removes the row from the table view, and updates the saved memes array on the file disk (by saving the memes file on the disk with the updated Memes.sharedInstance.savedMemes that has the meme removed); my primary reference for learning how to delete table rows was https://developer.apple.com/library/ios/documentation/UserExperience/Conceptual/TableView_iPhone/ManageInsertDeleteRow/ManageInsertDeleteRow.html#//apple_ref/doc/uid/TP40007451-CH10-SW19
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            
            //deletes the two images (original and memed) from the file disk
            let memeToDelete = Memes.sharedInstance.savedMemes[indexPath.row]
            let manager = NSFileManager.defaultManager()
            if let documentsPath = manager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first {
                let originalImagePathURL = documentsPath.URLByAppendingPathComponent(memeToDelete.originalImagePath)
                let memedImagePathURL = documentsPath.URLByAppendingPathComponent(memeToDelete.memedImagePath)
                do {
                    try manager.removeItemAtURL(originalImagePathURL)
                    try manager.removeItemAtURL(memedImagePathURL)
                } catch let error as NSError {
                    print(error.description)
                }
            }
            
            //deletes the meme from the context
            sharedContext.deleteObject(memeToDelete)
            
            //deletes the meme from the shared Memes [MemeObject] array
            Memes.sharedInstance.savedMemes.removeAtIndex(indexPath.row)
            
            do {
                //saves the deletion
                try sharedContext.save()
                
                //deletes the row from the table, which only occurs if the save to disk is successful (i.e. does not thrown an error)
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            } catch let error as NSError {
                callAlert("Error deleting meme from disk", message: error.localizedDescription, handler: nil)
            }
        }
    }
    
    //MARK: VIEW CONTROLLER METHODS
    //preparation is necessary when segueing to the meme viewer from the table view after tapping on a row (but not when seguing to the meme editor when tapping the "+" button), and this preparation involves setting the memeToDisplay property to the specific meme that was selected; since outlets are NOT yet set on the destination view controller, it was not possible to set the imageView.image property directly from prepareForSegue, and instead the memeToDisplay property is set (which, when the meme viewer is about to appear, enables the imageView.image to THEN be set using the meme information passed in memeToDisplay, since outlets are set the time "viewWillAppear" is called)
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "TableToMemeViewer" {
            if let memeViewController = segue.destinationViewController as? MemeDetailViewController {
                if let cell = sender as? MemeTableViewCell {
                    if let indexPath = tableView.indexPathForCell(cell) {
                        memeViewController.memeToDisplay = Memes.sharedInstance.savedMemes[indexPath.row]
                    }
                }
            }
        }
    }
    
    //this method was overridden as part of enabling the default behavior of the "Edit-Done" button (as created via the call to editButtonItem() in viewDidLoad), which turns on editing for an editable view, such as a table; it was necessary to override this method because the "Edit-Dont" button is associated with the view controller, NOT the table view, and so this overridden version of the method links the current state of the view controller's Edit-Done button (and value of the "editing" propoerty as either true or false) to the value of the tableView's editing value (so that when "Edit" is pressed in the view controller, the tableView goes into editing mode, and vice versa for "Done").
    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        tableView.setEditing(editing, animated: true)
    }
    
    //MARK: VIEW CONTROLLER LIFECYCLE
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    //in viewDidLoad, the navigation bar is set up with the "+" button to segue to the meme editor and with a built-in "Edit-Done" toggle button (by returning the button created via the view controller's editButtonItem() method), which is connected to the editing property, and the saved memes array is read from disk and loaded into the shared singleton [MemeObject] array; also, the title is set (to prevent the "Sent Memes" title from appering in the tab bar button underneath the tab bar button icon, it was necessary to set the view's title = "" and the navigationItem's title to "Sent Memes")
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: #selector(SentMemesTableViewController.addMeme))
        navigationItem.leftBarButtonItem = editButtonItem()
        
        //sets the shared memes array to the array of memes that are returned from the persistent core data stack when loaded
        Memes.sharedInstance.savedMemes = loadAllMemes()
        
        //sets title to "" sets both navigation bar title AND tab bar title to ""; subsequently setting navigationItem's title to "Sent Memes" allowed just this title to be shown in the navigation bar (and not under the tab bar icon)
        title = ""
        navigationItem.title = "Sent Memes"
    }

}
