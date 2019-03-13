//
//  HelperRealmManager.swift
//  Mes Listes
//
//  Created by Anastasiia Tanczak on 13/03/2019.
//  Copyright © 2019 Ana Viktoriv. All rights reserved.
//

import Foundation
import RealmSwift


class HelperRealmManager {
    
    let realm = try! Realm()
    var lists : Results <Liste>?
    
    
    //saves data into database
    func save(list: Liste) {
        do {
            try realm.write {
                realm.add(list)
            }
        } catch {
            print("Error saving massage\(error)")
        }
    }
    
    //retrieves data from the database
    func loadLists () {
        lists = realm.objects(Liste.self)
        lists = lists?.sorted(byKeyPath: "name", ascending: true)
        
    }
    
    func deleteListAndItsItems(atRow subScript: Int) {
        guard let listes = lists else {return}
        let listForDeletion = listes[subScript]
        let items = listForDeletion.items.sorted(byKeyPath: "title", ascending: true)
        let helperFileManager = HelperFileManager()
        
        do {
            try realm.write {
                for item in items {
                    if item.hasImage {
                        helperFileManager.deleteImageFromDirectory(named: item.imageName)
                    }
                    self.realm.delete(item)
                }
                self.realm.delete(listForDeletion)
            }
        } catch{
            print("Error deleting category\(error)")
        }
    }
    
    func updateIsDone (forListAtRow subScript: Int) {
        if let listeForUpdate = self.lists?[subScript] {
            do {
                try realm.write {
                    listeForUpdate.done = !listeForUpdate.done
                }
            }catch{
                print("error updating relm\(error)")
            }
        }
    }
    
    func changeListName (_ liste: Liste, _ newName: String, _ newIconName: String ) {
        do {
            try realm.write {
                liste.name = newName
                liste.iconName = newIconName
            }
        } catch {
            print("Error saving massage\(error)")
        }
    }
}
