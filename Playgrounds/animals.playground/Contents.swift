//
//  animals.playground
//  iOS Networking
//
//  Created by Jarrod Parkes on 09/30/15.
//  Copyright (c) 2015 Udacity. All rights reserved.
//

import Foundation
import UIKit

/* Path for JSON files bundled with the Playground */
var pathForAnimalsJSON = NSBundle.mainBundle().pathForResource("animals", ofType: "json")

/* Raw JSON data (...simliar to the format you might receive from the network) */
var rawAnimalsJSON = NSData(contentsOfFile: pathForAnimalsJSON!)

/* Error object */
var parsingAnimalsError: NSError? = nil

/* Parse the data into usable form */
var parsedAnimalsJSON = try! NSJSONSerialization.JSONObjectWithData(rawAnimalsJSON!, options: .AllowFragments) as! NSDictionary

func parseJSONAsDictionary(dictionary: NSDictionary) {
    /* Start playing with JSON here... */
	print(dictionary)
	
	guard let photosDictionary = dictionary["photos"] else {
		print("Could not find photos dictionary")
		return
	}
	
	guard let photoArray = photosDictionary["photo"] as? [[String: AnyObject]] else {
		return
	}
	
	if let totalPhotos = photosDictionary["total"] as? Int {
		print(totalPhotos)
	}
	
	for (index, photo) in photoArray.enumerate() {
		guard let commentDictionary = photo["comment"] as? [String: AnyObject] else {
			return
		}
		guard let commentContent = commentDictionary["_content"] as? String else {
			return
		}
		if commentContent.containsString("interrufftion") {
			print(index)
		}
	}
	
	if let thirdPhotoDictionary = photoArray[2] as? [String: AnyObject] {
		guard let imageUrlString = thirdPhotoDictionary["url_m"] as? String else {
			return
		}
		print(imageUrlString)
	}
	
}

parseJSONAsDictionary(parsedAnimalsJSON)
