//
//  AppDelegate.swift
//  CoreData1Swift
//
//  Created by Tatiana Kornilova on 3/18/16.
//  Copyright © 2016 Tatiana Kornilova. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate  {

    var window: UIWindow?
    
    lazy var database = Database()
    
            func application(application: UIApplication, didFinishLaunchingWithOptions
        launchOptions: [NSObject: AnyObject]?) -> Bool {

   
                if let split = self.window?.rootViewController as? UISplitViewController,
                navigationMaster = split.viewControllers.first as? UINavigationController,
                topMaster = navigationMaster.topViewController
            {
                if topMaster.respondsToSelector(Selector("setDatabase:")) {
                    topMaster.performSelector(Selector("setDatabase:"), withObject: database)
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
}

