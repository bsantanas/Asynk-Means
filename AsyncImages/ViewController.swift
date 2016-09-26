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
        
        var urlList = urlStringList.map({return URL(string:$0)!}).shuffled()
        
        var images = [ClusterImage]()
        for (idx,url) in urlList[0..<(GRID_SIZE)].enumerated() {
            let request = URLRequest(url:url)
            let task = URLSession.shared.dataTask(with: request as URLRequest) { (data,response,error) in

                guard let data = data, error == nil else { return }
                
                if let image = UIImage(data: data) {
                    
                    DispatchQueue.main.async {
                        
                        let name = response?.suggestedFilename ?? url.lastPathComponent
                        
                        if name != "photo_unavailable.png" { // Image net bugs
                            print(name)
                            images.append(ClusterImage(image: image, id: idx))
                            print("\(100 * images.count / (self.GRID_SIZE))%")
                            let gridImageView = GridImageView(image: image,id:idx)
                            gridImageView.contentMode = .scaleAspectFill
                            self.imageViews[idx] = gridImageView
                            gridImageView.frame = self.rectForTileAtIndex(idx)
                            self.view.addSubview(gridImageView)
                            gridImageView.alpha = 0
                            UIView.animate(withDuration: 0.15, animations: {
                                gridImageView.alpha = 1
                            })
                        }
                        
                        if images.count == self.GRID_SIZE {
                            self.modelController.recalculateCentroidsWith(images)
                            self.recalculateButton.isEnabled = true
                        }
                    }
                }
            }
            task.resume()
        }
        
        
    }
    
    func urlStringsFromJSON() -> [String]? {
        if let filePath = Bundle.main.path(forResource: "easy", ofType: "json") {
            let data = FileManager.default.contents(atPath: filePath)
            do {
                let imageURLList = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String]
                return imageURLList
            } catch let error as NSError {
                print("Error serializing JSON file \(error)")
            }
        } else {
            print("Error loading JSON file, is it in the project directory?")
        }
        
        return nil
    }
    
    @IBAction func recalculateCentroids(_ sender: AnyObject) {
        modelController.recalculateCentroidsWith(nil)
    }
    
    
}

extension ViewController: kMeansMCDelegate {
    func drawClusters(_ clusters: [[ClusterImage]]) {
        
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.4, options: [], animations: {
            
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
    
    func getGridDimensionsFor(_ nImages:Int) -> (Int,CGFloat) {
        let area = view.frame.width * view.frame.height / CGFloat(nImages)
        let maxSide = sqrt(area)
        let nTilesH = ceil(view.frame.width / maxSide)
        return (Int(nTilesH) , view.frame.width / nTilesH)
    }
    
    func rectForTileAtIndex(_ idx:Int) -> CGRect {
        return CGRect(x: CGFloat(idx%nColumns)*tileWidth, y: CGFloat(idx/nColumns)*tileWidth, width: tileWidth, height: tileWidth )
    }
    
}

extension MutableCollection where Indices.Iterator.Element == Index {
    /// Shuffles the contents of this collection.
    mutating func shuffle() {
        let c = count
        guard c > 1 else { return }
        
        for (unshuffledCount, firstUnshuffled) in zip(stride(from: c, to: 1, by: -1), indices) {
            let d: IndexDistance = numericCast(arc4random_uniform(numericCast(unshuffledCount)))
            guard d != 0 else { continue }
            let i = index(firstUnshuffled, offsetBy: d)
            swap(&self[firstUnshuffled], &self[i])
        }
    }
}

extension Sequence {
    /// Returns an array with the contents of this sequence, shuffled.
    func shuffled() -> [Iterator.Element] {
        var result = Array(self)
        result.shuffle()
        return result
    }
}
