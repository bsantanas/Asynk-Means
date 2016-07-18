//
//  NetworkManager.swift
//  AsyncImages
//
//  Created by Bernardo Santana on 7/15/16.
//  Copyright © 2016 Bernardo Santana. All rights reserved.
//

import UIKit

class NetworkManager {
    static let shared = NetworkManager()
    
    func getDataFrom(url: NSURL, completion: ((data: NSData?, response: NSURLResponse?, error: NSError? ) -> Void)) {
        NSURLSession.sharedSession().dataTaskWithURL(url) {
            (data, response, error) in
            dispatch_sync(dispatch_get_main_queue(), {
                completion(data: data, response: response, error: error)
            })
            }.resume()
    }

}


