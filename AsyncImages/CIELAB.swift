//
//  CIELAB.swift
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
        let l,a,b,alpha:CGFloat
        color.getLightness(&l, a: &a, b: &b, alpha: &alpha)
        
        self.l = Float(l)
        self.a = Float(a)
        self.b = Float(b)
    }
}

