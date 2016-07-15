//
//  KMeans.swift
//  AsyncImages
//
//  Created by Bernardo Santana on 7/14/16.
//  Copyright © 2016 Bernardo Santana. All rights reserved.
//

import Foundation

class kMeansModelController {

    let K: Int
    private var centroids = [ColorVector]()
    
    init(k: Int) {
        self.K = k
    }
    
    // Delegate Handles All View rendering
    weak var delegate:kMeansMCDelegate?
    
    // Clusters
    var clusters:[[AveragedImage]] = [] {
        didSet {
            delegate!.drawClusters(clusters)
        }
    }
    
    
    func getClusters() {
        let imageList:[UIImage] = [] //getListOfImages()
        guard imageList.count > 0 else { print("An error ocurred"); return }
        
        let imageObjects:[AveragedImage] = imageList.map({ image in return AveragedImage(image: image) })
 
        
    }
    
    
    func trainModel(samples: [ColorVector], convergeDistance: Double) {
        let zeroVector = ColorVector(l: 0, a: 0, b: 0)
        
        // Choose n random samples to be the initial centers
        var centers = randomNSamples(samples, n:K)
        var centerOffsetDistance:Double = 0.0
        
        repeat {
            var assignments = [[ColorVector]](count: K, repeatedValue: [])
            
            for sample in samples {
                let idx = indexOfnearestCenter(sample, centers: centers)
                assignments[idx].append(sample)
            }
            
            var newCenters = [ColorVector]()
            for cluster in assignments {
                let center = cluster.reduce(zeroVector, combine: + ) / cluster.count
                newCenters.append(center)
            }
            
            for (idx,center) in centers.enumerate() {
                centerOffsetDistance += Double(abs(center.distanceTo(newCenters[idx])))
            }
            
            centers = newCenters
            
        } while centerOffsetDistance > convergeDistance
        
        centroids = centers
    }
    
    private func indexOfnearestCenter(x: ColorVector, centers: [ColorVector]) -> Int {
        var nearestDist = FLT_MAX
        var minIndex = 0
        
        for (idx, center) in centers.enumerate() {
            let dist = x.distanceTo(center)
            if dist < nearestDist {
                minIndex = idx
                nearestDist = dist
            }
        }
        return minIndex
    }
    
    // TODO 
    // func fit(vector: ColorVector) -> Int
    
    // Pick n random elements from samples
    func randomNSamples<T>(samples: [T], n: Int) -> [T] {
        var result = [T]()
        var indexes = [Int]()
        while result.count < n {
            let index = Int(arc4random_uniform(UInt32(samples.count)))
            guard indexes.contains(index) else { continue }
            
            indexes.append(index)
            result.append(samples[index])
        }
        return result
    }

    
}

protocol kMeansMCDelegate: class {
    func drawClusters(clusters:[[AveragedImage]])
}

class AveragedImage {
    let image:UIImage
    let colorAverage:Float
    
    init(image:UIImage) {
        self.image = image
        self.colorAverage = image.getCielabAverage()
    }
    
}

extension UIImage {
    func getCielabAverage() -> Float {
        
        return 0
    }
    
    
}



