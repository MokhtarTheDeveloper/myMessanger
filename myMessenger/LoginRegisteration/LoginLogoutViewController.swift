//
//  LogoutViewController.swift
//  myMessenger
//
//  Created by Ahmed Mokhtar on 7/15/18.
//  Copyright © 2018 Ahmed Mokhtar. All rights reserved.
//

import UIKit
import ChameleonFramework

class LoginLogoutViewController: UIViewController, UITextFieldDelegate, LoginLogoutDelegate {
    
    var presenter : LoginLogoutPresenter!
    
    lazy var scrollView : UIScrollView = {
        let scrView = UIScrollView(frame: self.view.frame)
        let size = CGSize(width: self.view.frame.size.width, height: self.view.frame.size.height + 50)
        scrView.contentSize = size
        scrView.backgroundColor = UIColor.flatGreen()
        scrView.bounces = true
        return scrView
    }()
    
    
    let inputsContainerView : UIView = {
        let vview = UIView()
        vview.backgroundColor = UIColor.white
        vview.translatesAutoresizingMaskIntoConstraints = false
        vview.layer.cornerRadius = 10
        vview.layer.masksToBounds = true
        return vview
    }()

    let registerButton : UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor.flatGreenColorDark()
        button.layer.cornerRadius = 22
        button.layer.masksToBounds = true
        button.setTitle("Register", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handelLoginLogout), for: .touchUpInside)
        return button
    }()
    
    
    lazy var nameTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Name"
        tf.delegate = self
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    let fieldSperator: UIView = {
        let vw = UIView()
        vw.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        vw.translatesAutoresizingMaskIntoConstraints = false
        return vw
    }()
    
    let fieldSperator2: UIView = {
        let vw = UIView()
        vw.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        vw.translatesAutoresizingMaskIntoConstraints = false
        return vw
    }()
    
    
    lazy var mailTextField: UITextField = {
        let tf = UITextField()
        tf.delegate = self
        tf.placeholder = "E-mail Adress"
        tf.backgroundColor = UIColor.white
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    
    lazy var passwordTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Password"
        tf.delegate = self
        tf.backgroundColor = UIColor.white
        tf.isSecureTextEntry = true
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    
    lazy var userProfileImageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "iTunesArtwork")
        view.contentMode = .scaleToFill
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleProfileImagePicker)))
        view.isUserInteractionEnabled = true
        return view
    }()
    
    let segmantedController: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["Login", "Register"])
        sc.translatesAutoresizingMaskIntoConstraints = false
        sc.selectedSegmentIndex = 1
        sc.backgroundColor = UIColor.white
        sc.tintColor = UIColor.flatForestGreen()
        sc.layer.cornerRadius = 5
        sc.layer.masksToBounds = true
        sc.addTarget(self, action: #selector(handleSegmantedController), for: .valueChanged)
        return sc
    }()
    
    @objc func handleSegmantedController() {
        
        userProfileImageView.isHidden = segmantedController.selectedSegmentIndex == 0 ? true : false
        let title = segmantedController.titleForSegment(at: segmantedController.selectedSegmentIndex)
        registerButton.setTitle(title, for: .normal)
        inputsContainerHeightAnchor?.constant = segmantedController.selectedSegmentIndex == 0 ? 100 : 150
        nameTextFieldHeightAnchor?.isActive = false
        nameTextFieldHeightAnchor = nameTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: segmantedController.selectedSegmentIndex == 0 ? 0 : 1/3)
        nameTextFieldHeightAnchor?.isActive = true
        mailTextFieldHeightAnchor?.isActive = false
        mailTextFieldHeightAnchor = mailTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: segmantedController.selectedSegmentIndex == 0 ? 1/2 : 1/3)
        mailTextFieldHeightAnchor?.isActive = true
        passwordTextFieldHeightAnchor?.isActive = false
        passwordTextFieldHeightAnchor = passwordTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: segmantedController.selectedSegmentIndex == 0 ? 1/2 : 1/3)
        passwordTextFieldHeightAnchor?.isActive = true
        firstSepratoprHeightAnchor?.isActive = false
        firstSepratoprHeightAnchor = fieldSperator.heightAnchor.constraint(equalToConstant: segmantedController.selectedSegmentIndex == 0 ? 0 : 1)
        firstSepratoprHeightAnchor?.isActive = true
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.delegate = self
        
        view.addSubview(scrollView)
        scrollView.addSubview(inputsContainerView)
        scrollView.addSubview(registerButton)
        scrollView.addSubview(userProfileImageView)
        scrollView.addSubview(segmantedController)
        scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        setUpinputsContainerView()
        setUpnameTextFieldConstraint()
        setUpFieldSperatorConstraint()
        setUpMailTextField()
        setUpPasswordTextField()
        setUpfieldSperator2Constraints()
        setUpRegisterButtonConstraints()
        setUpsegmantedControllerConstraint()
        imageVWConstraint()
        
        NotificationCenter.default.addObserver(self , selector: #selector(handleKeyboardAppearance), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardDisappearance), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func handleKeyboardDisappearance(notification : NSNotification) {
        
        view.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        
    }
    
    @objc func handleKeyboardAppearance(notification : NSNotification) {
        
        view.frame = CGRect(x: 0, y: -44, width: view.frame.width, height: view.frame.height)
        
    }

    var nameTextFieldHeightAnchor: NSLayoutConstraint?
    var mailTextFieldHeightAnchor: NSLayoutConstraint?
    var passwordTextFieldHeightAnchor: NSLayoutConstraint?
    var inputsContainerHeightAnchor: NSLayoutConstraint?
    var firstSepratoprHeightAnchor: NSLayoutConstraint?
    
    
    func setUpinputsContainerView() {
        inputsContainerView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
        inputsContainerView.topAnchor.constraint(equalTo: segmantedController.bottomAnchor, constant: 16).isActive = true
        inputsContainerView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -24).isActive = true
        inputsContainerHeightAnchor = inputsContainerView.heightAnchor.constraint(equalToConstant: 150.0)
        inputsContainerHeightAnchor?.isActive = true
    }
    
    
    func setUpnameTextFieldConstraint() {
        
        inputsContainerView.addSubview(nameTextField)
        nameTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 15).isActive = true
        nameTextField.rightAnchor.constraint(equalTo: inputsContainerView.rightAnchor, constant: -15).isActive = true
        nameTextField.topAnchor.constraint(equalTo: inputsContainerView.topAnchor).isActive = true
        nameTextFieldHeightAnchor = nameTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/3)
        nameTextFieldHeightAnchor?.isActive = true

    }

    
    func setUpFieldSperatorConstraint() {
    
        inputsContainerView.addSubview(fieldSperator)
        firstSepratoprHeightAnchor = fieldSperator.heightAnchor.constraint(equalToConstant: 1)
        firstSepratoprHeightAnchor?.isActive = true
        fieldSperator.topAnchor.constraint(equalTo: nameTextField.bottomAnchor).isActive = true
        fieldSperator.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 15).isActive = true
        fieldSperator.rightAnchor.constraint(equalTo: inputsContainerView.rightAnchor, constant: -15).isActive = true
    
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func setUpMailTextField() {
        
        inputsContainerView.addSubview(mailTextField)
        mailTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 15).isActive = true
        mailTextField.rightAnchor.constraint(equalTo: inputsContainerView.rightAnchor, constant: -15).isActive = true
        mailTextField.topAnchor.constraint(equalTo: nameTextField.bottomAnchor , constant: 1).isActive = true
        mailTextFieldHeightAnchor = mailTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/3)
        mailTextFieldHeightAnchor?.isActive = true
    }
    
    
    func setUpPasswordTextField() {
        
        inputsContainerView.addSubview(passwordTextField)
        passwordTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 15).isActive = true
        passwordTextField.rightAnchor.constraint(equalTo: inputsContainerView.rightAnchor, constant: -15).isActive = true
        passwordTextField.topAnchor.constraint(equalTo: mailTextField.bottomAnchor , constant: 1).isActive = true
        passwordTextFieldHeightAnchor = passwordTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/3)
        passwordTextFieldHeightAnchor?.isActive = true
    }
    
    
    func setUpfieldSperator2Constraints() {
        
        inputsContainerView.addSubview(fieldSperator2)
        fieldSperator2.heightAnchor.constraint(equalToConstant: 1).isActive = true
        fieldSperator2.topAnchor.constraint(equalTo: mailTextField.bottomAnchor).isActive = true
        fieldSperator2.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 15).isActive = true
        fieldSperator2.rightAnchor.constraint(equalTo: inputsContainerView.rightAnchor, constant: -15).isActive = true
    
    }
    
    
    func setUpRegisterButtonConstraints() {
        
        registerButton.topAnchor.constraint(equalTo: inputsContainerView.bottomAnchor, constant : 10).isActive = true
        registerButton.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
        registerButton.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -24).isActive = true
        registerButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
    }
    
    
    func setUpsegmantedControllerConstraint() {
        
        segmantedController.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor, multiplier: 1).isActive = true
        segmantedController.heightAnchor.constraint(equalToConstant: 36).isActive = true
        segmantedController.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
        segmantedController.topAnchor.constraint(equalTo: userProfileImageView.bottomAnchor, constant: 32).isActive = true
        
    }
    
    
    func imageVWConstraint() {
        
        NSLayoutConstraint.activate([
            userProfileImageView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 16)
            ,userProfileImageView.widthAnchor.constraint(equalToConstant: 150)
            ,userProfileImageView.heightAnchor.constraint(equalToConstant: 150)
            ,userProfileImageView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor)
            ])
    }
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle  {
        return .lightContent
    }

}


