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
     var items : Results <Item>?
    
    let helperFileManager = HelperFileManager()
    
    //saves list into database
    func save(list: Liste) {
        do {
            try realm.write {
                realm.add(list)
            }
        } catch {
            print("Error saving massage\(error)")
        }
    }
    
    //retrieves lists from the database
    func loadLists () {
        lists = realm.objects(Liste.self)
        lists = lists?.sorted(byKeyPath: "name", ascending: true)
        
    }
    
    //deletes lists and items and images associated
    func deleteListAndItsItems(atRow subScript: Int) {
        guard let listes = lists else {return}
        let listForDeletion = listes[subScript]
        let items = listForDeletion.items.sorted(byKeyPath: "title", ascending: true)
        
        
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
    
    //changes done for true to false and vise versa (to stike out)
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
    
    // changes listName
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
    
    //retrieves items from the database
    func loadItems (for list: Liste) {
        items = list.items.sorted(byKeyPath: "creationDate", ascending: true)
       // tableView.reloadData()
    }
    
    // creates item
    func createItem (in list: Liste, named itemTitle: String){
       do {
                try self.realm.write {
                    let newItem = Item()
                    newItem.id = UUID().uuidString
                    newItem.title = itemTitle
                    newItem.creationDate = Date()
                    list.items.append(newItem)
                }
            }catch{
                print("Error saving item\(error)")
            }
    }
    
    //changes title in Item
    func changeItemTitle(for item: Item, newTitle title: String) {
        do {
            try self.realm.write {
                item.title = title
            }
        }catch{
            print("Error saving item\(error)")
        }
    }
    
    func deleteItemFromRealm (at row: Int) {
        if let itemForDeletion = items?[row] {
            
            if itemForDeletion.hasImage {
                helperFileManager.deleteImageFromDirectory(named: itemForDeletion.imageName)
            }
            
            do {
                try self.realm.write {
                    self.realm.delete(itemForDeletion)
                }
            }catch{
                print("Error deleting item\(error)")
            }
        }
    }
    
    func updateIsDoneForItem (at row: Int) {
        if let currentItem = items?[row] {
        do {
            try realm.write {
                currentItem.done = !currentItem.done
            }
        }catch{
            print("error updating realm\(error)")
        }
    }
    }
    
    func saveImageNameAsStringToRealm (named imageName: String, at row: Int){

            if let currentItem = items?[row]{
                do {
                    try realm.write{
                        currentItem.hasImage = true
                        currentItem.imageName = imageName
                    }
                }
                catch{
                    print("error updating realm\(error)")
                }
            }
        }
    }
