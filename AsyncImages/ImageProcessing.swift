//
//  ImageProcessing.swift
//  AsyncImages
//
//  Created by Bernardo Santana on 7/15/16.
//  Copyright © 2016 Bernardo Santana. All rights reserved.
//
// Based on https://github.com/indragiek/DominantColor

import Foundation

extension UIImage {
    
    func averageCIELabColor() -> ColorVector {
        let width = CGImageGetWidth(self.CGImage)
        let height = CGImageGetHeight(self.CGImage)
        
        let context = createRGBAContext(, height: )
        return color
    }
    
    private func createRGBAContext(width: Int, height: Int) -> CGContext {
        return CGBitmapContextCreate(
            nil,
            width,
            height,
            8,          // bits per component
            width * 4,  // bytes per row
            CGColorSpaceCreateDeviceRGB(),
            CGBitmapInfo(rawValue: CGImageAlphaInfo.PremultipliedLast.rawValue).rawValue
            )!
    }

}

