//
//  JustPostedFlickrPhotosTVC.swift
//  AdaptiveSplitViewController1Swift
//
//  Created by Tatiana Kornilova on 2/9/16.
//  Copyright © 2016 Tatiana Kornilova. All rights reserved.
//

import UIKit
import CoreData

class JustPostedFlickrPhotosTVC: PhotosCDTVC {
    var moc: NSManagedObjectContext? {
        didSet {
        if let context = moc {
            fetchPhotos()
            self.setupFetchedResultsController(context)
            }
        }
    }
    
 
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if moc == nil {
     //       useDocument()
            Database ().useDocument{ (success, document) in
                if success {
                    self.moc =  document.managedObjectContext
                    self.document = document;
                }
            }
        }
    }
    
    func setupFetchedResultsController(context:NSManagedObjectContext) {
        
        let request = NSFetchRequest(entityName: "Photo")
        request.sortDescriptors = [NSSortDescriptor(key: "title",
            ascending: true,
            selector: #selector(NSString.localizedStandardCompare(_:)))]
        
        self.fetchedResultsController = NSFetchedResultsController(fetchRequest: request,
                                                                   managedObjectContext: context,
                                                                   sectionNameKeyPath: nil,
                                                                   cacheName: nil)
        
    }

    @IBAction func fetchPhotos(){
        self.refreshControl?.beginRefreshing()
        
        let offSet = CGPoint (x: 0, y: -(self.refreshControl?.frame.size.height)!)
        self.tableView.setContentOffset(offSet, animated: true)

        if let context = self.moc {
            let url = FlickrFetcher.URLforRecentGeoreferencedPhotos()
            let task = NSURLSession.sharedSession().downloadTaskWithURL(url)
            {(localURL, response, error) in
                guard error == nil else {return}
                
                // получаем массив словарей для фотографий с Flickr
                guard let httpResponse = response as? NSHTTPURLResponse where
                                             httpResponse.statusCode == 200,
                      let url = localURL,
                      let data = NSData(contentsOfURL: url),
                      let json = try? NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments),
                      let flickrPhotos = json.valueForKeyPath(FLICKR_RESULTS_PHOTOS) as? [[String : AnyObject]]
                    else { return}
                
                dispatch_async(dispatch_get_main_queue()){
                    self.refreshControl?.endRefreshing()
                    
                    // Записываем в Core Data
                    Photo.newPhotos (flickrPhotos, context: context)
                    _ = flickrPhotos.flatMap({ (json) -> Photo? in
                                     return Photo.init(json: json, context: context) })
                   
                    let startTime = CFAbsoluteTimeGetCurrent()
                    
                   self.document?.saveDocument()
                    
                    let endTime = CFAbsoluteTimeGetCurrent()
                    let elapsedTime = (endTime - startTime) * 1000
                    print("Saving the context took \(elapsedTime) ms")
                }
            }
            task.resume()
        }
    }
/*
    func useDocument () {
        let fileManager = NSFileManager.defaultManager()
        let doc = "database"
        let url = self.dir.URLByAppendingPathComponent(doc)
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
                // block для выполнения, когда документ создан
                self.printCreateFile(success)
                if success {
                    self.moc =  document.managedObjectContext
                    self.document = document;
                }
            }
        }else  {
            if document.documentState == .Closed {
                document.openWithCompletionHandler(){(success:Bool) -> Void in
                    self.printOpenFile(success)
                    if success {
                        self.moc =  document.managedObjectContext
                        self.document = document;
                    }
                }
            } else {
                self.moc =  document.managedObjectContext
                self.document = document;
                
            }
        }
    }
    
    

    
    private lazy var dir: NSURL = {
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory,
                                                                   inDomains: .UserDomainMask)
        return urls[urls.count-1]
    }()
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
    }*/

}


