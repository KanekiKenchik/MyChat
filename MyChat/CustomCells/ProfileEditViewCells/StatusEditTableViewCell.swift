//
//  CustomTableViewCell.swift
//  MyChat
//
//  Created by Афанасьев Александр Иванович on 18.08.2022.
//

import UIKit
import SnapKit

class StatusEditTableViewCell: UITableViewCell {

    static let identifier = "StatusEditTableViewCell"
    
    private let statusTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Status"
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
        
        contentView.addSubview(statusTextField)
        
        statusTextField.delegate = self
        
        statusTextField.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(15)
            make.right.equalTo(-15)
        }
        
    }
    
    public func configure(with model: StatusEdit) {
        statusTextField.text = model.status
    }
    
}

extension StatusEditTableViewCell: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == statusTextField {
            if textField.text != "" {
                if var user = User.currentUser {
                    user.status = textField.text!
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
