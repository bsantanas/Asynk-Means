//
//  ImageProcessing.swift
//  AsyncImages
//
//  Created by Bernardo Santana on 7/15/16.
//  Copyright © 2016 Bernardo Santana. All rights reserved.
//
// Based on https://github.com/indragiek/DominantColor

import UIKit

let REFX_O2_D65:Float = 95.047
let REFY_O2_D65:Float = 100
let REFZ_O2_D65:Float = 108.883

extension UIImage {
    
    func averageCIELabColor() -> ColorVector {
        let width = CGImageGetWidth(self.CGImage)
        let height = CGImageGetHeight(self.CGImage)
        
        let context = createRGBAContext(width, height: height)
        CGContextDrawImage(context, CGRect(x: 0, y: 0, width: width, height:height), self.CGImage)
        
        // Get the RGB colors from the bitmap context, ignoring any pixels
        // that have alpha transparency.
        // Also convert the colors to the LAB color space
        var labValues = [ColorVector]()
        labValues.reserveCapacity(Int(width * height))
        
        let RGBToLAB: RGBAPixel -> ColorVector = {
            return $0.toColorVector()
        }
        
        enumerateRGBAContext(context) { (_, _, pixel) in
            if pixel.a == UInt8.max {
                labValues.append(RGBToLAB(pixel))
            }
        }

        let color = labValues.reduce(ColorVector(), combine: +) / (width * height)
        
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
    
    /** Enumerates over all of the pixels in an RGBA bitmap context in the order that they are stored in memory, for faster access.
 
     From: https://www.mikeash.com/pyblog/friday-qa-2012-08-31-obtaining-and-interpreting-image-data.html
     */ 
    private func enumerateRGBAContext(context: CGContext, handler: (Int, Int, RGBAPixel) -> Void) {
        let (width, height) = (CGBitmapContextGetWidth(context), CGBitmapContextGetHeight(context))
        let data = unsafeBitCast(CGBitmapContextGetData(context), UnsafeMutablePointer<RGBAPixel>.self)
        for y in 0..<height {
            for x in 0..<width {
                handler(x, y, data[Int(x + y * width)])
            }
        }
    }
    

}

struct RGBAPixel {
    let r: UInt8
    let g: UInt8
    let b: UInt8
    let a: UInt8
    
    func toColorVector() -> ColorVector {
        let (x,y,z) = rgbToXYZ(Float(self.r)/Float(UINT8_MAX), green: Float(self.r)/Float(UINT8_MAX), blue: Float(self.r)/Float(UINT8_MAX))
        let (l,a,b) = xyzToLab(x, Y: y, Z: z)
        return ColorVector(l: l, a: a, b: b)
        
    }
}

//MARK: Color Conversions

/** RGB->XYZ->LAB
 
 From: https://github.com/thisandagain/color
 */

func rgbToXYZ(red:Float,green:Float, blue:Float) ->  (x:Float,y:Float, z:Float) {
    var x,y,z:Float
    var r = red, g = green, b = blue
    if(r > 0.04045) { r = pow(((r + 0.055) / 1.055),2.4); }
    else { r = r / 12.92; }
    if(g > 0.04045) { g = pow(((g + 0.055) / 1.055),2.4); }
    else { g = g / 12.92; }
    if(b > 0.04045) { b = pow(((b + 0.055) / 1.055),2.4); }
    else { b = b / 12.92; }
    
    r *= 100.0;
    g *= 100.0;
    b *= 100.0;
    
    x = (r * 0.4124) + (g * 0.3576) + (b * 0.1805);
    y = (r * 0.2126) + (g * 0.7152) + (b * 0.0722);
    z = (r * 0.0193) + (g * 0.1192) + (b * 0.9505);
    
    return (x,y,z)
}

func xyzToLab(X:Float,Y:Float, Z:Float) ->  (l:Float,a:Float,b:Float) {
    var l,a,b: Float
    var x = X, y = Y, z = Z
    x /= REFX_O2_D65;
    y /= REFY_O2_D65;
    z /= REFZ_O2_D65;
    
    if(x > 0.008856) { x = pow(x, 1.0/3.0);} else {x = (7.787 * x) + (16.0/116.0);}
    if(y > 0.008856) { y = pow(y, 1.0/3.0);} else {y = (7.787 * y) + (16.0/116.0);}
    if(z > 0.008856) { z = pow(z, 1.0/3.0);} else {z = (7.787 * z) + (16.0/116.0);}
    
    l = (116.0 * y) - 16.0;
    a = 500.0 * (x - y);
    b = 200.0 * (y - z);
    
    return (l,a,b)
}

func memo<T: Hashable, U>(f: T -> U) -> T -> U {
    var cache = [T : U]()
    
    return { key in
        var value = cache[key]
        if value == nil {
            value = f(key)
            cache[key] = value
        }
        return value!
    }
}


