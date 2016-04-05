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
    
  // MARK: - Table View Data Source
    override func tableView(tableView: UITableView,
                            cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.CellReuseIdentifier,
                                                                       forIndexPath: indexPath)

        let photo = self.fetchedResultsController?.objectAtIndexPath(indexPath) as? Photo
        
        cell.textLabel?.text = photo?.title
        cell.detailTextLabel?.text = photo?.subtitle == "" ? photo?.unique: photo?.subtitle
        
        return cell
    }
    
    // MARK: - Storyboard
    private struct Storyboard {
        static let CellReuseIdentifier = "photoCell"
        static let SegueIdentifierPhoto = "Show Photo"
    }

	// MARK: - Navigation
	  
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard  segue.identifier == Storyboard.SegueIdentifierPhoto ,
               let cell = sender as? UITableViewCell,
               let indexPath = self.tableView.indexPathForCell(cell),
               let photo = self.fetchedResultsController?.objectAtIndexPath(indexPath) as? Photo
            else {return}
        var ivc = segue.destinationViewController
        if let vc = ivc as? UINavigationController {
            ivc = vc.visibleViewController!
        }
        guard let ivcm = ivc as? ImageViewController  else { return }
        
        ivcm.imageURL = photo.imageURL
        ivcm.title = photo.title
        
        ivcm.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
        ivcm.navigationItem.leftItemsSupplementBackButton = true

	}
 }
