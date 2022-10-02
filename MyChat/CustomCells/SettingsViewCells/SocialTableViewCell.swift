//
//  CustomTableViewCell.swift
//  MyChat
//
//  Created by Афанасьев Александр Иванович on 18.08.2022.
//

import UIKit
import SnapKit
import FirebaseAuth

class SocialTableViewCell: UITableViewCell {

    static let identifier = "SocialTableViewCell"
    
    private let lbl: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont(name: "Avenir", size: 20)
        return lbl
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupViews()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        
        contentView.addSubview(lbl)
        
        lbl.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.right.equalToSuperview().offset(10)
        }
        
    }
    
    public func configure(with model: SocialOptions) {
        lbl.text = model.lbl
        lbl.textAlignment = NSTextAlignment(rawValue: model.lblAlignment.rawValue)!
        lbl.font = model.font
        lbl.textColor = model.textColor
    }

    
}
