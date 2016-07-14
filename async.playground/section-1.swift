import UIKit
import XCPlayground

let GRID_SIZE = 10
var imageList:[UIImage] = []

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

func getImageURLList() -> [String]? {
    let filePath = NSBundle.mainBundle().pathForResource("images", ofType: "json")
    if let data = NSFileManager.defaultManager().contentsAtPath(filePath!) {
        do {
            let imageURLList = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as! [String]
            return imageURLList
        } catch let error as NSError {
            print("Error serializing JSON file \(error)")
        }
    }
    return nil
}

let imageURLList = getImageURLList()

func randomURLString() -> String {
    let limit = imageURLList!.count
    let randomIndex = Int(arc4random()) % limit
    return imageURLList![randomIndex]
}

extension UIImageView {
    func downloadedFrom(link: String, contentMode mode: UIViewContentMode = .ScaleAspectFit) {
        guard let url = NSURL(string: link) else { return }
        contentMode = mode
        let defaultSession = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
        defaultSession.dataTaskWithURL(url) { (data, response, error) in
            guard
                let httpURLResponse = response as? NSHTTPURLResponse where httpURLResponse.statusCode == 200,
                let data = data where error == nil,
                let image = UIImage(data: data)
                else { return }
            dispatch_async(dispatch_get_main_queue(), {
                self.image = image
            })
            }.resume()
    }
}


let url = randomURLString()
let image = UIImageView().downloadedFrom(url)

//var data = NSData(contentsOfURL:randomURL())
//var retrys = 0



//for i in 0..<GRID_SIZE{
//        UIImage(data: <#T##NSData#>)
////    while data == nil && retrys < 4 {
////        data = NSData(contentsOfURL:randomURL())
////        retrys += 1
////    }
//    print(data)
//}
