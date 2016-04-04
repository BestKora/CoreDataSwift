//
//  CoreDataTableViewController.swift
//  Photomania
//
//

import CoreData
import UIKit

/**
 Swift версия класса первоначально созданного **Stanford CS193p Winter 2013**.
 Этот класс по большой части просто копирует код из документации `NSFetchedResultsController`
 в subclass `UITableViewController`.
 Просто создайте subclass этого класса и установите свойство `fetchedResultsController`.
 Единственный метод `UITableViewDataSource`, который вы **ДОЛЖНЫ** реализовать, 
 это `tableView:cellForRowAtIndexPath:`.
 Вы можете использовать `NSFetchedResultsController` метод `objectAtIndexPath:` для его реализации.
 Помните, что как только вы создали `NSFetchedResultsController`, вы **НЕ МОЖЕТЕ** изменять его свойства.
 Если вы хотите новые параметры выборки (predicate, sorting, etc.),
 создайте  **НОВЫЙ** `NSFetchedResultsController` и установите свойство класса
 `fetchedResultsController` заново.
 */
public class CoreDataTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    /// Это controller *(этот класс не выберет ничего, если он не будет установлен)*.
    public var fetchedResultsController: NSFetchedResultsController? {
        didSet {
            if let frc = fetchedResultsController {
                if frc != oldValue {
                    frc.delegate = self
                    do {
                        try performFetch()
                    } catch {
                        print(error)
                    }
                }
            } else {
                tableView.reloadData()
            }
        }
    }
    
    /**
     Заставляет `fetchedResultsController` заново выбирать данные.
     Вам практически никогда не придется его вызывать.
     Класс `NSFetchedResultsController` отслеживает context
     (так что если объекты в context изменяются, вам не нужно вызывать `performFetch`,
     так как `NSFetchedResultsController` заметит изменения и модифицирует таблицу автоматически).
     Это также будет автоматически вызвано, если вы изменили свойство `fetchedResultsController`.
     */
    public func performFetch() throws {
        if let frc = fetchedResultsController {
            defer {
                tableView.reloadData()
            }
            do {
                try frc.performFetch()
            } catch {
                throw error
            }
        }
    }
    
    private var _suspendAutomaticTrackingOfChangesInManagedObjectContext: Bool = false
    /**
     Turn this on before making any changes in the managed object context that
     are a one-for-one result of the user manipulating rows directly in the table view.
     Such changes cause the context to report them (after a brief delay),
     and normally our `fetchedResultsController` would then try to update the table,
     but that is unnecessary because the changes were made in the table already (by the user)
     so the `fetchedResultsController` has nothing to do and needs to ignore those reports.
     Turn this back off after the user has finished the change.
     Note that the effect of setting this to NO actually gets delayed slightly
     so as to ignore previously-posted, but not-yet-processed context-changed notifications,
     therefore it is fine to set this to YES at the beginning of, e.g., `tableView:moveRowAtIndexPath:toIndexPath:`,
     and then set it back to NO at the end of your implementation of that method.
     It is not necessary (in fact, not desirable) to set this during row deletion or insertion
     (but definitely for row moves).
     */
    public var suspendAutomaticTrackingOfChangesInManagedObjectContext: Bool {
        get {
            return _suspendAutomaticTrackingOfChangesInManagedObjectContext
        }
        set (newValue) {
            if newValue == true {
                _suspendAutomaticTrackingOfChangesInManagedObjectContext = true
            } else {
                dispatch_after(0, dispatch_get_main_queue(), { self._suspendAutomaticTrackingOfChangesInManagedObjectContext = false })
            }
        }
    }
    private var beganUpdates: Bool = false
    
    // MARK: NSFetchedResultsControllerDelegate
    
    /**
    Notifies the receiver that the fetched results controller is about to start processing of one or more changes due to an add, remove, move, or update.
    
    :param: controller The fetched results controller that sent the message.
    */
    public func controllerWillChangeContent(controller: NSFetchedResultsController) {
        if !suspendAutomaticTrackingOfChangesInManagedObjectContext {
            tableView.beginUpdates()
            beganUpdates = true
        }
    }
    
    /**
     Notifies the receiver of the addition or removal of a section.
     
     :param: controller The fetched results controller that sent the message.
     :param: sectionInfo The section that changed.
     :param: sectionIndex The index of the changed section.
     :param: type The type of change (insert or delete).
     */
    public func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        if !suspendAutomaticTrackingOfChangesInManagedObjectContext {
            switch type {
            case .Insert:
                tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
            case .Delete:
                tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
            default:
                return
            }
        }
    }
    
    /**
     Notifies the receiver that a fetched object has been changed due to an add, remove, move, or update.
     
     :param: controller The fetched results controller that sent the message.
     :param: anObject The object in controller’s fetched results that changed.
     :param: indexPath The index path of the changed object (this value is nil for insertions).
     :param: type The type of change.
     :param: newIndexPath The destination path for the object for insertions or moves (this value is nil for a deletion).
     */
    public func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        if !suspendAutomaticTrackingOfChangesInManagedObjectContext {
            switch type {
            case .Insert:
                tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
            case .Delete:
                tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            case .Update:
                tableView.reloadRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            case .Move:
                // TODO: fix bug when moving rows in iOS 8.3 and 8.4 - Xcode 7.0 (7A220)
                // SEE: http://stackoverflow.com/questions/31383760/ios-9-attempt-to-delete-and-reload-the-same-index-path
                tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
                tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
            }
        }
    }
    
    /**
     Notifies the receiver that the fetched results controller has completed processing of one or more changes due to an add, remove, move, or update.
     
     :param: controller The fetched results controller that sent the message.
     */
    public func controllerDidChangeContent(controller: NSFetchedResultsController) {
        if beganUpdates {
            tableView.endUpdates()
        }
    }
    
    // MARK: UITableViewDataSource
    
    /**
    Asks the data source to return the number of sections in the table view.
    
    :param: tableView An object representing the table view requesting this information.
    
    :returns: The number of sections in tableView.
    */
    public override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return fetchedResultsController?.sections?.count ?? 0
    }
    
    /**
     Tells the data source to return the number of rows in a given section of a table view. (required)
     
     :param: tableView The table-view object requesting this information.
     :param: section An index number identifying a section in tableView.
     
     :returns: The number of rows in section.
     */
    public override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (fetchedResultsController?.sections?[section])?.numberOfObjects ?? 0
    }
    
    /**
     Asks the data source for the title of the header of the specified section of the table view.
     
     :param: tableView An object representing the table view requesting this information.
     :param: section An index number identifying a section in tableView.
     
     :returns: A string to use as the title of the section header.
     */
    public override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return (fetchedResultsController?.sections?[section])?.name
    }
    
    /**
     Asks the data source to return the index of the section having the given title and section title index.
     
     :param: tableView An object representing the table view requesting this information.
     :param: title The title as displayed in the section index of tableView.
     :param: index An index number identifying a section title in the array returned by sectionIndexTitlesForTableView:.
     
     :returns: An index number identifying a section.
     */
    public override func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int {
        return fetchedResultsController?.sectionForSectionIndexTitle(title, atIndex: index) ?? 0
    }
    
    /**
     Asks the data source to return the titles for the sections for a table view.
     
     :param: tableView An object representing the table view requesting this information.
     
     :returns: An array of strings that serve as the title of sections in the table view and appear in the index list on the right side of the table view.
     */
    public override func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
        return fetchedResultsController?.sectionIndexTitles
    }
    
}
