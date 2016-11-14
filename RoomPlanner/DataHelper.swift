//
//  DataHelper.swift
//  RoomPlanner
//
//  Created by Felix Brix on 14.11.16.
//  Copyright © 2016 AR. All rights reserved.
//
//  Created with: Using Swift to Seed a Core Data Database
//  Andrew Bancroft | https://www.andrewcbancroft.com/2015/02/25/using-swift-to-seed-a-core-data-database/

import Foundation
import CoreData

public class DataHelper {
    let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func seedModels() {        
        let models = [
            (name: "Round Sofa", path: "RoundSofa.obj")
        ]
        
        for model in models {
            let newModel = NSEntityDescription.insertNewObject(
                forEntityName: "Model", into: context
            ) as! Model
            
            newModel.name = model.name
            newModel.path = model.path
        }
    
        do {
            try context.save()
        } catch _ { }
    }
}
