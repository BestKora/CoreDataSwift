//
//  PhotosCDTVC.swift
//  Photomania
//  Hook up fetchedResultsController to any Photo Fetch Request
//  Use "Photo Cell" as your table view cell's reuse object
//
//

import UIKit
import CoreData

class PhotosCDTVC: CoreDataTableViewController {
    var moc: NSManagedObjectContext?
    
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

    // MARK: - Table View Data Source
 
    override func tableView(tableView: UITableView,
                            cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.CellReuseIdentifier,
                                                               forIndexPath: indexPath)

        let photo = self.fetchedResultsController?.objectAtIndexPath(indexPath) as? Photo
        
        var photographerName:String? {
            if let photographer = photo?.whoTook {
                return photographer.name
            } else {return nil}
        }
        cell.textLabel?.text = photo?.title
        cell.detailTextLabel?.text = photo?.subtitle == "" ? photographerName: photo?.subtitle
        
        return cell
    }
    
    override func tableView(tableView: UITableView,
      commitEditingStyle editingStyle: UITableViewCellEditingStyle,
          forRowAtIndexPath indexPath: NSIndexPath) {
  
        switch editingStyle {
        case .Delete:
            guard let photo = self.fetchedResultsController?.objectAtIndexPath(indexPath) as? Photo,
                  let context = photo.managedObjectContext     else {return}
            
             context.deleteObject(photo)
            do {
                try context.save()
            } catch {
                fatalError("Ошибка сохранения main managed object context! \(error)")
            }
        default:break
        }
    }
    
    // MARK: - Storyboard
    private struct Storyboard {
        static let CellReuseIdentifier = "photoCell"
        static let SegueIdentifierPhoto = "Show Photo"
    }

	// MARK: - Navigation
	
    func prepareViewController(viewController : UIViewController,
                               forSegue segue : String?,
                      fromIndexPath indexPath : NSIndexPath) {
        
        guard let photo = self.fetchedResultsController?.objectAtIndexPath(indexPath) as? Photo
                         else { return }
        
        var ivc = viewController
                        
        if let vc = viewController as? UINavigationController {
            ivc = vc.visibleViewController!
        }
        guard let ivcm = ivc as? ImageViewController  else { return }
                        
            ivcm.imageURL = photo.imageURL
            ivcm.title = photo.title
            ivcm.navigationItem.leftBarButtonItem =
                                         self.splitViewController?.displayModeButtonItem()
            ivcm.navigationItem.leftItemsSupplementBackButton = true
    }
    

	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard  segue.identifier == Storyboard.SegueIdentifierPhoto ,
               let cell = sender as? UITableViewCell,
               let indexPath = self.tableView.indexPathForCell(cell)
            else {return}
		self.prepareViewController(segue.destinationViewController,
                                         forSegue: segue.identifier,
                                    fromIndexPath: indexPath)
	}
}