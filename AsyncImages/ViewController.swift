//
//  ViewController.swift
//  AsyncImages
//
//  Created by Bernardo Santana on 7/13/16.
//  Copyright © 2016 Bernardo Santana. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    let modelController = kMeansModelController(k: 3)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        modelController.delegate = self
        beginLoadingImages()
        
    }

    func beginLoadingImages() {
        guard let urlStringList:[String] = urlStringsFromJSON() else { return }
        
        let urlList = urlStringList.map({return NSURL(string:$0)!})
        for url in urlList {
            NetworkManager.shared.getDataFrom(url) { data, response, error in
                guard let data = data where error == nil else { return }
                let clusterImage = ClusterImage(image: UIImage(data: data)!)
                self.modelController.addImagesAndRecalculateCentroids([clusterImage])
            }
        }
        
    }
    
    func urlStringsFromJSON() -> [String]? {
        if let filePath = NSBundle.mainBundle().pathForResource("images", ofType: "json") {
        let data = NSFileManager.defaultManager().contentsAtPath(filePath)
            do {
                let imageURLList = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments) as! [String]
                return imageURLList
            } catch let error as NSError {
                print("Error serializing JSON file \(error)")
            }
        } else {
            print("Error loading JSON file, is it in the project directory?")
        }

        return nil
    }


}

extension ViewController: kMeansMCDelegate {
    func drawClusters(clusters: [[ClusterImage]]) {
        
    }
}
