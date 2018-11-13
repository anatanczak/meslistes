////
////  SwipeTableViewController.swift
////  RememberIT
////
////  Created by Anastasiia Tanczak on 13/06/2018.
////  Copyright © 2018 Ana Viktoriv. All rights reserved.
////
//
//import UIKit
//import SwipeCellKit
//import UserNotifications
//
//
//
//class SwipeTableViewController: UITableViewController, SwipeTableViewCellDelegate {
//
//    
//    //MARK: - GLOBAL VARIABLES
//    var isSwipeRightEnabled = true
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//     tableView.rowHeight = 80.0
//        
//    }
//    
//    //MARK: - TABLEVIEW DATASOURCE METHODS
//    
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        
//        //initializes the SwipeTableViewCell as the default cell for all of the TableView that inherit from this class
//        
//        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SwipeTableViewCell
//        
//        //makes this class delegate and enables the implementation of all the methods for a swipe cell
//        cell.delegate = self
//
//        return cell
//    }
//    
//    //MARK: - SWIPE CELL METHODS
//    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
//        //guard orientation == .right else { return nil }
//        
//        if orientation == .left {
//            guard isSwipeRightEnabled else { return nil }
//            
//            let strikeOut = SwipeAction(style: .default, title: "") { (action, indexPath) in
//                
//                self.strikeOut(at: indexPath)
//            }
//            
//            let setReminder = SwipeAction(style: .default, title: "") { action, indexPath in
//                
//                self.updateModelByAddingAReminder(at: indexPath)
//                
//            }
//            setReminder.image = UIImage(named: "reminder-icon")
//           
//            
//            let addEventToCalendar = SwipeAction(style: .default, title: "") { (action, indexPath) in
//                
//                self.addEventToCalendar(at: indexPath)
//            }
//             return[strikeOut, setReminder, addEventToCalendar]
//            
//        }else{
//            
//            let createNote = SwipeAction(style: .default, title: "Note") { (action, indexPath) in
//                self.createNote(at: indexPath)
//            }
//            
//            let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
//                
//                self.updateModel(at: indexPath)
//                
//            }
//            // customize the action appearance
//            deleteAction.image = UIImage(named: "delete-icon")
//            return [deleteAction, createNote]
//        }
//        
//    }
//    
//    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeTableOptions {
//        
//        var options = SwipeTableOptions()
//        
//        
//        //diferent expansion styles
//        options.expansionStyle = orientation == .left ? .selection : .destructive
//
//        return options
//    }
//    
//    //MARK: - DIFFERENT FUNCTIONS
//    func updateModel(at indexpath: IndexPath){
//        //Update our data model by deleting things from the database
//    }
//    
//    
//    func updateModelByAddingAReminder(at indexpath: IndexPath){
//        // add time to datamodel
//    }
//    
//    func addEventToCalendar (at indexpath: IndexPath) {
//        // add events to calendar
//    }
//    
//    func strikeOut (at indexPath: IndexPath) {
//        // stike out the text in the cell
//    }
//    
//    func createNote (at indexPath: IndexPath) {
//        //creates a note
//    }
//    
//}


