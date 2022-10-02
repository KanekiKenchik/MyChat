//
//  ProfileEditViewController.swift
//  MyChat
//
//  Created by Афанасьев Александр Иванович on 20.08.2022.
//

import UIKit
import Gallery
import ProgressHUD

struct SectionProfileEdit {
    let title: String
    let options: [CellTypeProfileEdit]
}

enum CellTypeProfileEdit {
    case imgEditCell(model: ImgEdit)
    case usernameEdit(model: UsernameEdit)
    case statusEdit(model: StatusEdit)
}

struct ImgEdit {
    
    let avatarLink: String
    
}

struct UsernameEdit {
    
    let username: String
    
}

struct StatusEdit {
    
    let status: String
    
}


class ProfileEditViewController: UIViewController {
    
    static let shared = ProfileEditViewController()
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.register(ImageEditTableViewCell.self, forCellReuseIdentifier: ImageEditTableViewCell.identifier)
        tableView.register(UsernameEditTableViewCell.self, forCellReuseIdentifier: UsernameEditTableViewCell.identifier)
        tableView.register(StatusEditTableViewCell.self, forCellReuseIdentifier: StatusEditTableViewCell.identifier)
        return tableView
    }()
    
    private var models = [SectionProfileEdit]()
    private var gallery: GalleryController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        refreshUserInfo()
        
    }
    
    private func setupViews() {
        setupBackgroundTap()
        view.backgroundColor = .secondarySystemBackground
        title = "Edit Profile"
        navigationItem.largeTitleDisplayMode = .never
        tableView.dataSource = self
        tableView.delegate = self
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints { make in
            make.right.top.left.bottom.equalToSuperview()
        }
        
        configure()
    }
    
    private func configure() {
        guard let user = User.currentUser else { return }
        
        self.models.append(SectionProfileEdit(title: "Image", options: [
            .imgEditCell(model: ImgEdit(avatarLink: user.avatarLink))
            ]))
        
        self.models.append(SectionProfileEdit(title: "Username", options: [
            .usernameEdit(model: UsernameEdit(username: user.username))]))
        
        self.models.append(SectionProfileEdit(title: "Status", options: [
            .statusEdit(model: StatusEdit(status: user.status))]))
        
    }
    
    private func refreshUserInfo() {
        
        let profileCellIndexPath = NSIndexPath(row: 0, section: 0)
        let profileCell = tableView.cellForRow(at: profileCellIndexPath as IndexPath) as! ImageEditTableViewCell
        
        if let user = User.currentUser {
            if user.avatarLink != "" {
                FileStorage.downloadImage(imageURL: user.avatarLink) { avatarImage in
                    profileCell.image.image = avatarImage?.circleMasked
                }
            }
        }
        
    }
    
    private func setupBackgroundTap() {
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(backgroundTap))
        view.addGestureRecognizer(tapGesture)
        
    }
    
    @objc private func backgroundTap() {
        view.endEditing(false)
    }

    //MARK: - UploadImages
    private func uploadAvatarImage(_ image: UIImage) {
        
        let fileDirectory = "Avatars/_\(User.currentId).jpg"
        
        FileStorage.uploadImage(image, path: fileDirectory) { avatarLink in
            if var user = User.currentUser {
                user.avatarLink = avatarLink ?? ""
                saveUserLocally(user)
                FirebaseUserListener.shared.saveUserToFirestore(user)
            }
            
            FileStorage.saveFileLocally(fileData: image.jpegData(compressionQuality: 1.0)! as NSData, fileName: User.currentId)
            
        }
        
    }
    
}

extension ProfileEditViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let model = models[indexPath.section].options[indexPath.row]
        
        switch model.self {
        case .imgEditCell(let model):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ImageEditTableViewCell.identifier) as? ImageEditTableViewCell else {
                return UITableViewCell()
            }
            cell.selectionStyle = .none
            cell.configure(with: model)
            cell.delegate = self
            
            return cell
            
        case .usernameEdit(let model):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: UsernameEditTableViewCell.identifier) as? UsernameEditTableViewCell else {
                return UITableViewCell()
            }
            cell.selectionStyle = .none
            cell.configure(with: model)

            return cell
            
        case .statusEdit(let model):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: StatusEditTableViewCell.identifier) as? StatusEditTableViewCell else {
                return UITableViewCell()
            }
            cell.selectionStyle = .none
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
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let type = models[indexPath.section].options[indexPath.row]
        switch type.self {
        case .imgEditCell:
            return 100
        case .usernameEdit:
            return 50
        case .statusEdit:
            return 50
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 32.0 : 15.0
    }
    
}

extension ProfileEditViewController: ImageEditTableViewCellDelegate {
    
    //MARK: - Gallery
    func showImageGallery() {
        
        self.gallery = GalleryController()
        self.gallery.delegate = self
        
        Config.tabsToShow = [.imageTab, .cameraTab]
        Config.Camera.imageLimit = 1
        Config.initialTab = .imageTab
        
        self.present(gallery, animated: true, completion: nil)
        
    }
}


extension ProfileEditViewController: GalleryControllerDelegate {
    
    func galleryController(_ controller: GalleryController, didSelectImages images: [Image]) {
        
        if images.count > 0 {
            
            images.first!.resolve { avatarImage in
                if avatarImage != nil {
                    self.uploadAvatarImage(avatarImage!)
                    let profileImageCellIndexPath = NSIndexPath(row: 0, section: 0)
                    let profileImageCell = self.tableView.cellForRow(at: profileImageCellIndexPath as IndexPath) as! ImageEditTableViewCell
                    profileImageCell.image.image = avatarImage?.circleMasked
                } else {
                    ProgressHUD.showError("Couldn't select image!")
                }
                
            }
            
        }
        
        controller.dismiss(animated: true, completion: nil)
        
    }
    
    func galleryController(_ controller: GalleryController, didSelectVideo video: Video) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func galleryController(_ controller: GalleryController, requestLightbox images: [Image]) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func galleryControllerDidCancel(_ controller: GalleryController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    
}
