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

    override var database:  Database! {
        didSet {
           self.moc = database.document?.managedObjectContext
            fetchPhotos()
        }
    }
     var moc: NSManagedObjectContext?
    
     // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        if let context = self.moc {
            self.setupFetchedResultsController(context)
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
                guard let url = localURL,
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
}


