//
//  NetAPIManager.swift
//  LeLocationTracker
//
//  Created by Oleh Zayats on 6/10/15.
//  Copyright (c) 2015 Oleh Zayats. All rights reserved.
//

import Foundation
import UIKit

typealias Response = (JSON, NSError?) -> Void

class RestAPIManager: NSObject {
    
    static let sharedInstance = RestAPIManager()
    static let url = NSURL(string:"http://track-my-location.herokuapp.com/")
    //static let deviceID = NSUUID().UUIDString
    
    static let deviceID = UIDevice.currentDevice().modelName
    
    func sendDeviceTrackedData(locations: NSArray!, onCompletion: Response) {
        
        var modifLocations: NSMutableArray = NSMutableArray()
        for var i = 0; i < locations.count; i++ {
            let loc: Location = locations.objectAtIndex(i) as! Location
            var locationDict = loc.locationToDictionary()
            modifLocations.addObject(locationDict as NSDictionary)
        }
        var postRequestData = ["device_id":RestAPIManager.deviceID, "track":modifLocations]
        
        let urlPost = NSURL(string:"http://track-my-location.herokuapp.com/track/add")
        let request = NSMutableURLRequest(URL:urlPost!)
        var session = NSURLSession.sharedSession()
        request.HTTPMethod = "POST"
        
        var err: NSError?
        var data: NSData = NSJSONSerialization.dataWithJSONObject(postRequestData, options: nil, error: &err)!
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        var length = NSString(format: "%d", data.length) as String
        request.setValue(length, forHTTPHeaderField: "Content-Length")
        request.setValue("json", forHTTPHeaderField: "Data-Type")
        
        request.HTTPBody = data
        
        let task = session.dataTaskWithRequest(request, completionHandler: {
            data, response, error -> Void in
            let json:JSON = JSON(data: data)
            onCompletion(json, err)
        })
        task.resume()
    }
}

private let DeviceList = [
    /* iPod 5 */          "iPod5,1": "iPod Touch 5",
    /* iPhone 4 */        "iPhone3,1":  "iPhone 4", "iPhone3,2": "iPhone 4", "iPhone3,3": "iPhone 4",
    /* iPhone 4S */       "iPhone4,1": "iPhone 4S",
    /* iPhone 5 */        "iPhone5,1": "iPhone 5", "iPhone5,2": "iPhone 5",
    /* iPhone 5C */       "iPhone5,3": "iPhone 5C", "iPhone5,4": "iPhone 5C",
    /* iPhone 5S */       "iPhone6,1": "iPhone 5S", "iPhone6,2": "iPhone 5S",
    /* iPhone 6 */        "iPhone7,2": "iPhone 6",
    /* iPhone 6 Plus */   "iPhone7,1": "iPhone 6 Plus",
    /* iPad 2 */          "iPad2,1": "iPad 2", "iPad2,2": "iPad 2", "iPad2,3": "iPad 2", "iPad2,4": "iPad 2",
    /* iPad 3 */          "iPad3,1": "iPad 3", "iPad3,2": "iPad 3", "iPad3,3": "iPad 3",
    /* iPad 4 */          "iPad3,4": "iPad 4", "iPad3,5": "iPad 4", "iPad3,6": "iPad 4",
    /* iPad Air */        "iPad4,1": "iPad Air", "iPad4,2": "iPad Air", "iPad4,3": "iPad Air",
    /* iPad Air 2 */      "iPad5,1": "iPad Air 2", "iPad5,3": "iPad Air 2", "iPad5,4": "iPad Air 2",
    /* iPad Mini */       "iPad2,5": "iPad Mini", "iPad2,6": "iPad Mini", "iPad2,7": "iPad Mini",
    /* iPad Mini 2 */     "iPad4,4": "iPad Mini", "iPad4,5": "iPad Mini", "iPad4,6": "iPad Mini",
    /* iPad Mini 3 */     "iPad4,7": "iPad Mini", "iPad4,8": "iPad Mini", "iPad4,9": "iPad Mini",
    /* Simulator */       "x86_64": "Simulator", "i386": "Simulator"
]

extension UIDevice {
    
    var modelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        
        let machine = systemInfo.machine
        let mirror = reflect(machine)
        var identifier = ""
        
        for i in 0..<mirror.count {
            if let value = mirror[i].1.value as? Int8 where value != 0 {
                identifier.append(UnicodeScalar(UInt8(value)))
            }
        }
        return DeviceList[identifier] ?? identifier
    }
    
}


