//
//  ModelMenuController.swift
//  RoomPlanner
//
//  Created by Felix Brix on 21.11.16.
//  Copyright © 2016 AR. All rights reserved.
//

import Foundation
import UIKit

class ModelMenuController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

//    func collectionView(collectionView: UICollectionView, cellForItemAt indexPath: NSIndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath as IndexPath)
//        let imageview:UIImageView = UIImageView(frame: CGRect(x: 50, y: 50, width: self.view.frame.width - 200, height: 50))
//        
//        let model = ModelObject.all()?[indexPath.row]
//        print(ModelObject.all())
//        print(model ?? "")
//        let image:UIImage = UIImage(named: "")!
//        imageview.image = image
//        cell.contentView.addSubview(imageview)
//        
//        return cell
//    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath as IndexPath)
        cell.backgroundColor = UIColor.red
    
        return cell
    }
    
    private func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let models = ModelObject.all() {
            return models.count
        } else {
            return 0
        }
    }
    
}
