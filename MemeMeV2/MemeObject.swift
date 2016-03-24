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
    
    ///this class method is used to return a UIImage associated with the NSData saved to disk (this method was updated to work with core data)
    func getImage(type: ImageType) -> UIImage? {
        if type == .Original {
            return UIImage(data: originalImage)
        } else if type == .Memed {
            return UIImage(data: memedImage)
        }
        return nil
    }
    
    //required standard init required for loading data from core data on startup
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
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