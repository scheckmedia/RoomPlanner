//
//  ModelController.swift
//  RoomPlanner
//
//  Created by Felix Brix on 14.11.16.
//  Copyright © 2016 AR. All rights reserved.
//

import Foundation
import CoreData

class ModelObject {
    class func all() -> [NSManagedObject]? {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Model")
        
        do {
            let results = try managedContext.fetch(fetchRequest)
            return results as? [NSManagedObject]
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        
        return []
    }
}
