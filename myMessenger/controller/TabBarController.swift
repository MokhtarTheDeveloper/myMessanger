//
//  TabBarController.swift
//  myMessenger
//
//  Created by Mokhtar on 10/14/18.
//  Copyright © 2018 Ahmed Mokhtar. All rights reserved.
//

import UIKit
import Firebase

class TabBarController: UITabBarController {
    
    
    var userViewModel : UserViewModel?

    override func viewDidLoad() {
        
        super.viewDidLoad()
        tabBar.tintColor = .flatGreen()
        guard let speechBubble = UIImage(named: "speech-bubble") else { return }
        guard let contacts = UIImage(named: "contacts") else { return }
        viewControllers = [setUpViewControllers(viewController: MessagesViewController(), title: "Chats", image: speechBubble), setUpViewControllers(viewController: NewMessageController(), title: "Contacts", image: contacts)]
        
    }
    
    
    func setUpViewControllers(viewController: UIViewController, title: String, image: UIImage) -> UIViewController {
        let navController = UINavigationController(rootViewController: viewController)
        navController.tabBarItem.title = title
        navController.tabBarItem.image = image
        navigationItem.title = title
        return navController
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

    
    
}
