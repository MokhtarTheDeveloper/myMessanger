//
//  ViewController.swift
//  myMessenger
//
//  Created by Ahmed Mokhtar on 7/14/18.
//  Copyright © 2018 Ahmed Mokhtar. All rights reserved.
//

import UIKit
import Firebase

class MessagesViewController: UITableViewController {

    
    var userViewModel : UserViewModel?
    
    var messagesModelViewArray = [MessageViewModel]()
    let ref = Firebase.Database.database().reference()
    var timer : Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        tableView.register(UserCell.self, forCellReuseIdentifier: "cellID")
        
        checkIfUserIsLoggedIn()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        checkIfUserIsLoggedIn()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellID", for: indexPath) as! UserCell
        cell.messageModelView = messagesModelViewArray[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messagesModelViewArray.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let messageModelView = messagesModelViewArray[indexPath.row]
        let userID = messageModelView.partnerID
        let ref = Firebase.Database.database().reference().child("user").child(userID!)
        ref.observeSingleEvent(of: .value, with: { (snapShot) in
            if let dict = snapShot.value as? [String : String] {
                let user = User(dictionary: dict, id: userID)
                let userVM = UserViewModel(user: user)
                self.presentChatLogWithUser(userVM: userVM)
            }
        }, withCancel: nil)
    }
    
    
    
    func setupBarView() {
        messagesModelViewArray.removeAll()
        tableView.reloadData()
        grabUserMessages()
                
        let titleView = NavigationBarTitleView(frame: CGRect(x: 0, y: 0, width: 100, height: 40))
        if let url = userViewModel?.userProfileImageUrl {
            titleView.profileImageView.sd_setImage(with: url, completed: nil)
        }
        
        titleView.titleLabel.text = userViewModel?.name
        navigationItem.titleView = titleView
        
    }
    
    @objc func presentChatLogWithUser(userVM: UserViewModel) {
        let chatLogVC = ChatLogViewController(collectionViewLayout: UICollectionViewFlowLayout())
        chatLogVC.userViewModel = userVM
        chatLogVC.grabMessages()
        navigationController?.pushViewController(chatLogVC, animated: true)
    }
    
    
    func checkIfUserIsLoggedIn() {
        if Auth.auth().currentUser?.email == nil {
            print("nil")
            performSelector(onMainThread: #selector(handleLogout), with: nil, waitUntilDone: true)
        } else {
            guard let uid = Auth.auth().currentUser?.uid else { return }
            
            
            Firebase.Database.database().reference().child("user").child(uid).observe(.value, with: { (dataSnap) in
                if let dictionary = dataSnap.value as? [String : AnyObject]{
                    self.userViewModel = UserViewModel(user: User(dictionary: dictionary, id: uid))
                        self.setupBarView()
                }
            }) { (error) in
                print(error)
            }
            
        }
    }
    
    @objc func handleLogout() {
        do {
            try Auth.auth().signOut()
            
        } catch{
            print(error)
        }
        let logoutViewController = LoginLogoutViewController()
        present(logoutViewController, animated: true, completion: nil)
        
    }
    
    
    func grabUserMessages() {
        guard let uid = userViewModel?.id else { return }
        Networking.shared.grabFriendsLatestMessages(uid: uid) { (messagesDict) in
            self.messagesModelViewArray = Array(messagesDict.values).map({MessageViewModel(message: $0)})
            self.messagesModelViewArray.sort(by: { (messageModelView1, messageModelView2) -> Bool in
                return (messageModelView1.timeDoubleValue)! > (messageModelView2.timeDoubleValue)!
            })
            self.timer?.invalidate()
            self.timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.reloadTableView), userInfo: nil, repeats: false)
        }
    }
    
    
    @objc func reloadTableView() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        print("reloading tableView")
    }
    
}

