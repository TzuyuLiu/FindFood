//
//  ManagedUser.swift
//  FindFood
//
//  Created by 劉子瑜-20001220 on 2024/6/20.
//
import CoreData

private class ManagedUser: NSManagedObject {
    @NSManaged var name: String
    @NSManaged var idToken: String
    @NSManaged var image: URL?
    @NSManaged var loginType: String
}
