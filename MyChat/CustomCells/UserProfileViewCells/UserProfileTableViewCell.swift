//
//  CustomTableViewCell.swift
//  MyChat
//
//  Created by Афанасьев Александр Иванович on 18.08.2022.
//

import UIKit
import SnapKit

class UserProfileTableViewCell: UITableViewCell {

    static let identifier = "UserProfileTableViewCell"
    
    let avatarImageView: UIImageView = {
        let img = UIImageView()
        img.image = UIImage(named: "avatar")
        return img
    }()
    
    let usernameLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Username"
        lbl.font = UIFont(name: "Avenir Medium", size: 25)
        lbl.textColor = .black
        lbl.textAlignment = .center
        return lbl
    }()
    
    let statusLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Status"
        lbl.font = UIFont(name: "Avenir Book", size: 21)
        lbl.textColor = .lightGray
        lbl.textAlignment = .center
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
        
        contentView.addSubview(avatarImageView)
        contentView.addSubview(usernameLabel)
        contentView.addSubview(statusLabel)
        
        avatarImageView.snp.makeConstraints { make in
            make.width.height.equalTo(100)
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(20)
        }
        
        usernameLabel.snp.makeConstraints { make in
            make.top.equalTo(avatarImageView.snp.bottom)
            make.left.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-10)
        }
        
        statusLabel.snp.makeConstraints { make in
            make.top.equalTo(usernameLabel.snp.bottom)
            make.left.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-10)
        }
        
    }
    
    public func configure(with user: User) {
        usernameLabel.text = user.username
        statusLabel.text = user.status
        setAvatar(avatarLink: user.avatarLink)
    }
    
    private func setAvatar(avatarLink: String) {
        if avatarLink != "" {
            FileStorage.downloadImage(imageURL: avatarLink) { avatarImage in
                self.avatarImageView.image = avatarImage?.circleMasked
            }
        }
    }
    
}
