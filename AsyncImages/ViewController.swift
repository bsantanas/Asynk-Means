//
//  ViewController.swift
//  AsyncImages
//
//  Created by Bernardo Santana on 7/13/16.
//  Copyright © 2016 Bernardo Santana. All rights reserved.
//

import UIKit
import Alamofire

class ViewController: UIViewController {
    
    @IBOutlet weak var recalculateButton:UIBarButtonItem!
    
    let GRID_SIZE = 15
    var nColumns:Int = 0
    var tileWidth:CGFloat = 0
    let modelController = kMeansModelController(k: 3)
    var imageViews = [Int:UIImageView]()
    let group = DispatchGroup()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        modelController.delegate = self
        downloadImages()
    }
    
    override func viewWillLayoutSubviews() {
        (nColumns,tileWidth) = getGridDimensionsFor(GRID_SIZE)
        resetGridImages()
        super.viewWillLayoutSubviews()
    }
    
    // MARK: - IBActions
    
    @IBAction func recalculateCentroids(_ sender: AnyObject) {
        modelController.getCentroids()
    }
    
    // MARK: - Instance methods
    
    func downloadImages() {
        
        var urlList = urlStringsFromJSON(name:Files.easy).shuffled()
        
        for (idx,url) in urlList[0..<(GRID_SIZE)].enumerated() {
            group.enter()
            Alamofire.request(url).validate().responseData { response in
                
                switch response.result {
                case .success:
                    if let data = response.result.value {
                        self.createImageWith(data: data, atIndex: idx)
                    } else {
                        print("Error no data received from \(url)")
                    }
                case .failure(let error):
                    print("Error downloading image from \(url)",error)
                }
            }
        }
        
        group.notify(queue: DispatchQueue.main, execute: {
            self.modelController.getCentroids()
            self.recalculateButton.isEnabled = true
        })
    }
    
    
    func createImageWith(data:Data, atIndex index: Int) {
        
        guard let image = UIImage(data: data) else {
            print("Not image data at idx \(index)")
            return
        }
        
        DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async {
            self.modelController.add(image: image, withID: index)
            DispatchQueue.main.async {
                if self.imageViews[index] == nil {
                    let gridImageView = UIImageView(image: image)
                    gridImageView.clipsToBounds = true
                    gridImageView.contentMode = .scaleAspectFill
                    self.imageViews[index] = gridImageView
                    gridImageView.frame = self.rectForTileAtIndex(index)
                    self.view.addSubview(gridImageView)
                    gridImageView.alpha = 0
                    UIView.animate(withDuration: 0.15, animations: {
                        gridImageView.alpha = 1
                    })
                }
                self.group.leave()
            }
        }
    }
    
    
    func urlStringsFromJSON(name:Filename) -> [String] {
        if let filePath = Bundle.main.path(forResource: name, ofType: Files.FileType.json) {
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
        
        return []
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
    
    func resetGridImages() {
        for i in 0...GRID_SIZE {
            if let imageView = self.imageViews[i] {
                imageView.frame = self.rectForTileAtIndex(i)
            }
        }

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
