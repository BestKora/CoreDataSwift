

import Foundation
import CoreData

class CoreDataStack: NSObject {
  static let moduleName = "CoreData4Swift"

    func saveMainContext() {
        guard mainMoc.hasChanges || privateMoc.hasChanges else {
            return
        }
 
        mainMoc.performBlockAndWait() {
            do {
                let startTime = CFAbsoluteTimeGetCurrent()
                try self.mainMoc.save()
                let endTime = CFAbsoluteTimeGetCurrent()
                let elapsedTime = (endTime - startTime) * 1000
                print("Pushing main context took \(elapsedTime) ms")

            } catch {
                fatalError("Ошибка сохранения mainMoc! \(error)")
            }
        }
        
               privateMoc.performBlock() {
            do {
                let startTime1 = CFAbsoluteTimeGetCurrent()
                try self.privateMoc.save()
                let endTime1 = CFAbsoluteTimeGetCurrent()
                let elapsedTime1 = (endTime1 - startTime1) * 1000
                print("Saving private context took \(elapsedTime1) ms")
            } catch {
                fatalError("Ошибка сохранения privateMoc! \(error)")
            }
        }
       
    }
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        let modelURL = NSBundle.mainBundle().URLForResource(moduleName, withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()
    
    lazy var applicationDocumentsDirectory: NSURL = {
        return NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).last!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        
        let persistentStoreURL = self.applicationDocumentsDirectory.URLByAppendingPathComponent("\(moduleName).sqlite")
        print (persistentStoreURL)
        do {
            try coordinator.addPersistentStoreWithType(NSSQLiteStoreType,
                                                       configuration: nil,
                                                       URL: persistentStoreURL,
                                                       options: [NSMigratePersistentStoresAutomaticallyOption: true,
                                                        NSInferMappingModelAutomaticallyOption: false])
        } catch {
            fatalError("Persistent store error! \(error)")
        }
        
        return coordinator
    }()
    
    // создание writer MOC
    private lazy var privateMoc: NSManagedObjectContext = {
        let moc = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        
        moc.persistentStoreCoordinator = self.persistentStoreCoordinator
       
        moc.mergePolicy =  NSMergeByPropertyObjectTrumpMergePolicy

        return moc
    }()
    
    // создание main thread MOC
    lazy var mainMoc: NSManagedObjectContext = {
        let moc = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        
        moc.parentContext = self.privateMoc
        
        moc.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy

        return moc
    }()

}
