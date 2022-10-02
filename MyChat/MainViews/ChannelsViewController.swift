//
//  ChannelsViewController.swift
//  MyChat
//
//  Created by Афанасьев Александр Иванович on 18.08.2022.
//

import UIKit
import SnapKit

class ChannelsViewController: UIViewController {
    
    let comingSoonLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Coming Soon"
        lbl.font = UIFont(name: "Avenir", size: 50)
        lbl.textColor = .lightGray
        lbl.textAlignment = .center
        return lbl
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        
    }
    
    private func setupViews() {
        view.addSubview(comingSoonLabel)
        
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true
        
        view.backgroundColor = .secondarySystemBackground
        title = "Channels"
        
        comingSoonLabel.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
        }
        
    }

}
