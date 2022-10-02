//
//  CustomTableViewCell.swift
//  MyChat
//
//  Created by Афанасьев Александр Иванович on 18.08.2022.
//

import UIKit
import SnapKit

class RecentTableViewCell: UITableViewCell {

    static let identifier = "MessageTableViewCell"
    
    let avatarImageView: UIImageView = {
        let img = UIImageView()
        img.image = UIImage(named: "avatar")
        return img
    }()
    
    let usernameLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Username"
        lbl.font = UIFont(name: "Avenir Medium", size: 17)
        lbl.textColor = .black
        lbl.textAlignment = .left
        return lbl
    }()
    
    let lastMessage: UILabel = {
        let lbl = UILabel()
        lbl.text = "Last message"
        lbl.font = UIFont(name: "Avenir Medium", size: 15)
        lbl.textColor = .lightGray
        lbl.textAlignment = .left
        lbl.numberOfLines = 2
        return lbl
    }()
    
    let lastMessageTime: UILabel = {
        let lbl = UILabel()
        lbl.text = "Today 22:45"
        lbl.font = UIFont(name: "Avenir Medium", size: 13)
        lbl.textColor = .darkGray
        lbl.textAlignment = .left
        return lbl
    }()
    
    let unreadMessagesView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGreen
        view.layer.cornerRadius = 15
        return view
    }()
    
    let unreadMessagesCount: UILabel = {
        let lbl = UILabel()
        lbl.text = "1000"
        lbl.font = UIFont(name: "Avenir Medium", size: 12)
        lbl.textColor = .white
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
        contentView.addSubview(lastMessage)
        contentView.addSubview(lastMessageTime)
        contentView.addSubview(unreadMessagesView)
        
        avatarImageView.snp.makeConstraints { make in
            make.width.height.equalTo(60)
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(10)
        }
        
        lastMessageTime.snp.makeConstraints { make in
            make.height.equalTo(18)
            make.width.equalTo(77)
            make.right.equalToSuperview().offset(-2)
            make.top.equalTo(usernameLabel.snp.top)
        }
        
        unreadMessagesView.snp.makeConstraints { make in
            make.width.height.equalTo(30)
            make.bottom.equalTo(avatarImageView.snp.bottom)
            make.right.equalToSuperview().offset(-10)
            
        }
        
        usernameLabel.snp.makeConstraints { make in
            make.top.equalTo(avatarImageView.snp.top)
            make.left.equalTo(avatarImageView.snp.right).offset(8)
            make.right.equalTo(lastMessageTime.snp.left).offset(-8)
        }
        
        lastMessage.snp.makeConstraints { make in
            make.top.equalTo(usernameLabel.snp.bottom)
            make.left.equalTo(avatarImageView.snp.right).offset(8)
            make.right.equalTo(unreadMessagesView.snp.left).offset(-8)
        }
        
        unreadMessagesView.addSubview(unreadMessagesCount)
        
        unreadMessagesCount.snp.makeConstraints { make in
            make.left.top.right.bottom.equalToSuperview()
        }
        
    }
    
    public func configure(with recent: RecentChat) {
        usernameLabel.text = recent.receiverName
        usernameLabel.adjustsFontSizeToFitWidth = true
        usernameLabel.minimumScaleFactor = 0.9
        
        lastMessage.text = recent.lastMessage
        lastMessage.adjustsFontSizeToFitWidth = true
        lastMessage.minimumScaleFactor = 0.9
        
        if recent.unreadCounter != 0 {
            self.unreadMessagesCount.text = "\(recent.unreadCounter)"
            self.unreadMessagesView.isHidden = false
        } else {
            self.unreadMessagesView.isHidden = true
        }
        
        lastMessageTime.text = timeElapsed(recent.date ?? Date())
        lastMessageTime.adjustsFontSizeToFitWidth = true
        
        setAvatar(avatarLink: recent.avatarLink)
    }
    
    private func setAvatar(avatarLink: String) {
        if avatarLink != "" {
            FileStorage.downloadImage(imageURL: avatarLink) { avatarImage in
                self.avatarImageView.image = avatarImage?.circleMasked
            }
        } else {
            self.avatarImageView.image = UIImage(named: "avatar")
        }
    }
    
}
