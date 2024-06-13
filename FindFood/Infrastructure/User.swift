//
//  User.swift
//  FindFood
//
//  Created by 劉子瑜-20001220 on 2024/6/13.
//

import UIKit

struct User {
    let name: String
    let image: URL?
    let idToken: String

    init(name: String, image: URL?, idToken: String) {
        self.name = name
        self.image = image
        self.idToken = idToken
    }
}
