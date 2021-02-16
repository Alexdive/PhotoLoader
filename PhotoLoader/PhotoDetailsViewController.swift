//
//  PhotoDetailsViewController.swift
//  PhotoLoader
//
//  Created by Alex Permiakov on 2/5/21.
//

import UIKit

class PhotoDetailsViewController: UIViewController {
    
    lazy var imageView = CustomImageView()
    
    var imageUrlString: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        imageView.contentMode = .scaleAspectFit
        
        view.addSubview(imageView)
        imageView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        if let imageUrlString = self.imageUrlString {
            self.imageView.loadImageUsingUrlString(urlString: imageUrlString) {
                print("Loaded")
            }
        }
    }
}
