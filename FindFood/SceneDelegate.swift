//
//  SceneDelegate.swift
//  FindFood
//
//  Created by 劉子瑜-20001220 on 2024/6/13.
//

import UIKit
import GoogleSignIn
import FBSDKCoreKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }
    }

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else {
            return
        }

        setupGoogleLogin(url)
        setupFacebokLogin(url)
    }
}

private extension SceneDelegate {
    func setupGoogleLogin(_ url: URL) {
        GIDSignIn.sharedInstance.handle(url)
    }

    func setupFacebokLogin(_ url: URL) {
        ApplicationDelegate.shared.application(
             UIApplication.shared,
             open: url,
             sourceApplication: nil,
             annotation: [UIApplication.OpenURLOptionsKey.annotation]
         )
    }
}


