//
//  FBAuthProvider.swift
//  FindFood
//
//  Created by 劉子瑜-20001220 on 2024/6/17.
//

import Foundation
import FBSDKLoginKit

final class FBAuthProvider: AuthProvider, LogoutProvider {
    
    func fetchUser(completion: @escaping (AuthProvider.Result) -> Void) {
        let loginManager = LoginManager()

        loginManager.logIn(permissions: ["email", "public_profile"], from: nil) { (result, error) in
            guard error == nil else {
                completion(.failure(.custom(reason: error!)))
                return
            }

            let request = GraphRequest(graphPath: "me", parameters: ["fields": "id, email, name, picture"])

            request.start { _, result, error in
                guard let result = result as? [String: Any] else {
                    completion(.failure(.convertDataFail))
                    return
                }
                guard error == nil else {
                    completion(.failure(.custom(reason: error!)))
                    return
                }

                var picUrl: URL? = nil
                let uid = result["id"] as? String ?? ""
                let name = result["name"] as? String ?? ""
                if let picture = result["picture"] as? [String: Any], let data = picture["data"] as? [String: Any] {
                    picUrl = data["url"] as? URL
                }

                completion(.success(User(name: name, image: picUrl, idToken: uid)))
            }
        }
    }

    func logoutUser() {
        let loginManager = LoginManager()
        loginManager.logOut()
    }
}
