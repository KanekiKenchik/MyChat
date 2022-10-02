//
//  SettingsViewController.swift
//  MyChat
//
//  Created by Афанасьев Александр Иванович on 18.08.2022.
//

import UIKit
import FirebaseAuth
import RealmSwift

struct Section {
    let title: String
    let options: [CellType]
}

enum CellType {
    case profileCell(model: User)
    case socialCell(model: SocialOptions)
}

struct SocialOptions {
    
    let lbl: String
    let lblAlignment: alignment
    let font: UIFont
    let textColor: UIColor
    let handler: (() -> Void)
    
    enum alignment: Int {
        case center = 1
        case left = 0
    }
    
}

class SettingsViewController: UIViewController {
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.register(ProfileTableViewCell.self, forCellReuseIdentifier: ProfileTableViewCell.identifier)
        tableView.register(SocialTableViewCell.self, forCellReuseIdentifier: SocialTableViewCell.identifier)
        return tableView
    }()
    
    var models = [Section]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        refreshUserInfo()
    }

    private func setupViews() {
        
        configure()
        
        view.backgroundColor = .secondarySystemBackground
        title = "Settings"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        tableView.dataSource = self
        tableView.delegate = self
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints { make in
            make.left.right.top.bottom.equalToSuperview()
        }
        
    }
    
    private func configure() {
        
        var avatarLink = ""
        
        if User.currentUser != nil {
            avatarLink = User.currentUser!.avatarLink
        }
        
        self.models.append(Section(title: "Profile", options: [
            .profileCell(model: User(id: "", username: "Username", email: "", pushId: "", avatarLink: avatarLink, status: "Status"))]))
        
        self.models.append(Section(title: "Social", options: [
            .socialCell(model: SocialOptions(lbl: "Tell a friend", lblAlignment: .left, font: UIFont(name: "Avenir", size: 20)!, textColor: .systemBlue) {
                //Tell a friend cell tapped
                print("Tell a friend cell tapped")
            }),
            .socialCell(model: SocialOptions(lbl: "Terms and conditions", lblAlignment: .left, font: UIFont(name: "Avenir", size: 20)!, textColor: .systemBlue) {
                //Terms and conditions cell tapped
                print("Terms and conditions cell tapped")
            })]))
        
        self.models.append(Section(title: "System", options: [.socialCell(model: SocialOptions(lbl: "Log Out", lblAlignment: .center, font: UIFont.boldSystemFont(ofSize: 22), textColor: .systemRed) {
            FirebaseUserListener.shared.logOutCurrentUser { error in
                if error == nil {
                    self.dismiss(animated: true)
                }
            }
        })]))
        
    }
    
    //MARK: - Segue to profile editing
    private func goToProfileEditing() {
        
        let newVC = ProfileEditViewController()
        
        navigationController?.pushViewController(newVC, animated: true)
    }
    
    //MARK: - UpdateUI
    private func refreshUserInfo() {
        
        let profileCellIndexPath = NSIndexPath(row: 0, section: 0)
        let profileCell = tableView.cellForRow(at: profileCellIndexPath as IndexPath) as! ProfileTableViewCell
        
        if User.currentUser != nil {
            profileCell.configure(with: User.currentUser!)
        }
        
    }
    
}

extension SettingsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let model = models[indexPath.section].options[indexPath.row]

        switch model.self {
        case .profileCell(let model):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ProfileTableViewCell.identifier) as? ProfileTableViewCell else {
                return UITableViewCell()
            }

            cell.configure(with: model)

            cell.accessoryType = .disclosureIndicator
            return cell
            
        case .socialCell(let model):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: SocialTableViewCell.identifier) as? SocialTableViewCell else {
                return UITableViewCell()
            }
            
            cell.configure(with: model)
            
            cell.accessoryType = .disclosureIndicator
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
        case .profileCell:
            goToProfileEditing()
        case .socialCell(let model):
            model.handler()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let type = models[indexPath.section].options[indexPath.row]
        switch type.self {
        case .profileCell:
            return 100
        case .socialCell:
            return 50
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 32.0 : 15.0
    }
    
}
