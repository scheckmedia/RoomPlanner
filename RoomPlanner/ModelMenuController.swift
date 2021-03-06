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
    var activeModels: [String] = []
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath as IndexPath)
        
        if let model = ModelObject.all()?[indexPath.row] {
            let imageview:UIImageView = UIImageView(
                frame: CGRect(
                    x: 0,
                    y: 0,
                    width: 100,
                    height: 100
                )
            )
            
            let imageFileName = model.value(forKey: "image")
            let image:UIImage = UIImage(named: imageFileName as! String)!
            
            imageview.image = image
            cell.layer.setValue(model.value(forKey: "path"), forKey: "modelPath")
            cell.contentView.addSubview(imageview)
            cell.contentView.alpha = 0.5
        }

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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) {
            let modelPath = cell.layer.value(forKey: "modelPath") as! String

            if cell.contentView.alpha != 1 {
                cell.contentView.alpha = 1
                activeModels.append(modelPath)
            } else {
                cell.contentView.alpha = 0.5
                activeModels = activeModels.filter() { $0 != modelPath }
            }
            
            UserDefaults.standard.set(
                activeModels, forKey: "activeModels"
            )
        }
    }
}
