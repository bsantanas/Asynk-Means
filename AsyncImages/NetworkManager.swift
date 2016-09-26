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
    
    func getDataFrom(_ url: URL, completion: @escaping  (_ d: Data?, _ r: URLResponse?, _ e: NSError? ) -> Void) {
        
        let request = URLRequest(url:url)
        let task = URLSession.shared.dataTask(with: request as URLRequest) { (data,response,error) in
            DispatchQueue.main.sync(execute: {
                //completion(data, response, error)
            })
        }
        task.resume()
    }

}


