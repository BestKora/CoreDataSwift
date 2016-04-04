
//
//  PhotosByPhotographerCDTVC.swift
//  Photomania
//
//

import UIKit
import CoreData

class PhotosByPhotographerCDTVC: PhotosCDTVC  {

	var photographer : Photographer?{
		didSet{
			self.title = photographer?.name
            self.moc = photographer?.managedObjectContext
			self.setupFetchedResultsController()
		}
	}
    var moc: NSManagedObjectContext?
    
	func setupFetchedResultsController() {
		if let context = self.moc {
            
			let request = NSFetchRequest(entityName: "Photo")
			request.predicate = NSPredicate(format: "whoTook = %@", self.photographer!)
			request.sortDescriptors = [NSSortDescriptor(key: "title",
                                                  ascending: true,
                                                   selector: #selector(NSString.localizedStandardCompare(_:)))]
			
			self.fetchedResultsController = NSFetchedResultsController(fetchRequest: request,
                                                               managedObjectContext: context,
                                                                 sectionNameKeyPath: nil,
                                                                          cacheName: nil)
		}
		else {
			self.fetchedResultsController = nil
		}
	}
}
