//
//  Database.swift
//
//  Created by Tatiana Kornilova on 3/18/16.
//  Copyright © 2016 Tatiana Kornilova. All rights reserved.
//

import UIKit
import CoreData

extension NSManagedObjectContext
{
    public func saveThrows () {
        do {
            try save()
        } catch let error  {
            print("Core Data Error: \(error)")
        }
    }
}

class MyDocument :UIManagedDocument {
    
    override class func persistentStoreName() -> String{
        return "Flickr.sqlite"
    }
 
    override func contentsForType(typeName: String) throws -> AnyObject {
        print ("Auto-Saving Document")
        return try! super.contentsForType(typeName)
    }
    
    override func handleError(error: NSError, userInteractionPermitted: Bool) {
        // идея отсюда http://blog.stevex.net/2011/12/uimanageddocument-autosave-troubleshooting/
        print("Ошибка при записи:\(error.localizedDescription)")
        if let userInfo = error.userInfo as? [String:AnyObject],
            let conflicts = userInfo["conflictList"] as? NSArray{
            print("Конфликты при записи:\(conflicts)")
            
        }
    }
}

extension UIManagedDocument
{
    func save () {
        do {
            try self.managedObjectContext.save()
        } catch let error  {
            print("Core Data Error: \(error)")
        }
    }
    
    class func useDocument (completion: (success:Bool, document: MyDocument) -> Void) {
        let fileManager = NSFileManager.defaultManager()
        let doc = "database"
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory,
                                                                   inDomains: .UserDomainMask)
        let url = urls[urls.count-1].URLByAppendingPathComponent(doc)
        print (url)
        let document = MyDocument(fileURL: url)
        document.persistentStoreOptions =
            [ NSMigratePersistentStoresAutomaticallyOption: true,
              NSInferMappingModelAutomaticallyOption: true]
        
        document.managedObjectContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        if let parentContext = document.managedObjectContext.parentContext{
            parentContext.performBlock {
                parentContext.mergePolicy =  NSMergeByPropertyObjectTrumpMergePolicy
            }
        }
        
        if !fileManager.fileExistsAtPath(url.path!) {
            document.saveToURL(url, forSaveOperation: .ForCreating) { (success) -> Void in
                if success {
                    print("File создан: Success")
                    completion (success: success, document: document)                }
            }
        }else  {
            if document.documentState == .Closed {
                document.openWithCompletionHandler(){(success:Bool) -> Void in
                    if success {
                        print("File существует: Открыт")
                        completion (success: success, document: document)                    }
                }
            } else {
                completion (success: true, document: document)
            }
        }
    }

 }


/*class Database {
    let printOpenFile: (Bool) -> Void = {  (success:Bool) -> Void in
        if (success) {
            print("File существует: Открыт")
        } else {
            print("File существует: Не могу открыть")
        }
    }
    
    let printCreateFile: (Bool) -> Void  = {  (success:Bool) -> Void in
        if (success) {
            print("File создан: Success")
        } else {
            print("Не могу создать file")
        }
    }

    class func useDocument (completion: (success:Bool, document: MyDocument) -> Void) {
        let fileManager = NSFileManager.defaultManager()
        let doc = "database"
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory,
                                                                   inDomains: .UserDomainMask)
        let url = urls[urls.count-1].URLByAppendingPathComponent(doc)
        print (url)
        let document = MyDocument(fileURL: url)
        document.persistentStoreOptions =
            [ NSMigratePersistentStoresAutomaticallyOption: true,
              NSInferMappingModelAutomaticallyOption: true]
        
        document.managedObjectContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        if let parentContext = document.managedObjectContext.parentContext{
            parentContext.performBlock {
                parentContext.mergePolicy =  NSMergeByPropertyObjectTrumpMergePolicy
            }
        }
        
        if !fileManager.fileExistsAtPath(url.path!) {
            document.saveToURL(url, forSaveOperation: .ForCreating) { (success) -> Void in
                if success {
                    print("File создан: Success")
                    completion (success: success, document: document)                }
            }
        }else  {
            if document.documentState == .Closed {
                document.openWithCompletionHandler(){(success:Bool) -> Void in
                    if success {
                        print("File существует: Открыт")
                        completion (success: success, document: document)                    }
                }
            } else {
                completion (success: true, document: document)
            }
        }
    }

    lazy var document: MyDocument? =  {
        
        let fileManager = NSFileManager.defaultManager()
        let doc = "database"
        let url = self.dir.URLByAppendingPathComponent(doc)
        print (url)
        let document = MyDocument(fileURL: url)
        document.persistentStoreOptions =
                        [ NSMigratePersistentStoresAutomaticallyOption: true,
                          NSInferMappingModelAutomaticallyOption: true]

        if fileManager.fileExistsAtPath(url.path!) {
            document.openWithCompletionHandler(){(success:Bool) -> Void in
                self.printOpenFile(success)
            }
        } else {
            document.saveToURL(url, forSaveOperation: .ForCreating) { (success) -> Void in
                // block для выполнения, когда документ создан
                self.printCreateFile(success)

              }
        }
        
        document.managedObjectContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        if let parentContext = document.managedObjectContext.parentContext{
            parentContext.performBlock {
                parentContext.mergePolicy =  NSMergeByPropertyObjectTrumpMergePolicy
            }
        }
        return document
    }()
    
    private lazy var dir: NSURL = {
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory,
                                                                   inDomains: .UserDomainMask)
        return urls[urls.count-1]
    }()
    
   }
*/
//NSMergeByPropertyStoreTrumpMergePolicy

