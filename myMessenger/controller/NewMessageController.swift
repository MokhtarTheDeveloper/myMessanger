//
//  NewMessageController.swift
//  myMessenger
//
//  Created by Ahmed Mokhtar on 7/21/18.
//  Copyright © 2018 Ahmed Mokhtar. All rights reserved.
//

import UIKit
import Firebase

class NewMessageController: UITableViewController {
    
    let ref = Firebase.Database.database().reference().child("user")
    var messagesController : MessagesViewController? {
        didSet{
            self.fetchData()
        }
    }
    var usersViewModelArray = [UserViewModel]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UserCell.self, forCellReuseIdentifier: "cellID")
        fetchData()
    }
    
    @objc func handleCancelButton() {
        navigationController?.popViewController(animated: true)
    }
    
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usersViewModelArray.count
    }

    func fetchData() {
        ref.observe(.childAdded, with: { (dataSnap) in
            guard let dictionary = dataSnap.value as? [String : AnyObject] else { return }
            let id = dataSnap.key
            let user = User(dictionary: dictionary, id: id)
            let userVM = UserViewModel(user: user)
            if Auth.auth().currentUser?.uid != id{
                self.usersViewModelArray.append(userVM)
            }
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }) { (error) in
            print(error)
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellID", for: indexPath) as! UserCell
        cell.textLabel?.text = usersViewModelArray[indexPath.row].name
        cell.detailTextLabel?.text = usersViewModelArray[indexPath.row].mail
        if let url = usersViewModelArray[indexPath.row].userProfileImageUrl {
            cell.profileImageView.sd_setImage(with: url, completed: nil)
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }

    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        navigationController?.popViewController(animated: true)
        presentChatLogWithUser(userVM: usersViewModelArray[indexPath.row])
    }
    
    
    @objc func presentChatLogWithUser(userVM: UserViewModel) {
        let chatLogVC = ChatLogViewController(collectionViewLayout: UICollectionViewFlowLayout())
        chatLogVC.userViewModel = userVM
        chatLogVC.grabMessages()
        navigationController?.pushViewController(chatLogVC, animated: true)
    }
}
