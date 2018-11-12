//
//  NewMessageController.swift
//  myMessenger
//
//  Created by Ahmed Mokhtar on 7/21/18.
//  Copyright © 2018 Ahmed Mokhtar. All rights reserved.
//

import UIKit

class ContactsController: UITableViewController , ContactPresenterDelegate{
    var presenter : ContactPresenter!
    
    var messagesController : RecentMessagesViewController? {
        didSet {
            presenter.fetchData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.delegate = self
        tableView.register(UserCell.self, forCellReuseIdentifier: "cellID")
        presenter.fetchData()
    }
    
    @objc func handleCancelButton() {
        navigationController?.popViewController(animated: true)
    }
    
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.usersArray.count
    }

    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellID", for: indexPath) as! UserCell
        cell.textLabel?.text = presenter.usersArray[indexPath.row].name
        cell.detailTextLabel?.text = presenter.usersArray[indexPath.row].mail
        if let url = presenter.usersArray[indexPath.row].profileImageURL {
            cell.profileImageView.sd_setImage(with: url, completed: nil)
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }

    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        navigationController?.popViewController(animated: true)
        presentChatLogWithUser(user: presenter.usersArray[indexPath.row])
    }
    
    
    @objc func presentChatLogWithUser(user: User) {
        let chatLogVC = ChatLogViewController(collectionViewLayout: UICollectionViewFlowLayout())
        let chatLogPresenter = ChatLogPresenter()
        chatLogPresenter.user = user
        chatLogVC.presenter = chatLogPresenter
        chatLogVC.presenter.grabMessages()
        navigationController?.pushViewController(chatLogVC, animated: true)
    }
    
    func reloadTableView() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}
