//
//  ViewController.swift
//  AsyncImages
//
//  Created by Bernardo Santana on 7/13/16.
//  Copyright © 2016 Bernardo Santana. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    let GRID_SIZE = 15
    let modelController = kMeansModelController(k: 3)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        modelController.delegate = self
        beginLoadingImages()
        
    }

    func beginLoadingImages() {
        guard let urlStringList:[String] = urlStringsFromJSON() else { return }

        let urlList = urlStringList.map({return NSURL(string:$0)!})
        
        for url in urlList[0..<(GRID_SIZE)] {
            NetworkManager.shared.getDataFrom(url) { data, response, error in
                guard let data = data where error == nil else { return }
                
                if let image = UIImage(data: data) {
                    let name = response?.suggestedFilename ?? url.lastPathComponent ?? "Downloaded file"
                    if name != "photo_unavailable.png" {
                        let clusterImage = ClusterImage(image: image)
                        self.modelController.addImagesAndRecalculateCentroids([clusterImage])
                    }
                }
                
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
        let offset:CGFloat = 10
        view.subviews.map({$0.removeFromSuperview()})
        for (i,cluster) in clusters.enumerate() {
            for (j,img) in cluster.enumerate() {
                let imageView = UIImageView(image: img.image)
                imageView.frame = CGRect(x: CGFloat(j)*offset, y: CGFloat(i)*3*offset, width: offset, height: offset)
                view.addSubview(imageView)
            }
        }
    }
}
