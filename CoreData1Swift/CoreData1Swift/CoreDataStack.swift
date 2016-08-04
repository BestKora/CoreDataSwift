

import Foundation
import CoreData

class CoreDataStack: NSObject {
  static let moduleName = "CoreData1Swift"
    
    lazy var mainMoc: NSManagedObjectContext = {
        let moc = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        moc.persistentStoreCoordinator = self.coordinator
        
        moc.mergePolicy =  NSMergeByPropertyObjectTrumpMergePolicy
        
        return moc
    }()

    private lazy var model: NSManagedObjectModel = {
        guard let modelURL = NSBundle.mainBundle().URLForResource(moduleName,
                                                            withExtension: "momd")
        else {
            fatalError("Ошибка при загрузке model из bundle")
        }
        guard let mom = NSManagedObjectModel(contentsOfURL: modelURL) else {
            
            fatalError("Ошибка инициализации модели mom из: \(modelURL)")
        }
        return mom
    }()

  private lazy var applicationDocumentsDirectory: NSURL = {
    let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
    return urls[urls.count-1]
  }()

  private lazy var coordinator: NSPersistentStoreCoordinator = {
    
    let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.model)

    let persistentStoreURL =
        self.applicationDocumentsDirectory.URLByAppendingPathComponent("\(moduleName).sqlite")
    print (persistentStoreURL)

    do {
      try coordinator.addPersistentStoreWithType(NSSQLiteStoreType,
                                configuration: nil,
                                          URL: persistentStoreURL,
                                      options: [NSMigratePersistentStoresAutomaticallyOption: true,
       NSInferMappingModelAutomaticallyOption: false])
    } catch {
      fatalError("Ошибка Persistent store! \(error)")
    }
    return coordinator
  }()
    
    func saveMainContext() {
        if mainMoc.hasChanges {
            do {
                let startTime = CFAbsoluteTimeGetCurrent()
                try mainMoc.save()
                let endTime = CFAbsoluteTimeGetCurrent()
                let elapsedTime = (endTime - startTime) * 1000
                print("Saving the context took \(elapsedTime) ms")
            } catch  {
                fatalError("Ошибка сохранения main managed object context! \(error)")
            }
        }
    }
}