extension LoginLogoutViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var picker : UIImagePickerController {
        let pc = UIImagePickerController()
        pc.delegate = self
        pc.sourceType = .photoLibrary
        pc.allowsEditing = true
        return pc
    }
    
    @objc func handleProfileImagePicker() {
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // Local variable inserted by Swift 4.2 migrator.
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)
        
        if let editedImage = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.editedImage)] as? UIImage{
            userProfileImageView.image = editedImage
        } else {
            if let originalImage = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as? UIImage {
                userProfileImageView.image = originalImage
            }
        }
    }
    
    @objc func handelLoginLogout() {
        if segmantedController.selectedSegmentIndex == 1 {
            handleRegestiration()
        } else{
            handleLogin()
        }
    }
    
    
    func handleLogin() {
        guard let email = mailTextField.text, let password = passwordTextField.text else { return }
        presenter.handleLogin(email: email, password: password)
    }
    
    
    func handleRegestiration() {
        guard let email = mailTextField.text, let password = passwordTextField.text, let name = nameTextField.text else { return }
        guard let imageData = self.userProfileImageView.image!.jpegData(compressionQuality: 0.9) else { return }
        presenter.handleRegisteration(email: email, password: password, name: name, imageData: imageData)
    }
    
    func dismiss() {
        dismiss(animated: true, completion: nil)
    }
    
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
    return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
    return input.rawValue
}
