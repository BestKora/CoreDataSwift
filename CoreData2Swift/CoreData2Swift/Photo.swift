//
//  Photo.swift
//  AdaptiveSplitViewController6Swift
//
//  Created by Tatiana Kornilova on 3/11/16.
//  Copyright © 2016 Tatiana Kornilova. All rights reserved.
//

import Foundation
import CoreData

final class Photo: NSManagedObject {
    
    convenience init?(json : [String : AnyObject], context: NSManagedObjectContext) {
        guard var title = json[FLICKR_PHOTO_TITLE] as? String,
            var subtitle = (json as AnyObject).valueForKeyPath(FLICKR_PHOTO_DESCRIPTION) as? String,
            let imageURL = FlickrFetcher.URLforPhoto(json,format:FlickrPhotoFormatLarge),
            let unique = json[FLICKR_PHOTO_ID] as? String,
            let photographer =  json[FLICKR_PHOTO_OWNER] as? String
            else {return nil}
        
        // убираем пробелы с обоих концов
        title = title.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        subtitle = subtitle.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        
        // специальные требования формирования атрибутов Photo
        let titleNew =  title == "" ? subtitle: title
        
        guard let entity = NSEntityDescription.entityForName("Photo", inManagedObjectContext: context)
            else {return nil}
        
        self.init(entity: entity, insertIntoManagedObjectContext: context)
        
        self.unique = unique
        self.title = titleNew == "" ? "Unknown": titleNew
        self.subtitle = subtitle
        self.imageURL = imageURL
        self.whoTook = Photographer(name: photographer, context: context)
    }
    
    static func newPhotos(json : [[String : AnyObject]],context: NSManagedObjectContext) {
        var uniques = [String]()
        let fetchRequest = NSFetchRequest(entityName: "Photo")
        do {
            if let results = try context.executeFetchRequest(fetchRequest) as? [Photo] {
                uniques = results.flatMap({ $0.unique}).sort()
                print (uniques.count)
            }
        } catch {
            fatalError("Ошибка при выборе списка фотографий!")
        }
        let uniquesFlickr = json.flatMap({$0[FLICKR_PHOTO_ID] as? String}).sort()
        
        let uniquesSet = Set(uniques)
        var news = Set(uniquesFlickr)
        news.subtractInPlace(uniquesSet)
        print ("кол-во новых элементов \(news.count)")
    /*    for unic in news {
            if let index = json.indexOf({$0[FLICKR_PHOTO_ID] as? String == unic}){
                _ =  Photo.init(json: json[index], context: context)
            }
        }*/
    }
    
    override func prepareForDeletion() {
        guard let p = whoTook else { return }
        if p.photos.filter ({ !$0.deleted }).isEmpty {
            managedObjectContext?.deleteObject(p)
        }
    }

}
