//
//  UsersViewController.swift
//  MyChat
//
//  Created by Афанасьев Александр Иванович on 18.08.2022.
//

import UIKit

class UsersViewController: UIViewController {
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.register(ProfileTableViewCell.self, forCellReuseIdentifier: ProfileTableViewCell.identifier)
        return tableView
    }()
    
    var allUsers = [User]()
    var filteredUsers = [User]()
    
    let searchController = UISearchController(searchResultsController: nil)

    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
    }

    private func setupViews() {
        
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true
        
        tableView.refreshControl = UIRefreshControl()
        
//        createDummyUsers()
        setupSearchController()
        downloadUsers()
        
        view.backgroundColor = .secondarySystemBackground
        title = "Users"
        navigationController?.navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true
        
        tableView.dataSource = self
        tableView.delegate = self
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints { make in
            make.left.right.top.bottom.equalToSuperview()
        }
        
    }
    
    //MARK: - DownloadUsers
    private func downloadUsers() {
        FirebaseUserListener.shared.downloadAllUsersFromFirebase { allFirebaseUsers in
            
            self.allUsers = allFirebaseUsers
            
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
        
        filteredUsers = allUsers.filter({ user -> Bool in
            
            return user.username.lowercased().contains(searchText.lowercased())
        })
        
        tableView.reloadData()
    }
    
    //MARK: - UIScrollViewDelegate
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        if tableView.refreshControl!.isRefreshing {
            downloadUsers()
            tableView.refreshControl!.endRefreshing()
        }
    }
    
    //MARK: - Segue to user profile
    private func goToUserProfile(user: User) {
        
        let newVC = UserProfileViewController()
        newVC.user = user
        
        navigationController?.pushViewController(newVC, animated: true)
    }

}

extension UsersViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let user = searchController.isActive ? filteredUsers[indexPath.row] : allUsers[indexPath.row]

        guard let cell = tableView.dequeueReusableCell(withIdentifier: ProfileTableViewCell.identifier) as? ProfileTableViewCell else {
            return UITableViewCell()
        }
        
        cell.configure(with: user)
        
        cell.accessoryType = .disclosureIndicator
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchController.isActive ? filteredUsers.count : allUsers.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let user = searchController.isActive ? filteredUsers[indexPath.row] : allUsers[indexPath.row]
        
        goToUserProfile(user: user)
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
//    //MARK: - TableViewDelegates
//    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//
//        let headerView = UIView()
//        headerView
//    }
//
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return 5
//    }

    
}


extension UsersViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        
        filteredContentForSearchText(searchText: searchController.searchBar.text!)
    }
    
}
