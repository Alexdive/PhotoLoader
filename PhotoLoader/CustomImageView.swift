//
//  CustomImageView.swift
//  PhotoLoader
//
//  Created by Alex Permiakov on 1/28/21.
//

import UIKit

let imageCache = NSCache<NSString, UIImage>()

class CustomImageView: UIImageView {
    
    var imageUrlString: String?
    
    func loadImageUsingUrlString(urlString: String, completion: @escaping () -> ()) {
        
        imageUrlString = urlString
        
        guard let url = URL(string: urlString) else { return }
        
        image = nil
        
        if let imageFromCache = imageCache.object(forKey: urlString as NSString) { 
            self.image = imageFromCache
            completion()
            return
        }
        
        URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
            
            if error != nil {
                print(error ?? "")
                return
            }
            
            DispatchQueue.main.async { [weak self] in
                guard let imageToCache = UIImage(data: data!) else { return }
                guard let self = self else { return }
                if self.imageUrlString == urlString {
                    self.image = imageToCache
                    completion()
                }
                imageCache.setObject(imageToCache, forKey: urlString as NSString)
            }
        }).resume()
    }
}

