//
//  ViewController.swift
//  myMessenger
//
//  Created by Ahmed Mokhtar on 7/14/18.
//  Copyright © 2018 Ahmed Mokhtar. All rights reserved.
//

import UIKit

class RecentMessagesViewController: UITableViewController , RecentMessagesPresenterDelegate{

    var presenter : RecentMessagesViewPresenter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(presenter.handleLogout))
        tableView.register(UserCell.self, forCellReuseIdentifier: "cellID")
        presenter.recentMessagesPresenterDelegate = self
        presenter.checkIfUserIsLoggedIn()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        presenter.checkIfUserIsLoggedIn()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellID", for: indexPath) as! UserCell
        let messageVM = presenter.messagesArray[indexPath.row]
        cell.textLabel?.text = messageVM.partnerName
        cell.detailTextLabel?.text = messageVM.messageText
        if let url = messageVM.partnerImageURL {
            cell.profileImageView.sd_setImage(with: url, completed: nil)
        }
        cell.timeLabel.text = messageVM.timeText
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.messagesArray.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let messageModelView = presenter.messagesArray[indexPath.row]
        presenter.a(messageModelView: messageModelView)
        
    }
    
    func setupBarView() {
        presenter.messagesArray.removeAll()
        tableView.reloadData()
        presenter.grabUserMessages()
                
        let titleView = NavigationBarTitleView(frame: CGRect(x: 0, y: 0, width: 100, height: 40))
        if let url = presenter.user?.profileImageURL {
            titleView.profileImageView.sd_setImage(with: url, completed: nil)
        }
        
        titleView.titleLabel.text = presenter.user?.name
        navigationItem.titleView = titleView
        
    }
    
    func presentChatLogWithUser(user: User) {
        let chatLogVC = ChatLogViewController(collectionViewLayout: UICollectionViewFlowLayout())
        let chatLogPresenter = ChatLogPresenter()
        chatLogPresenter.user = user
        chatLogVC.presenter = chatLogPresenter
        chatLogVC.presenter.grabMessages()
        navigationController?.pushViewController(chatLogVC, animated: true)
    }
    
    @objc func handleLogout() {
        let logoutViewController = LoginLogoutViewController()
        let loginLogoutPresenter = LoginLogoutPresenter()
        logoutViewController.presenter = loginLogoutPresenter
        present(logoutViewController, animated: true, completion: nil)
    }
    
    func reloadTableView() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        print("reloading tableView")
    }
    
}

