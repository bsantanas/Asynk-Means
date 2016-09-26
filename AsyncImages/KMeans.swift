//
//  KMeans.swift
//  AsyncImages
//
//  Created by Bernardo Santana on 7/14/16.
//  Copyright © 2016 Bernardo Santana. All rights reserved.
//

import UIKit


// This delegate handles all the view rendering
protocol kMeansMCDelegate: class {
    func drawClusters(_ clusters:[[ClusterImage]])
}

/*********************** Main controller. All business logic ************************/

// MARK: - Model Controller

class kMeansModelController {
    
    // MARK: Public API
    
    var K: Int = 5 { didSet{ recalculateCentroids() }}
    var convergeDistance: Double = 0.1 { didSet{ recalculateCentroids() } }
    weak var delegate:kMeansMCDelegate?
    
    func recalculateCentroidsWith(_ newImages:[ClusterImage]?) {
        
        //Dispatch on background thread
        DispatchQueue.global().async {
            if newImages != nil { self.clusterObjects = newImages! }
            self.recalculateCentroids()
        }
        
    }
    
    func fit(image: ClusterImage) -> Int {
        // Todo
        return 0
    }
    
    init(k: Int) {
        self.K = k
    }
    
    
    // MARK: - Private
    
    private var clusterObjects = [ClusterImage]()
    private var centroids = [ColorVector]()
    private(set) var clusters:[[ClusterImage]] = [] // read-only
    
    
    
    private func recalculateCentroids() {
    
        guard clusterObjects.count >= K else { return }
        
        let samples = clusterObjects.map({ $0.colorAverage })
        let zeroVector = ColorVector()
        
        // Choose n random samples to be the initial centers
        var centers = randomNSamples(samples, n:K)
        var centerOffsetDistance:Double = 0
        
        repeat {
            
            // Assign points to closest centers
            var assignments = [[ColorVector]](repeating: [], count: K)
            for sample in samples {
                let idx = indexOfnearestCenter(sample, centers: centers)
                assignments[idx].append(sample)
            }
            
            // Recalculate center of the cluster
            var newCenters = [ColorVector]()
            for cluster in assignments {
                let center = cluster.reduce(zeroVector, + ) / cluster.count
                newCenters.append(center)
            }
            
            // Get error from previous set of clusters
            centerOffsetDistance = 0
            for (idx,center) in centers.enumerated() {
                centerOffsetDistance += Double(center.distanceTo(newCenters[idx]))
            }
            
            // Reset clusters
            centers = newCenters
            
        } while centerOffsetDistance > convergeDistance
        
        centroids = centers
        
        reorganizeImagesInClusters()
    }
    
    private func reorganizeImagesInClusters() {
        
        clusters = [[ClusterImage]](repeating: [], count: K)
        
        for image in clusterObjects {
            let i = indexOfnearestCenter(image.colorAverage, centers: centroids)
            clusters[i].append(image)
        }
        
        DispatchQueue.main.sync(execute: {
            self.delegate?.drawClusters(self.clusters)
        })
        
    }
    
    private func indexOfnearestCenter(_ x: ColorVector, centers: [ColorVector]) -> Int {
        var nearestDist = Float.infinity
        var minIndex = 0
        
        for (idx, center) in centers.enumerated() {
            let dist = x.distanceTo(center)
            if dist < nearestDist {
                minIndex = idx
                nearestDist = dist
            }
        }
        return minIndex
    }
    
}

/******************************** Model Class *******************************/
// MARK: - Model Class

// Convienence class to handle images
class ClusterImage {
    
    let colorAverage:ColorVector
    let id:Int
    
    init(image:UIImage, id: Int) {
        self.id = id
        self.colorAverage = image.averageCIELabColor()
    }
    
}


/***************************** Convenience methods *******************************/

// Pick n random elements from samples
func randomNSamples<T>(_ samples: [T], n: Int) -> [T] {
    var result = [T]()
    var indexes = [Int]()
    while result.count < n {
        let index = Int(arc4random_uniform(UInt32(samples.count)))
        guard !indexes.contains(index) else { continue }
        
        indexes.append(index)
        result.append(samples[index])
    }
    return result
}
