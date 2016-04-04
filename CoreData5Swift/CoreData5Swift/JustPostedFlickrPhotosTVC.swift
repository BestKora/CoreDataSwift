//
//  JustPostedFlickrPhotosTVC.swift
//  AdaptiveSplitViewController1Swift
//
//  Created by Tatiana Kornilova on 2/9/16.
//  Copyright © 2016 Tatiana Kornilova. All rights reserved.
//

import UIKit
import CoreData

class JustPostedFlickrPhotosTVC: PhotographersCDTVC {
    

    override func viewDidLoad() {
        super.viewDidLoad()
        fetchPhotos()

}

    // создание work MOC
    lazy var workMoc: NSManagedObjectContext = {
        let moc = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        moc.parentContext = self.moc
        moc.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return moc
    }()


    @IBAction func fetchPhotos(){
        self.refreshControl?.beginRefreshing()
        let offSet = CGPoint (x: 0, y: -(self.refreshControl?.frame.size.height)!)
        self.tableView.setContentOffset(offSet, animated: true)

            let url = FlickrFetcher.URLforRecentGeoreferencedPhotos()
            let task = NSURLSession.sharedSession().downloadTaskWithURL(url) {
                (localURL, response, error) in
                guard error == nil else {return}
                
                // получаем массив словарей для фотографий с Flickr
                guard let url = localURL,
                    let data = NSData(contentsOfURL: url),
                    let json =
                       try? NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments),
                    let flickrPhotos =
                        json.valueForKeyPath(FLICKR_RESULTS_PHOTOS) as? [[String : AnyObject]]
                    else { return}
                
                // Записываем в Core Data
                self.workMoc.performBlock() {
                    _ = flickrPhotos.flatMap({ (json) -> Photo? in
                        return Photo.init(json: json, context: self.workMoc) })
                }
                let startTime = CFAbsoluteTimeGetCurrent()
                self.workMoc.performBlockAndWait() {
                    do {
                        try self.workMoc.save() } catch {
                            fatalError("Persistent store error! \(error)")
                    }
                    let endTime = CFAbsoluteTimeGetCurrent()
                    let elapsedTime = (endTime - startTime) * 1000
                    print("Saving work context took \(elapsedTime) ms")
                    
                    self.coreDataStack.saveMainContext()

                dispatch_async(dispatch_get_main_queue()){
                    self.refreshControl?.endRefreshing()
                      }
                }
            }
            task.resume()
    }
 }
