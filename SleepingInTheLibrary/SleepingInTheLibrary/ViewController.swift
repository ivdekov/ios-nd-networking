//
//  ViewController.swift
//  SleepingInTheLibrary
//
//  Created by Jarrod Parkes on 11/3/15.
//  Copyright © 2015 Udacity. All rights reserved.
//

import UIKit

// MARK: - ViewController: UIViewController

class ViewController: UIViewController {

    // MARK: Outlets
    
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var photoTitleLabel: UILabel!
    @IBOutlet weak var grabImageButton: UIButton!
    
    // MARK: Actions
    
    @IBAction func grabNewImage(sender: AnyObject) {
        setUIEnabled(false)
        getImageFromFlickr()
    }
    
    // MARK: Configure UI
    
    private func setUIEnabled(enabled: Bool) {
        photoTitleLabel.enabled = enabled
        grabImageButton.enabled = enabled
        
        if enabled {
            grabImageButton.alpha = 1.0
        } else {
            grabImageButton.alpha = 0.5
        }
    }
    
    // MARK: Make Network Request
    
    private func getImageFromFlickr() {
        
        let methodParameters = [
            Constants.FlickrParameterKeys.Method: Constants.FlickrParameterValues.GalleryPhotosMethod,
            Constants.FlickrParameterKeys.APIKey: Constants.FlickrParameterValues.APIKey,
            Constants.FlickrParameterKeys.GalleryID: Constants.FlickrParameterValues.GalleryID,
            Constants.FlickrParameterKeys.Extras: Constants.FlickrParameterValues.MediumURL,
            Constants.FlickrParameterKeys.Format: Constants.FlickrParameterValues.ResponseFormat,
            Constants.FlickrParameterKeys.NoJSONCallback: Constants.FlickrParameterValues.DisableJSONCallback
        ]
        
        let session = NSURLSession.sharedSession()
        let urlString = Constants.Flickr.APIBaseURL + escapedParameters(methodParameters)
        let url = NSURL(string: urlString)!
        let request = NSURLRequest(URL: url)
        
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
			
			func displayError(error: String) {
				print(error)
				print("URL at time of error: \(url)")
				performUIUpdatesOnMain {
					self.setUIEnabled(true)
				}
			}
			
			guard (error == nil) else {
				displayError("There was an error with your request: \(error)")
				return
			}
			
			guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
				displayError("Your request returned a status code other than 2xx!")
				return
			}
			
			guard let data = data else {
				displayError("No data was returned by the request!")
				return
			}
			
			// parse the data
			
			let parsedResult: AnyObject!
			do {
				parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
			} catch {
				print("Could not parse the data as JSON: '\(data)'")
				return
			}
				
			guard let stat = parsedResult[Constants.FlickrResponseKeys.Status] as? String where stat == Constants.FlickrResponseValues.OKStatus else {
				displayError("Flickr API returned an error. See error code and message in \(parsedResult)")
				return
			}
			
			guard let photosDictionary = parsedResult[Constants.FlickrResponseKeys.Photos] as? [String: AnyObject], photoArray = photosDictionary["photo"] as? [[String: AnyObject]] else {
				
				displayError("Cannot find keys '\(Constants.FlickrResponseKeys.Photos)' and '\(Constants.FlickrResponseKeys.Photo)' in \(parsedResult)")
				return
			}
			
			let randomPhotoIndex = Int(arc4random_uniform(UInt32(photoArray.count)))
			let photoDictionary = photoArray[randomPhotoIndex] as [String: AnyObject]
			let photoTitle = photoDictionary[Constants.FlickrResponseKeys.Title] as? String
			
			guard let imageUrlString = photoDictionary[Constants.FlickrResponseKeys.MediumURL] as? String else {
				displayError("Cannot find key '\(Constants.FlickrResponseKeys.MediumURL)' in \(photoDictionary)")
				return
			}
			let imageUrl = NSURL(string: imageUrlString)!
			if let imageData = NSData(contentsOfURL: imageUrl) {
				performUIUpdatesOnMain {
					self.photoImageView.image = UIImage(data: imageData)
					self.photoTitleLabel.text = photoTitle
					self.setUIEnabled(true)
				}
			}
			
		}
        task.resume()
    }
	
    // MARK: Helper for Escaping Parameters in URL
    
    private func escapedParameters(parameters: [String:AnyObject]) -> String {
        
        if parameters.isEmpty {
            return ""
        } else {
            var keyValuePairs = [String]()
            
            for (key, value) in parameters {
                
                // make sure that it is a string value
                let stringValue = "\(value)"
                
                // escape it
                let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
                
                // append it
                keyValuePairs.append(key + "=" + "\(escapedValue!)")
                
            }
            
            return "?\(keyValuePairs.joinWithSeparator("&"))"
        }
    }
}