
import UIKit
import SnapKit

class PhotoCollectionViewCell: UICollectionViewCell {
    
    static let id = "PhotoCell"

    lazy var imageView: CustomImageView = {
        let imageView = CustomImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = UIColor.systemGray2.cgColor
        imageView.layer.cornerRadius = 4
        return imageView
    }() 
    
    lazy var activityIndicator: UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.medium)
        ai.color = .white
        return ai
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
 
    private func setupUI() {
        
        contentView.addSubview(imageView)
        contentView.addSubview(activityIndicator)
        
        imageView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        activityIndicator.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
    }
}


