//
//  HelperFileManager.swift
//  Mes Listes
//
//  Created by Anastasiia Tanczak on 09/03/2019.
//  Copyright © 2019 Ana Viktoriv. All rights reserved.
//

import Foundation
import UIKit

class HelperFileManager {
    
    let fileManager = FileManager.default
    
    
    func deleteImageFromDirectory (named name: String) {
        let imagePath = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(name)
        if fileManager.fileExists(atPath: imagePath) {
            do {
                try fileManager.removeItem(atPath: imagePath)
            } catch {
                print(error)
            }
        }
    }
    
    func saveImageToDocumentDirectory (named image: UIImage, for itemID: String) -> String {
        
        //get the url for the users home directory
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        let nameForImage = "\(itemID).png"
        
        //create the variable that stores the name
        let filePath = documentsURL.appendingPathComponent("\(nameForImage)")
        
        //write data
        do {
            try UIImage.pngData(image)()!.write(to: filePath)
        } catch {
            print(error)
        }
        return nameForImage
    }
    
    func getImage(imageName : String)-> UIImage {
        // Here using getDirectoryPath method to get the Directory path
        let imagePath = (self.getDirectoryPath() as NSString).appendingPathComponent(imageName)
        if fileManager.fileExists(atPath: imagePath){
            return UIImage(contentsOfFile: imagePath)!
        }else{
            print("No Image available")
            ///TODO: create placeholder image and place it here
            return UIImage.init(named: "placeholder.png")! // Return placeholder image here
        }
    }
    
    func getDirectoryPath() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
}
