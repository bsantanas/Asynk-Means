//
//  GridImageView.swift
//  AsyncImages
//
//  Created by Bernardo Santana on 7/16/16.
//  Copyright © 2016 Bernardo Santana. All rights reserved.
//

import UIKit

class GridImageView: UIImageView {
    
    let id:Int
    
    init(image: UIImage?, id: Int) {
        self.id = id
        super.init(image: image)
        self.clipsToBounds = true
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
