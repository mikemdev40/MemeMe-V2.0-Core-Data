//
//  MemeObject.swift
//  MemeMeV1
//
//  Created by Michael Miller on 1/16/16.
//  Copyright © 2016 MikeMiller. All rights reserved.
//

import Foundation
import UIKit
import CoreData

//this model was updated from MemeMe V2.0 to be a subclass of NSManagedObject so it could be used with Core Data

class MemeObject: NSManagedObject {
    
    //this enum type was established to simplify the call to the "getImage" method below, which returns either the memed image or the original image from the file disk, based on which version of the image is needed; both the table view and collection view use this type when calling the getImage method on each meme object when setting up their respective cells, and the meme editor uses the type when it is segued to from the meme viewer
    enum ImageType {
        case Original
        case Memed
    }
    
    @NSManaged var topText: String
    @NSManaged var bottomText: String
    @NSManaged var date: NSDate
    
    //updated two variables below from originalImagePath and memedImagePath strings that held locations to saved files in the documents directory to the NSData type to persist the image data in core data
    @NSManaged var originalImage: NSData
    @NSManaged var memedImage: NSData
    
    
    
    ///this class method is used to locate and return the original and memed images from the file disk using the documents directory and the randomly generated path strings for the image file paths when the meme is created in the meme editor; the ImageType is used to simplify the call to this method so that it is clear which version of the image is being requested; the table view and collection view controllers call this method with the "Memed" type when setting up their cells, since they want to display the saved memes, whereas the "Original" type is used solely when the "Create New From" button is tapped in the meme viewer, which segues to the meme editor and loads the original version of the image into the imageview.
//    func getImage(type: ImageType) -> UIImage? {
//        if type == .Original {
//            return retrieveImage(originalImagePath)
//        } else if type == .Memed {
//            return retrieveImage(memedImagePath)
//        }
//        return nil
//    }
    
    ///this private method is called by the getImage above and returns the actual image from the file disk to the getImage function (it exists as a separate method from getImage to reduce redundant code)
//    private func retrieveImage(path: String) -> UIImage? {
//        let manager = NSFileManager.defaultManager()
//        if let documentsPath = manager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first {
//            let memeFilePath = documentsPath.URLByAppendingPathComponent(path)
//            if let imageData = NSData(contentsOfURL: memeFilePath) {
//                if let image = UIImage(data: imageData) {
//                    return image
//                }
//            }
//        }
//        return nil
//    }

    
    //updated initializer to take an NSManagedContext and call the superclass initializer
    init(topText: String, bottomText: String, originalImage: NSData, memedImage: NSData, date: NSDate, context: NSManagedObjectContext) {
        
        let entity = NSEntityDescription.entityForName("MemeObject", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        self.topText = topText
        self.bottomText = bottomText
        self.originalImage = originalImage
        self.memedImage = memedImage
        self.date = date
    }
}