//
//  GSAuthProvider.swift
//  FindFood
//
//  Created by 劉子瑜-20001220 on 2024/6/13.
//

import Foundation
import GoogleSignIn

final class GSAuthProvider: AuthProvider, LogoutProvider {
    var presentViewController: UIViewController

    init(presentViewController: UIViewController) {
        self.presentViewController = presentViewController
    }

    func fetchUser(completion: @escaping (AuthProvider.Result) -> Void) {
        GIDSignIn.sharedInstance.signIn(withPresenting: presentViewController) { signInResult, error in
            guard error == nil else {
                return completion(.failure(.custom(reason: error!)))
            }

            guard let user = signInResult?.user,
                  let profile = user.profile,
                  let token = user.idToken?.tokenString else {
                return completion(.failure(.cannotGetUserInfo))
            }

            completion(.success(User(name: profile.name,
                                     image: profile.imageURL(withDimension: 120),
                                     idToken: token, 
                                     loginType: .google)))
        }
    }
    
    func logoutUser() {
        GIDSignIn.sharedInstance.signOut()
    }
}
