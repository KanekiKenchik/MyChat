//
//  ViewController.swift
//  MyChat
//
//  Created by Афанасьев Александр Иванович on 16.08.2022.
//

import UIKit
import FirebaseAuth
import SnapKit
import ProgressHUD

class LogInViewController: UIViewController {
    
    static let shared = LogInViewController()
    
    private let label: UILabel = {
        let lbl = UILabel()
        lbl.text = "Sign In"
        lbl.font = UIFont(name: "Avenir", size: 35)
        lbl.textAlignment = .center
        return lbl
    }()
    
    private let emailLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = ""
        lbl.font = UIFont(name: "Avenir", size: 20)
        lbl.textColor = .lightGray
        lbl.textAlignment = .left
        return lbl
    }()
    
    private let emailField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Email"
        tf.borderStyle = .none
        return tf
    }()
    
    private let passwordLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = ""
        lbl.font = UIFont(name: "Avenir", size: 20)
        lbl.textColor = .lightGray
        lbl.textAlignment = .left
        return lbl
    }()
    
    private let passwordField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Password"
        tf.borderStyle = .none
        tf.isSecureTextEntry = true
        return tf
    }()
    
    private let repeatPasswordLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = ""
        lbl.font = UIFont(name: "Avenir", size: 20)
        lbl.textColor = .lightGray
        lbl.textAlignment = .left
        return lbl
    }()
    
    private let repeatPasswordField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Repeat password"
        tf.borderStyle = .none
        tf.isSecureTextEntry = true
        return tf
    }()
    
    private let emailView: UIView = {
        let sv = UIView()
        sv.backgroundColor = .systemGray
        return sv
    }()
    
    private let passwordView: UIView = {
        let sv = UIView()
        sv.backgroundColor = .systemGray
        return sv
    }()
    
    private let repeatPasswordView: UIView = {
        let sv = UIView()
        sv.backgroundColor = .systemGray
        return sv
    }()
    
    private let stackView = UIStackView()
    
    private let forgotPasswordBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle("Forgot password?", for: .normal)
        btn.setTitleColor(UIColor.darkGray, for: .normal)
        btn.titleLabel?.font = UIFont(name: "Avenir", size: 15)
        return btn
    }()
    
    private let resendEmailBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle("Resend email", for: .normal)
        btn.setTitleColor(UIColor.darkGray, for: .normal)
        btn.titleLabel?.font = UIFont(name: "Avenir", size: 15)
        btn.isHidden = true
        return btn
    }()
    
    private let loginBtn: UIButton = {
        let btn = UIButton(type: .custom)
        if let image = UIImage(named: "loginBtn.png") {
            btn.setImage(image, for: .normal)
        }
        return btn
    }()
    
    private let haveAnAccountQuestionLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Don't have an account?"
        lbl.font = UIFont(name: "Avenir", size: 16)
        lbl.textColor = .lightGray
        lbl.textAlignment = .left
        return lbl
    }()
    
    private let signUpInBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle("Sign up", for: .normal)
        btn.setTitleColor(UIColor.darkGray, for: .normal)
        btn.titleLabel?.font = UIFont(name: "Avenir", size: 16)
        return btn
    }()
    
    private let bottomStackView = UIStackView()
    
    private var isLogin = true

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        
    }
    
    private func setupViews() {
        
        setupBackgroundTap()
        
        updateUIFor(login: true)
        
        view.backgroundColor = .secondarySystemBackground
        
        view.addSubview(label)
        view.addSubview(forgotPasswordBtn)
        view.addSubview(resendEmailBtn)
        view.addSubview(loginBtn)
        
        label.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(50)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.5)
        }
        
        configureStackView()
        
        forgotPasswordBtn.snp.makeConstraints { make in
            make.top.equalTo(stackView.snp.bottom).offset(10)
            make.left.equalTo(stackView)
        }
        
        resendEmailBtn.snp.makeConstraints { make in
            make.top.equalTo(stackView.snp.bottom).offset(10)
            make.right.equalTo(stackView)
        }
        
        loginBtn.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(forgotPasswordBtn.snp.bottom).offset(20)
        }
        
        loginBtn.addTarget(self, action: #selector(loginBtnPressed), for: .touchUpInside)
        resendEmailBtn.addTarget(self, action: #selector(resendEmailBtnPressed), for: .touchUpInside)
        forgotPasswordBtn.addTarget(self, action: #selector(forgotPasswordBtnPressed), for: .touchUpInside)
        
        configureBottomStackView()
        
        setUpTextFieldDelegates()
        
    }

    private func configureStackView() {
        view.addSubview(stackView)
        
        stackView.axis = .vertical
        stackView.spacing = 8
        
        emailLabel.snp.makeConstraints { make in
            make.height.equalTo(20)
        }
        
        passwordLabel.snp.makeConstraints { make in
            make.height.equalTo(20)
        }
        
        repeatPasswordLabel.snp.makeConstraints { make in
            make.height.equalTo(20)
        }
        
        emailView.snp.makeConstraints { make in
            make.height.equalTo(2)
        }
        
        passwordView.snp.makeConstraints { make in
            make.height.equalTo(2)
        }
        
        repeatPasswordView.snp.makeConstraints { make in
            make.height.equalTo(2)
        }
        
        stackView.addArrangedSubview(emailLabel)
        stackView.addArrangedSubview(emailField)
        stackView.addArrangedSubview(emailView)
        stackView.addArrangedSubview(passwordLabel)
        stackView.addArrangedSubview(passwordField)
        stackView.addArrangedSubview(passwordView)
        stackView.addArrangedSubview(repeatPasswordLabel)
        stackView.addArrangedSubview(repeatPasswordField)
        stackView.addArrangedSubview(repeatPasswordView)
        
        stackView.snp.makeConstraints { make in
            make.width.equalToSuperview().multipliedBy(0.9)
            make.centerX.equalToSuperview()
            make.top.equalTo(label.snp.bottom).offset(10)
        }
    }
    
    private func configureBottomStackView() {
        view.addSubview(bottomStackView)
        
        signUpInBtn.addTarget(self, action: #selector(signUpInBtnPressed(_:)), for: .touchUpInside)
        
        bottomStackView.axis = .horizontal
        bottomStackView.spacing = 10
        
        bottomStackView.addArrangedSubview(haveAnAccountQuestionLabel)
        bottomStackView.addArrangedSubview(signUpInBtn)
        
        bottomStackView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-30)
        }
    }
    
    @objc private func signUpInBtnPressed(_ button: UIButton) {
        updateUIFor(login: button.titleLabel?.text == "Log In")
        isLogin.toggle()
    }
    
    @objc private func loginBtnPressed() {
        
        if isDataInputedFor(type: isLogin ? "login" : "registration") {
            isLogin ? logInUser() : registerUser()
        } else {
            ProgressHUD.showFailed("All fields are required")
        }
        
    }
    
    @objc private func forgotPasswordBtnPressed() {
        
        if isDataInputedFor(type: "password") {
            resetPassword()
        } else {
            ProgressHUD.showFailed("Email is required")
        }
        
    }
    
    @objc private func resendEmailBtnPressed() {
        if isDataInputedFor(type: "password") {
            resendVerificationEmail()
        } else {
            ProgressHUD.showFailed("Email is required")
        }
    }
    
    private func setUpTextFieldDelegates() {
        emailField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        passwordField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        repeatPasswordField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }

    @objc private func textFieldDidChange(_ textField: UITextField) {
        
        updatePlaceholderLabels(textField: textField)
        
    }
    
    private func setupBackgroundTap() {
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(backgroundTap))
        view.addGestureRecognizer(tapGesture)
        
    }
    
    @objc private func backgroundTap() {
        view.endEditing(false)
    }
    
    //MARK: - Animations
    
    private func updateUIFor(login: Bool) {
        
        loginBtn.setImage(UIImage(named: login ? "loginBtn" : "registerBtn"), for: .normal)
        signUpInBtn.setTitle(login ? "Sign up" : "Log In", for: .normal)
        haveAnAccountQuestionLabel.text = login ? "Don't have an account?" : "Have an account?"
        label.text = login ? "Sign In" : "Sign Up"
        
        UIView.animate(withDuration: 0.5) { [weak self] in
            self?.repeatPasswordField.isHidden = login
            self?.repeatPasswordView.isHidden = login
            self?.repeatPasswordLabel.isHidden = login
        }
        
    }
    
    private func updatePlaceholderLabels(textField: UITextField) {
        
        switch textField {
        case emailField:
            emailLabel.text = textField.hasText ? "Email" : ""
        case passwordField:
            passwordLabel.text = textField.hasText ? "Password" : ""
        default:
            repeatPasswordLabel.text = textField.hasText ? "Repeat password" : ""
            
        }
        
    }
    
    
    //MARK: - Helpers
    
    private func isDataInputedFor(type: String) -> Bool {
        
        switch type {
        case "login":
            return emailField.text != "" && passwordField.text != ""
        case "registraion":
            return emailField.text != "" && passwordField.text != "" && repeatPasswordField.text != ""
        default:
            return emailField.text != ""
        }
        
    }
    
    private func registerUser() {
        
        if passwordField.text! == repeatPasswordField.text! {
            
            FirebaseUserListener.shared.registerUserWith(email: emailField.text!, password: passwordField.text!) { error in
                
                if error == nil {
                    ProgressHUD.showSuccess("Verification email was sent")
                    self.resendEmailBtn.isHidden = false
                } else {
                    ProgressHUD.showFailed(error?.localizedDescription)
                }
                
            }
            
        } else {
            ProgressHUD.showFailed("The passwords don't match")
        }
        
    }
    
    private func logInUser() {
        
        FirebaseUserListener.shared.loginUserWith(email: emailField.text!, password: passwordField.text!) { error, isEmailVerified in
            
            if error == nil {
                if isEmailVerified {
                    self.goToApp()
                } else {
                    ProgressHUD.showFailed("Please verify your email")
                    self.resendEmailBtn.isHidden = false
                }
            } else {
                ProgressHUD.showFailed(error!.localizedDescription)
            }
            
        }
        
    }
    
    private func resetPassword() {
        
        FirebaseUserListener.shared.resetPasswordFor(email: emailField.text!) { error in
            
            if error == nil {
                ProgressHUD.showSuccess("Reset link sent to your email")
            } else {
                ProgressHUD.showFailed(error!.localizedDescription)
            }
        }
        
    }
    
    private func resendVerificationEmail() {
        FirebaseUserListener.shared.resendVerificationEmail(email: emailField.text!) { error in
            
            if error == nil {
                ProgressHUD.showSuccess("New verification link sent to your email")
            } else {
                ProgressHUD.showFailed(error!.localizedDescription)
                print(error!.localizedDescription)
            }
            
        }
    }
    
    
    //MARK: - Navigation
    
    private func goToApp() {
        
        setupTabBarAppearance()
        setupNavBarAppearance()
        
        let tabBarVC = UITabBarController()
        
        let vc1 = UINavigationController(rootViewController: RecentsViewController())
        let vc2 = UINavigationController(rootViewController: ChannelsViewController())
        let vc3 = UINavigationController(rootViewController: UsersViewController())
        let vc4 = UINavigationController(rootViewController: SettingsViewController())
        
        tabBarVC.setViewControllers([vc1, vc2, vc3, vc4], animated: false)
        
        guard let items = tabBarVC.tabBar.items else { return }
        
        let images = ["message", "quote.bubble", "person.2", "gear"]
        let titles = ["Messages", "Channels", "Users", "Settings"]
        
        for i in 0..<items.count {
            items[i].image = UIImage(systemName: images[i])
            items[i].title = titles[i]
        }
        
        tabBarVC.modalPresentationStyle = .fullScreen
        present(tabBarVC, animated: true, completion: nil)
    }
    
    public func setupTabBarAppearance() {
        
        if #available(iOS 13.0, *) {
            let tabBarAppearance = UITabBarAppearance()
            tabBarAppearance.configureWithDefaultBackground()
//            tabBarAppearance.backgroundColor = <your tint color>
            UITabBar.appearance().standardAppearance = tabBarAppearance

            if #available(iOS 15.0, *) {
                UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
            }
        }
        
    }
    
    public func setupNavBarAppearance() {
        if #available(iOS 13.0, *) {
            let navBarAppearance = UINavigationBarAppearance()
            navBarAppearance.configureWithDefaultBackground()
    //        appearance.backgroundColor = <your tint color>
            UINavigationBar.appearance().standardAppearance = navBarAppearance

            if #available(iOS 15.0, *) {
                UINavigationBar.appearance().scrollEdgeAppearance = navBarAppearance
            }
        }
        
    }
    
}

