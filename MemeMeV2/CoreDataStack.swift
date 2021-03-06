//
//  CoreDataStack.swift
//  MemeMeV2
//
//  Created by Michael Miller on 3/23/16.
//  Copyright © 2016 MikeMiller. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack {
    
    static let sharedInstance = CoreDataStack()
    
    lazy var managedObjectContect: NSManagedObjectContext = {
        
        //part of this coding block inspired by the Core Data Programming Guide: https://developer.apple.com/library/tvos/documentation/Cocoa/Conceptual/CoreData/InitializingtheCoreDataStack.html#//apple_ref/doc/uid/TP40001075-CH4-SW1
        
        guard let modelURL = NSBundle.mainBundle().URLForResource("Model", withExtension: "momd") else {
            fatalError("Error loading the model from the bundle")
        }
        
        guard let managedObjectModel = NSManagedObjectModel(contentsOfURL: modelURL) else {
            fatalError("Error initializing the managed object model")
        }
        
        let persistentCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        
        let context = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        context.persistentStoreCoordinator = persistentCoordinator
        
        let urlForDocDirectory = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first
        let urlForSQLDB = urlForDocDirectory?.URLByAppendingPathComponent("DataModel.sqlite")
        
        do {
            try persistentCoordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: urlForSQLDB, options: nil)
        } catch {
            fatalError("Error adding persistent store")
        }
        
        return context
    }()
    
    private init() {}
}