//
//  CustomTableViewCell.swift
//  MyChat
//
//  Created by Афанасьев Александр Иванович on 18.08.2022.
//

import UIKit
import SnapKit

class UsernameEditTableViewCell: UITableViewCell {

    static let identifier = "UsernameEditTableViewCell"
    
    private let usernameTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Username"
        tf.borderStyle = .none
        tf.returnKeyType = .done
        tf.clearButtonMode = .whileEditing
        return tf
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupViews()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        
        contentView.addSubview(usernameTextField)
        
        usernameTextField.delegate = self
        
        usernameTextField.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(15)
            make.right.equalTo(-15)
        }
        
    }
    
    public func configure(with model: UsernameEdit) {
        usernameTextField.text = model.username
    }
    
}

extension UsernameEditTableViewCell: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == usernameTextField {
            if textField.text != "" {
                if var user = User.currentUser {
                    user.username = textField.text!
                    saveUserLocally(user)
                    FirebaseUserListener.shared.saveUserToFirestore(user)
                }
            }
            textField.resignFirstResponder()
            return true
        }
        return false
    }
    
}
