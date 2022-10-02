//
//  SceneDelegate.swift
//  MyChat
//
//  Created by Афанасьев Александр Иванович on 16.08.2022.
//

import UIKit
import FirebaseAuth

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var authListener: AuthStateDidChangeListenerHandle?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = LogInViewController()
        window.makeKeyAndVisible()
        self.window = window
        
        autoLogin()
        
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }

    //MARK: - Autologin
    func autoLogin() {
        
        authListener = Auth.auth().addStateDidChangeListener({ auth, user in
            
            Auth.auth().removeStateDidChangeListener(self.authListener!)
            
            if user != nil && userDef.object(forKey: kCURRENTUSER) != nil {
                
                DispatchQueue.main.async {
                    self.goToApp()
                }
                
            }
            
        })
    }
    
    private func goToApp() {
        
        LogInViewController.shared.setupTabBarAppearance()
        LogInViewController.shared.setupNavBarAppearance()
        
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
        self.window?.rootViewController?.present(tabBarVC, animated: true, completion: nil)
    }

}

