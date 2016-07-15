//
//  ColorVector.swift
//  AsyncImages
//
//  Created by Bernardo Santana on 7/14/16.
//  Copyright © 2016 Bernardo Santana. All rights reserved.
//

import Foundation

struct ColorVector {
    let l:Float
    let a:Float
    let b:Float
    init(l:Float,a:Float,b:Float) {
        self.l = l
        self.a = a
        self.b = b
    }
    
    init(color:UIColor) {
        var l:CGFloat=0.0,a:CGFloat=0.0,b:CGFloat=0.0,alpha:CGFloat=0.0
        color.getLightness(&l, a: &a, b: &b, alpha: &alpha)
        
        self.l = Float(l)
        self.a = Float(a)
        self.b = Float(b)
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
