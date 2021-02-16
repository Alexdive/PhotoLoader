//
//  StartViewController.swift
//  PhotoLoader
//
//  Created by Alex Permiakov on 2/5/21.
//

import UIKit

class StartViewController: UIViewController {

    private var button: UIButton = {
      let button = UIButton()
      button.setTitle("Tap to load images", for: .normal)
      button.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
      return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemTeal
        
        view.addSubview(button)
        button.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    
    @objc func buttonPressed(_ sender: UIButton) {
        navigationController?.pushViewController(ViewController(), animated: true)
    }


}
