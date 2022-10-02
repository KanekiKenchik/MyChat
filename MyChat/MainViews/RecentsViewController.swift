//
//  MainAppViewController.swift
//  MyChat
//
//  Created by Афанасьев Александр Иванович on 17.08.2022.
//

import UIKit
import SnapKit
import FirebaseAuth

class RecentsViewController: UIViewController {

    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.register(RecentTableViewCell.self, forCellReuseIdentifier: RecentTableViewCell.identifier)
        return tableView
    }()
    
    private let searchController = UISearchController(searchResultsController: nil)
    
    private var allRecents = [RecentChat]()
    private var filteredRecents = [RecentChat]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        
    }
    
    private func setupViews() {
        
        setupSearchController()
        downloadRecentChats()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(composeBtnTapped))
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true
        
        view.backgroundColor = .secondarySystemBackground
        title = "Messages"
        
        tableView.dataSource = self
        tableView.delegate = self
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints { make in
            make.left.right.top.bottom.equalToSuperview()
        }
    }

    //MARK: - Navigation
    
    private func goToChat(recent: RecentChat) {
        
        restartChat(chatRoomID: recent.chatRoomId, memberIDs: recent.memberIds)
        
        let privateChatView = ChatViewController(chatId: recent.chatRoomId, recipientId: recent.receiverID, recipientName: recent.receiverName)
        privateChatView.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(privateChatView, animated: true)
        
    }
    
    @objc private func composeBtnTapped() {
        let userVC = UsersViewController()
        navigationController?.pushViewController(userVC, animated: true)
    }
    
    //MARK: - Download Chats
    private func downloadRecentChats() {
        
        FirebaseRecentListener.shared.downloadRecentChatsFromFirestore { allChats in
            self.allRecents = allChats
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    //MARK: - SetupSearchController
    private func setupSearchController() {
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = true
        
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search user"
        searchController.searchResultsUpdater = self
        definesPresentationContext = true
        
    }
    
    private func filteredContentForSearchText(searchText: String) {
        
        filteredRecents = allRecents.filter( { recent -> Bool in
            return recent.receiverName.lowercased().contains(searchText.lowercased())
        })
        
        tableView.reloadData()
        
    }
    
}

//MARK: - Extenshions
extension RecentsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: RecentTableViewCell.identifier) as? RecentTableViewCell else {
            return UITableViewCell()
        }
        
        let recent = searchController.isActive ? filteredRecents[indexPath.row] : allRecents[indexPath.row]
        
        cell.configure(with: recent)
        cell.accessoryType = .disclosureIndicator
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchController.isActive ? filteredRecents.count : allRecents.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let recent = searchController.isActive ? filteredRecents[indexPath.row] : allRecents[indexPath.row]
        
        FirebaseRecentListener.shared.clearUnreadCounter(recent: recent)
        goToChat(recent: recent)
            
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            let recent = searchController.isActive ? filteredRecents[indexPath.row] : allRecents[indexPath.row]
            
            FirebaseRecentListener.shared.deleteRecent(recent)
            
            searchController.isActive ? filteredRecents.remove(at: indexPath.row) : allRecents.remove(at: indexPath.row)
            
            tableView.deleteRows(at: [indexPath], with: .automatic)
            
        }
    }
    
}


extension RecentsViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        
        filteredContentForSearchText(searchText: searchController.searchBar.text!)
    }
    
}
