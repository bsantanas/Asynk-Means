//
//  ColorVector.swift
//  AsyncImages
//
//  Created by Bernardo Santana on 7/14/16.
//  Copyright © 2016 Bernardo Santana. All rights reserved.
//

import UIKit

struct ColorVector {
    let l:Float
    let a:Float
    let b:Float
    init(l:Float=0,a:Float=0,b:Float=0) {
        self.l = l
        self.a = a
        self.b = b
    }
    
    /**
     Delta E (CIE 1994): Distance between two lightness values. More info at http://www.brucelindbloom.com/index.html?Eqn_DeltaE_CIE94.html
    */
    func distanceTo(vector:ColorVector) -> Float {
        let kL: Float = 1
        let kC: Float = 1
        let kH: Float = 1
        let K1: Float = 0.045
        let K2: Float = 0.015
        
        let ΔL = self.l - vector.l
        
        // Extracting Vectors
        let C1 = sqrt(pow(self.a, 2) + pow(self.b, 2))
        let C2 = sqrt(pow(vector.a, 2) + pow(vector.b, 2))
        let ΔC = C1 - C2
        
        let ΔH = sqrt(pow(self.a - vector.a, 2) + pow(self.b - vector.b, 2) - pow(ΔC, 2))
        
        let Sl: Float = 1
        let Sc = 1 + K1 * C1
        let Sh = 1 + K2 * C1
        
        return pow(ΔL / (kL * Sl), 2) + pow(ΔC / (kC * Sc), 2) + pow(ΔH / (kH * Sh), 2)
    }
    
    static func zero() -> ColorVector {
        return ColorVector(l: 0, a: 0, b: 0)
    }
 
}

func +(lhs: ColorVector, rhs: ColorVector) -> ColorVector {
    return ColorVector(l: lhs.l + rhs.l, a: lhs.a + rhs.a, b: lhs.b + rhs.b)
}

func /(lhs: ColorVector, rhs: Float) -> ColorVector {
    return ColorVector(l: lhs.l/rhs, a: lhs.a/rhs, b: lhs.b/rhs)
}

func /(lhs: ColorVector, rhs: Int) -> ColorVector {
    return lhs / Float(rhs)
}
