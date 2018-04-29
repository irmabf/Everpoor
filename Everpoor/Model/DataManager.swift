//
//  DataManager.swift
//  Everpobre
//
//  Created by Joaquin Perez on 12/03/2018.
//  Copyright © 2018 Joaquin Perez. All rights reserved.
//

import UIKit
import CoreData

class DataManager: NSObject {
    
    static let sharedManager = DataManager()
    
    
    lazy var persistentContainer: NSPersistentContainer = {

        let container = NSPersistentContainer(name: "Everpoor")
        container.loadPersistentStores(completionHandler: { (storeDescription,error) in
            
            if let err = error {
                // Error to handle.
                print(err)
            }
        container.viewContext.automaticallyMergesChangesFromParent = true
        })
        return container
    }()
    



}
