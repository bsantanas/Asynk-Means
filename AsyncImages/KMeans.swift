//
//  KMeans.swift
//  AsyncImages
//
//  Created by Bernardo Santana on 7/14/16.
//  Copyright © 2016 Bernardo Santana. All rights reserved.
//

import Foundation

class kMeansModelController {

    let K = 3
    
    // Drawing Delegate
    weak var delegate:kMeansMCDelegate?
    
    // Clusters
    var clusters:[[ClusterImage]] = [] {
        didSet {
            delegate!.drawClusters(clusters)
        }
    }
    
    
    func getClusters() {
        let imageList:[UIImage] = [] //getListOfImages()
        guard imageList.count > 0 else { print("An error ocurred"); return }
        
        let imageObjects:[ClusterImage] = imageList.map({ image in return ClusterImage(image: image) })
        
        
        
    }

    
    // Pick k random elements from samples
    func reservoirSample<T>(samples: [T], k: Int) -> [T] {
        var result = [T]()
        
        // Fill the result array with first k elements
        for i in 0..<k {
            result.append(samples[i])
        }
        
        // Randomly replace elements from remaining pool
        for i in k..<samples.count {
            let j = Int(arc4random_uniform(UInt32(i + 1)))
            if j < k {
                result[j] = samples[i]
            }
        }
        return result
    }
}

protocol kMeansMCDelegate: class {
    func drawClusters(clusters:[[ClusterImage]])
}

class ClusterImage {
    let image:UIImage
    let cielab:Float
    
    init(image:UIImage) {
        self.image = image
        self.cielab = image.getCielabAverage()
    }
    
}

extension UIImage {
    func getCielabAverage() -> Float {
        return 0
    }
}

class KMeans {
    
    let K: Int
    private var centroids = [Float]()
    
    init(k: Int) {
        self.K = k
    }
    
    private func indexOfnearestCenter(x: Vector, centers: []) -> Int {
        var nearestDist = DBL_MAX
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
    
    func trainCenters(points: [Vector], convergeDistance: Double) {
        let zeroVector = Vector([Double](count: points[0].length, repeatedValue: 0))
        
        // Randomly take k objects from the input data to make the initial centroids.
        var centers = reservoirSample(points, k: numCenters)
        
        var centerMoveDist = 0.0
        repeat {
            // This array keeps track of which data points belong to which centroids.
            var classification: [[Vector]] = .init(count: numCenters, repeatedValue: [])
            
            // For each data point, find the centroid that it is closest to.
            for p in points {
                let classIndex = indexOfNearestCenter(p, centers: centers)
                classification[classIndex].append(p)
            }
            
            // Take the average of all the data points that belong to each centroid.
            // This moves the centroid to a new position.
            let newCenters = classification.map { assignedPoints in
                assignedPoints.reduce(zeroVector, combine: +) / Double(assignedPoints.count)
            }
            
            // Find out how far each centroid moved since the last iteration. If it's
            // only a small distance, then we're done.
            centerMoveDist = 0.0
            for idx in 0..<numCenters {
                centerMoveDist += centers[idx].distanceTo(newCenters[idx])
            }
            
            centers = newCenters
        } while centerMoveDist > convergeDistance
        
        centroids = centers
    }
    
    func fit(point: Vector) -> Label {
        assert(!centroids.isEmpty, "Exception: KMeans tried to fit on a non trained model.")
        
        let centroidIndex = indexOfNearestCenter(point, centers: centroids)
        return labels[centroidIndex]
    }
    
    func fit(points: [Vector]) -> [Label] {
        assert(!centroids.isEmpty, "Exception: KMeans tried to fit on a non trained model.")
        
        return points.map(fit)
    }
}



