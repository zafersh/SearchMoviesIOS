//
//  CoreDataStack.swift
//  SearchMovies
//
//  Created by Thafer Shahin on 8/21/18.
//  Copyright © 2018 Thafer Shahin. All rights reserved.
//

import Foundation

import CoreData

/// This class is to support CoreData for iOS < 10, as NSPersistentContainer requires iOS
class CoreDataStack {
    
    static var applicationDocumentsDirectory: URL = {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1]
    }()
    
    static var managedObjectModel: NSManagedObjectModel = {
        let modelURL = Bundle(for: CoreDataStack.self).url(forResource: "SearchMovies", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    static var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        let url = applicationDocumentsDirectory.appendingPathComponent("SearchMovies.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        let options = [NSMigratePersistentStoresAutomaticallyOption: NSNumber(value: true as Bool), NSInferMappingModelAutomaticallyOption: NSNumber(value: true as Bool)]
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: options)
        } catch {
            let dict : [String : Any] = [NSLocalizedDescriptionKey        : "Failed to initialize the application's saved data" as NSString,
                                         NSLocalizedFailureReasonErrorKey : "There was an error creating or loading the application's saved data." as NSString,
                                         NSUnderlyingErrorKey             : error as NSError]
            let wrappedError = NSError(domain: "Error_domain", code: 999, userInfo: dict)
            print("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()
    
    static var managedObjectContext: NSManagedObjectContext = {
        let coordinator = persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    static func getEntity<T: NSManagedObject>() -> T {
        if #available(iOS 10, *) {
            let obj = T(context: CoreDataStack.managedObjectContext)
            return obj
        } else {
            guard let entityDescription = NSEntityDescription.entity(forEntityName: NSStringFromClass(T.self), in: CoreDataStack.managedObjectContext) else {
                fatalError("Core Data entity name doesn't match.")
            }
            let obj = T(entity: entityDescription, insertInto: CoreDataStack.managedObjectContext)
            return obj
        }
    }
    
    static func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }
    
}
