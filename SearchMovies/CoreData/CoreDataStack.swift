//
//  CoreDataStack.swift
//  SearchMovies
//
//  Created by Thafer Shahin on 8/21/18.
//  Copyright © 2018 Thafer Shahin. All rights reserved.
//

import Foundation

import CoreData

/// Type for filtering
///
/// - match: <#match description#>
/// - contains: <#contains description#>
enum FilterType {
    case match
    case contains
}

/// This class is to support CoreData for iOS < 10, as NSPersistentContainer requires iOS
class CoreDataStack {
    
    /// Returns URL for application document directory.
    static var applicationDocumentsDirectory: URL = {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1]
    }()
    
    /// Managed object model used by persistent store coordinator.
    static var managedObjectModel: NSManagedObjectModel = {
        let modelURL = Bundle(for: CoreDataStack.self).url(forResource: "SearchMovies", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    /// Persistent store coordinator used for iOS 10 and above.
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
    
    /// App's managed object context. Used access core data context.
    static var managedObjectContext: NSManagedObjectContext = {
        let coordinator = persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    /// Returns ManagedObject for specified entity using proper methods according to current iOS version.
    ///
    /// - Returns: <#return value description#>
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
    
    /// Save changes to app's core data context.
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
    
    /// Insert provided keyword to persistent suggestions.
    ///
    /// Suggestions are limited to 10. Oldest suggestion will be removed when exceed 10 entires.
    ///
    /// This method make sure that the keyword is not already
    /// exists with persistent suggestions, if it does then it remove it and reinsert it.
    ///
    ///
    /// - Parameter keyword: <#keyword description#>
    static func insertSuggestion(keyword : String) {
        
        // Delete old suggestion if it is already exists.
        CoreDataStack.deleteSuggestion(keyword: keyword)
        
        // Delete oldes suggestion if suggestions already reach 10 entries limit.
        if CoreDataStack.getSuggestion(filter: "", filterType: .contains).count == 10 {
            CoreDataStack.deleteOldestSuggestion()
        }
        
        // Insert provided keyword into persistent suggestions.
        let suggestion : MovieQuery = CoreDataStack.getEntity()
        suggestion.keyword = keyword
        CoreDataStack.saveContext()
        
    }
    
    /// Deletes oldest suggestion. This method should be called when suggestions exceed 10 entries limit.
    static func deleteOldestSuggestion() {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: MovieQuery.self))
        do {
            let result = try CoreDataStack.managedObjectContext.fetch(request)
            if let entry = result[0] as? NSManagedObject {
                CoreDataStack.managedObjectContext.delete(entry)
                CoreDataStack.saveContext()
            }
        } catch (let error) {
            print("CoreData error: \(error), error description: \(error.localizedDescription)")
        }
    }
    
    /// Delete suggestion entry which match provided keyword if exists.
    ///
    /// - Parameter keyword: <#keyword description#>
    static func deleteSuggestion(keyword : String) {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: MovieQuery.self))
        request.predicate = NSPredicate(format: "keyword == %@", keyword)
        do {
            let result = try CoreDataStack.managedObjectContext.fetch(request)
            for entry in result as! [NSManagedObject] {
                CoreDataStack.managedObjectContext.delete(entry)
            }
            CoreDataStack.saveContext()
        } catch (let error) {
            print("CoreData error: \(error), error description: \(error.localizedDescription)")
        }
    }
    
    /// Get all suggestion filtered to provided keyword.
    ///
    /// - Parameter filter: <#filter description#>
    static func getSuggestion(filter : String, filterType : FilterType) -> [Suggestion] {
        // Retrieve all suggestion from persistent store.
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: MovieQuery.self))
        if filter.isEmpty == false {
            request.predicate = NSPredicate(format: filterType == .match ? "keyword == %@" : "keyword contains[c] %@", filter)
        }
        request.returnsObjectsAsFaults = false
        var suggestions = [Suggestion]()
        do {
            let result = try CoreDataStack.managedObjectContext.fetch(request)
            for entry in result as! [NSManagedObject] {
                suggestions.append(Suggestion(keyword: entry.value(forKey: "keyword") as! String))
            }
        } catch (let error) {
            print("CoreData error: \(error), error description: \(error.localizedDescription)")
        }
        // Reverse suggestions to show latest at top.
        return suggestions.reversed()
    }
    
}
