//
//  Database.swift
//
//  Created by Tatiana Kornilova on 3/18/16.
//  Copyright © 2016 Tatiana Kornilova. All rights reserved.
//

import UIKit
import CoreData

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

    func saveDocument(){
        let fileNormal = documentState.contains([.Normal])
        if  fileNormal {
           saveToURL(fileURL,forSaveOperation: .ForOverwriting) { (success) -> Void in
                    // block для выполнения после сохранения документа
                    if (success) {
                        print("Запись: Success")
                    } else {
                        print("Не могу записать file")
                    }
            }
        } else {
            print("Документ не открыт, его состояние \(documentState)")
        }
    }
    }

    


class Database: NSObject {
    
    lazy var document: MyDocument? =  {
        
        let fileManager = NSFileManager.defaultManager()
        let doc = "database"
        let url = self.dir.URLByAppendingPathComponent(doc)
        print (url)
        let document = MyDocument(fileURL: url)
        document.persistentStoreOptions =
                        [ NSMigratePersistentStoresAutomaticallyOption: true,
                          NSInferMappingModelAutomaticallyOption: true]
        let printOpenFile = {  (success:Bool) -> Void in
            if (success) {
                print("File существует: Открыт")
            } else {
                print("File существует: Не могу открыть")
            }
        }
        let printCreateFile = {  (success:Bool) -> Void in
            if (success) {
                print("File создан: Success")
            } else {
                print("Не могу создать file")
            }
        }

        if fileManager.fileExistsAtPath(url.path!) {
            document.openWithCompletionHandler(){(success:Bool) -> Void in
                printOpenFile(success)
            }
        } else {
            
            document.saveToURL(url, forSaveOperation: .ForCreating) { (success) -> Void in
                // block для выполнения, когда документ создан
                printCreateFile(success)

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

//NSMergeByPropertyStoreTrumpMergePolicy

