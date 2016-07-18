//
//  ViewController.swift
//  AsyncImages
//
//  Created by Bernardo Santana on 7/13/16.
//  Copyright © 2016 Bernardo Santana. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var recalculateButton:UIBarButtonItem!
    
    let GRID_SIZE = 15
    var nColumns:Int = 0
    var tileWidth:CGFloat = 0
    let modelController = kMeansModelController(k: 3)
    var imageViews = [Int:GridImageView]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        modelController.delegate = self
        beginLoadingImages()
        (nColumns,tileWidth) = getGridDimensionsFor(GRID_SIZE)
    }
    
    func beginLoadingImages() {
        guard let urlStringList:[String] = urlStringsFromJSON() else { return }
        
        let urlList = urlStringList.map({return NSURL(string:$0)!})
        
        var images = [ClusterImage]()
        for (idx,url) in urlList[0..<(GRID_SIZE)].enumerate() {
            NetworkManager.shared.getDataFrom(url) { data, response, error in
                guard let data = data where error == nil else { return }
                
                if let image = UIImage(data: data) {
                    let name = response?.suggestedFilename ?? url.lastPathComponent ?? "Downloaded file"

                    if name != "photo_unavailable.png" { // Image net bugs
                        print(name)
                        images.append(ClusterImage(image: image, id: idx))
                        print("\(100 * images.count / (self.GRID_SIZE))%")
                        let gridImageView = GridImageView(image: image,id:idx)
                        gridImageView.contentMode = .ScaleAspectFill
                        self.imageViews[idx] = gridImageView
                        gridImageView.frame = self.rectForTileAtIndex(idx)
                        self.view.addSubview(gridImageView)
                        gridImageView.alpha = 0
                        UIView.animateWithDuration(0.15, animations: {
                            gridImageView.alpha = 1
                        })
                    }
                }
                
                if images.count == self.GRID_SIZE {
                    self.modelController.recalculateCentroidsWith(images)
                    self.recalculateButton.enabled = true
                }
            }
        }
        
        
    }
    
    func urlStringsFromJSON() -> [String]? {
        if let filePath = NSBundle.mainBundle().pathForResource("easy", ofType: "json") {
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
    
    @IBAction func recalculateCentroids(sender: AnyObject) {
        modelController.recalculateCentroidsWith(nil)
    }
    
    
}

extension ViewController: kMeansMCDelegate {
    func drawClusters(clusters: [[ClusterImage]]) {
        
        UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.4, options: [], animations: {
            
            var pos = 0
            for cluster in clusters {
                for img in cluster {
                    let imageView = self.imageViews[img.id]!
                    imageView.frame = self.rectForTileAtIndex(pos)
                    pos += 1
                }
            }
        }, completion: nil)
        
    }
    
    func getGridDimensionsFor(nImages:Int) -> (Int,CGFloat) {
        let area = view.frame.width * view.frame.height / CGFloat(nImages)
        let maxSide = sqrt(area)
        let nTilesH = ceil(view.frame.width / maxSide)
        return (Int(nTilesH) , view.frame.width / nTilesH)
    }
    
    func rectForTileAtIndex(idx:Int) -> CGRect {
        return CGRect(x: CGFloat(idx%nColumns)*tileWidth, y: CGFloat(idx/nColumns)*tileWidth, width: tileWidth, height: tileWidth )
    }
    
}
