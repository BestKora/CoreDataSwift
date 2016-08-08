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
            UIManagedDocument.useDocument{ (success, document) in
                if success {
                    self.moc =  document.managedObjectContext
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
                    context.saveThrows()
                    
                    let endTime = CFAbsoluteTimeGetCurrent()
                    let elapsedTime = (endTime - startTime) * 1000
                    print("Saving the context took \(elapsedTime) ms")
                }
            }
            task.resume()
        }
    }
}


