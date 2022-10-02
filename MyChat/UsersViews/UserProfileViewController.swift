//
//  ProfileEditViewController.swift
//  MyChat
//
//  Created by Афанасьев Александр Иванович on 20.08.2022.
//

import UIKit
import Gallery
import ProgressHUD

struct SectionUserProfile {
    let title: String
    let options: [CellTypeUserProfile]
}

enum CellTypeUserProfile {
    case userProfile(model: User)
    case goToChat(model: SocialOptions)
}

class UserProfileViewController: UIViewController {
    
    var user = User(id: "", username: "Username", email: "", pushId: "", avatarLink: "", status: "Status")
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.register(UserProfileTableViewCell.self, forCellReuseIdentifier: UserProfileTableViewCell.identifier)
        tableView.register(SocialTableViewCell.self, forCellReuseIdentifier: SocialTableViewCell.identifier)
        return tableView
    }()
    
    private var models = [SectionUserProfile]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupViews()
        
    }
    
    private func setupViews() {
        
        view.backgroundColor = .secondarySystemBackground
        title = "User Profile"
        navigationItem.largeTitleDisplayMode = .never
        tableView.dataSource = self
        tableView.delegate = self
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints { make in
            make.right.top.left.bottom.equalToSuperview()
        }
        
        tableView.sectionHeaderHeight = 0.0
        tableView.sectionFooterHeight = 0.0
        
        configure()
    }
    
    private func configure() {
        
        self.models.append(SectionUserProfile(title: "User profile", options: [
            .userProfile(model: User(id: "", username: user.username, email: "", pushId: "", avatarLink: user.avatarLink, status: user.status))]))
        
        self.models.append(SectionUserProfile(title: "Chat", options: [
            .goToChat(model: SocialOptions(lbl: "Start chat", lblAlignment: .center, font: UIFont(name: "Avenir", size: 20)!, textColor: .systemBlue, handler: { [weak self] in
                self?.startChatWithUser()
            }))]))
        
    }
    
    private func startChatWithUser() {
        
        let chatId = startChat(user1: User.currentUser!, user2: user)
        let privateChatView = ChatViewController(chatId: chatId, recipientId: user.id, recipientName: user.username)
        privateChatView.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(privateChatView, animated: true)
    }
    
}

extension UserProfileViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let model = models[indexPath.section].options[indexPath.row]
        
        switch model.self {
        case .userProfile(let model):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: UserProfileTableViewCell.identifier) as? UserProfileTableViewCell else {
                return UITableViewCell()
            }
            cell.selectionStyle = .none
            cell.configure(with: model)
            
            return cell
            
        case .goToChat(let model):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: SocialTableViewCell.identifier) as? SocialTableViewCell else {
                return UITableViewCell()
            }
            
            cell.accessoryType = .disclosureIndicator
            cell.configure(with: model)

            return cell
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let section = models[section]
        return section.title
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models[section].options.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return models.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let type = models[indexPath.section].options[indexPath.row]
        switch type.self {
        case .userProfile:
            break
        case .goToChat(let model):
            model.handler()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let type = models[indexPath.section].options[indexPath.row]
        switch type.self {
        case .userProfile:
            return 200
        case .goToChat:
            return 50
        }
    }
    
}
