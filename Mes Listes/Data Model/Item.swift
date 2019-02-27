//
//  Item.swift
//  Mes Listes
//
//  Created by Anastasiia Tanczak on 24/06/2018.
//  Copyright © 2018 Ana Viktoriv. All rights reserved.
//

import Foundation
import RealmSwift

class Item: Object {
    @objc dynamic var id: String = ""
    @objc dynamic var title: String = ""
    @objc dynamic var done: Bool = false
    @objc dynamic var important: Bool = false
    @objc dynamic var hasImage: Bool = false
    @objc dynamic var imageName = ""
    @objc dynamic var creationDate: Date?
    
var parentListe = LinkingObjects(fromType: Liste.self, property: "items")
}
