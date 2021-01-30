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
    
    let countLabel = UILabel()
    
    var counter = 0 {
        didSet {
            let min = counter / 60
            countLabel.text = "is open for \(min) min \(counter - min * 60) sec"
        }
    }
    
    lazy var photoCV: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8
        let cv = UICollectionView(frame: view.safeAreaLayoutGuide.layoutFrame, collectionViewLayout: layout)
        cv.register(PhotoCollectionViewCell.self, forCellWithReuseIdentifier: PhotoCollectionViewCell.id)
        cv.backgroundColor = .systemGray
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
        setTimer()
        loadListOfImages()
    }
    
    func loadListOfImages() {
        
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) {
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
        }.resume()
    }
    
    private func setTimer() {
        let timer = Timer(timeInterval: 1.0,
                          target: self,
                          selector: #selector(fireTimer),
                          userInfo: nil,
                          repeats: true)
        RunLoop.current.add(timer, forMode: .common)
    }
    
    @objc func fireTimer() {
        counter += 1
    }
    
    private func setViews() {
        
        title = "Photo Loader"
        view.backgroundColor = .systemGray
        
        view.addSubview(photoCV)
        view.addSubview(countLabel)
        view.addSubview(activityIndicator)
        
        countLabel.snp.makeConstraints { (make) in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(16)
            make.centerX.equalToSuperview()
        }
        
        photoCV.snp.makeConstraints { (make) in
            make.top.equalTo(countLabel.snp.bottom).offset(16)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
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
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCollectionViewCell.id, for: indexPath) as? PhotoCollectionViewCell else { return UICollectionViewCell() }
        
        cell.activityIndicator.startAnimating()
        
        if let imageDictionary = images[indexPath.row] as? NSDictionary,
           let imageUrlString = imageDictionary.object(forKey: "thumbnailUrl") as? String {
   
            cell.imageView.loadImageUsingUrlString(urlString: imageUrlString, completion: {
                cell.activityIndicator.stopAnimating()
            })
        }
        return cell
    }
}

extension ViewController: UICollectionViewDelegateFlowLayout {
    
    private var baseInset: CGFloat { return 8 }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = widthForSection(collectionView, numberOfItems: 3, inset: baseInset)
        
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return UIEdgeInsets(top: 0, left: baseInset, bottom: 0, right: baseInset)
    }
    
    private func widthForSection(_ collectionView: UICollectionView, numberOfItems: CGFloat, inset: CGFloat) -> CGFloat {
        return (collectionView.frame.size.width - inset * (numberOfItems + 1)) / numberOfItems
    }
}
