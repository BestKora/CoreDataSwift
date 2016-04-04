//
//  AppDelegate.swift
//  AdaptiveSplitViewController1Swift
//
//  Created by Tatiana Kornilova on 2/9/16.
//  Copyright © 2016 Tatiana Kornilova. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {

    var window: UIWindow?
    
    lazy var coreDataStack = CoreDataStack()
    
    func application(application: UIApplication, didFinishLaunchingWithOptions
        launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        if let split = self.window?.rootViewController as? UISplitViewController,
            navigationMaster = split.viewControllers.first as? UINavigationController,
            topMaster = navigationMaster.topViewController
        {
            if topMaster.respondsToSelector(Selector("setCoreDataStack:")) {
                topMaster.performSelector(Selector("setCoreDataStack:"), withObject: coreDataStack)
            }
        }
        
        if let split = self.window?.rootViewController as? UISplitViewController,
            navigationDetail = split.viewControllers.last as? UINavigationController
        {
            navigationDetail.topViewController?.navigationItem.leftBarButtonItem
                = split.displayModeButtonItem()
            navigationDetail.topViewController?.navigationItem.leftItemsSupplementBackButton = true
            split.delegate = self
            
            split.preferredDisplayMode = .AllVisible
            
            //  split.preferredPrimaryColumnWidthFraction = 0.5
            //  split.maximumPrimaryColumnWidth = 512
        }
        
            self.window?.makeKeyAndVisible()
            return true
    }

    // MARK: - Split view
    
    func splitViewController(splitViewController: UISplitViewController,
        collapseSecondaryViewController secondaryViewController:UIViewController,
        ontoPrimaryViewController primaryViewController:UIViewController) -> Bool {
            
        guard let secondaryAsNav = secondaryViewController as? UINavigationController,
              let topAsDetail = secondaryAsNav.topViewController as? ImageViewController where
              topAsDetail.imageURL == nil else {return false}
            
            // Возврат true сигнализирует, что Detail должен быть отброшен
            return true
    }
    
    func splitViewController(splitViewController: UISplitViewController,
                             separateSecondaryViewControllerFromPrimaryViewController
        primaryViewController: UIViewController) -> UIViewController? {
        
        guard let masterAsNav = primaryViewController as? UINavigationController,
            let photosView = masterAsNav.topViewController as? PhotosCDTVC
            else { return nil }
        
        //-------- Detail----
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let detailAsNav =
            storyboard.instantiateViewControllerWithIdentifier("detailNavigation")
                as? UINavigationController,
            let controller = detailAsNav.visibleViewController as? ImageViewController
            else { return nil }
        
        // Выделяем первую строку
        let indexPath = NSIndexPath(forRow: 0, inSection: 0)
        photosView.tableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: .Top)
        
        // Обеспечиваем появление обратной кнопки
        controller.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem()
        controller.navigationItem.leftItemsSupplementBackButton = true
        
        //--------Настройка Модели на первое photo ----
        if let photo = photosView.fetchedResultsController?.objectAtIndexPath(indexPath) as? Photo{
            controller.imageURL =  photo.imageURL
            controller.title = photo.title
        }
        return detailAsNav
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        coreDataStack.saveMainContext()
    }
    
   }


