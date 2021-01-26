//
//  ViewController.swift
//  PhotoLoader
//
//  Created by Alex Permiakov on 1/22/21.
//

import UIKit
import SwiftyJSON
import SnapKit

class ViewController: UIViewController {
    
    lazy var photoCV: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8
        let cv = UICollectionView(frame: view.safeAreaLayoutGuide.layoutFrame, collectionViewLayout: layout)
        cv.register(PhotoCollectionViewCell.self, forCellWithReuseIdentifier: PhotoCollectionViewCell.id)
        cv.backgroundColor = .darkGray
        cv.delegate = self
        cv.dataSource = self
        return cv
    }()
    
    lazy var activityIndicator: UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.large)
        ai.color = .black
        ai.startAnimating()
        return ai
    }()
    
    var images: [AnyObject] = [] {
        didSet {
            DispatchQueue.main.async {
                self.photoCV.reloadData()
                self.activityIndicator.stopAnimating()
            }
        }
    }
    
    let urlString = "https://jsonplaceholder.typicode.com/photos"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setViews()
        loadListOfImages()
    }
    
    func loadListOfImages() {
        
        guard let url = URL(string: urlString) else { return }
        
        let task = URLSession.shared.dataTask(with: url) {
            data, _, error in
            
            if error != nil
            {
                print("error=\(String(describing: error))")
                return
            }
            
            guard let data = data else { return }
            do {
                if let convertedJsonIntoArray = try JSONSerialization.jsonObject(with: data, options: []) as? NSArray {
                    
                    self.images = convertedJsonIntoArray as [AnyObject]
                }
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
        task.resume()
    }
    
    private func setViews() {
        
        title = "Photo Loader"
        view.backgroundColor = .darkGray
        
        view.addSubview(photoCV)
        photoCV.addSubview(activityIndicator)
        
        photoCV.snp.makeConstraints { (make) in
            make.edges.equalTo(view.safeAreaLayoutGuide.snp.edges)
        }
        activityIndicator.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
    }
}

extension ViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCollectionViewCell.id,
                                                            for: indexPath) as? PhotoCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        cell.imageView.image = nil
        cell.activityIndicator.startAnimating()
        
        if let imageDictionary = images[indexPath.row] as? NSDictionary,
           let imageUrlString = imageDictionary.object(forKey: "thumbnailUrl") as? String,
           let imageUrl = URL(string: imageUrlString) {
            
            let task = URLSession.shared.dataTask(with: imageUrl) {
                data, _, error in
                
                if error != nil {
                    print("error=\(String(describing: error))")
                    return
                }
                
                guard let data = data else { return }
                DispatchQueue.main.async {
                    if let image = UIImage(data: data as Data) {
                        cell.imageView.image = image
                        cell.activityIndicator.stopAnimating()
                    }
                }
            }
            cell.task = task
            cell.task?.resume()
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let photoCell = cell as? PhotoCollectionViewCell else { return }
        photoCell.task?.cancel()
    }
}

extension ViewController: UICollectionViewDelegateFlowLayout {
    
    private var baseInset: CGFloat { return 8 }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = widthForSection(collectionView, numberOfItems: 3, inset: baseInset)
        
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return UIEdgeInsets(top: baseInset, left: baseInset, bottom: baseInset, right: baseInset)
    }
    
    private func widthForSection(_ collectionView: UICollectionView, numberOfItems: CGFloat, inset: CGFloat) -> CGFloat {
        return (collectionView.frame.size.width - inset * (numberOfItems + 1)) / numberOfItems
    }
}
