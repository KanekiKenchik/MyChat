//
//  CustomTableViewCell.swift
//  MyChat
//
//  Created by Афанасьев Александр Иванович on 18.08.2022.
//

import UIKit
import SnapKit
import Gallery

protocol ImageEditTableViewCellDelegate: AnyObject {
    func showImageGallery()
}

class ImageEditTableViewCell: UITableViewCell {

    static let identifier = "ProfileEditTableViewCell"

    var gallery: GalleryController!
    weak var delegate: ImageEditTableViewCellDelegate?
    
    let image: UIImageView = {
        let img = UIImageView()
        img.image = UIImage(named: "avatar")
        img.contentMode = .scaleAspectFill
        return img
    }()
    
    let info: UILabel = {
        let lbl = UILabel()
        lbl.text = "Enter your name, status and add an optional profile picture"
        lbl.font = UIFont(name: "Avenir", size: 20)
        lbl.textColor = .lightGray
        lbl.textAlignment = .left
        lbl.numberOfLines = 0
        return lbl
    }()
    
    let editImgBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle("Edit", for: .normal)
        btn.setTitleColor(UIColor.systemBlue, for: .normal)
        btn.titleLabel?.font = UIFont(name: "Avenir", size: 15)
        return btn
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupViews()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        
        contentView.addSubview(image)
        contentView.addSubview(info)
        contentView.addSubview(editImgBtn)
        
        
        image.snp.makeConstraints { make in
            make.width.height.equalTo(60)
            make.top.equalToSuperview().offset(10)
            make.left.equalToSuperview().offset(10)
        }
        
        info.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-10)
            make.left.equalTo(image.snp.right).offset(10)
            make.top.equalToSuperview().offset(20)
        }
        
        editImgBtn.snp.makeConstraints { make in
            make.top.equalTo(image.snp.bottom)
            make.left.equalTo(image).offset(15)
        }
        
        editImgBtn.addTarget(self, action: #selector(editImgBtnPressed), for: .touchUpInside)
        
    }
    
    @objc private func editImgBtnPressed() {
        
        delegate?.showImageGallery()
        
    }
    
    public func configure(with model: ImgEdit) {
        setAvatar(avatarLink: model.avatarLink)
    }
    
    private func setAvatar(avatarLink: String) {
        if avatarLink != "" {
            FileStorage.downloadImage(imageURL: avatarLink) { avatarImage in
                self.image.image = avatarImage?.circleMasked
            }
        } else {
            self.image.image = UIImage(named: "avatar")
        }
    }
    
}
