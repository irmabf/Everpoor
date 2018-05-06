//
//  UINotebooksTableViewController.swift
//  Everpoor
//
//  Created by Joaquin Perez on 03/05/2018.
//  Copyright © 2018 Joaquin Perez. All rights reserved.
//

import UIKit
import CoreData

class NotebooksTableViewController: UITableViewController {
    
    var notebooks:[Notebook] = []
    
    var isToSelect = false
    
    var completionBlock:((Notebook)->Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewNotebook))
        
        
        
        if isToSelect {
            title = NSLocalizedString("Select Notebook", comment: "")
        } else {
            title = NSLocalizedString("Manage Notebooks", comment: "")
        }
        
        if !isToSelect && self.modalPresentationStyle == .fullScreen
        {
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(closeViewController))
           
        }

    }



    // MARK: - Table view data source


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
     
        return notebooks.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "NotebookReuseIdentifier")
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "NotebookReuseIdentifier")
            cell?.selectionStyle = .none
        }
        let notebook = notebooks[indexPath.row]
        cell?.textLabel?.text = notebook.name
        if notebook.isDefault {
            cell?.accessoryType = .checkmark
        } else {
            cell?.accessoryType = .none
        }

        return cell!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isToSelect {
            self.completionBlock!(notebooks[indexPath.row])
            self.dismiss(animated: true, completion: nil)
        }
    }
 

  
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if isToSelect { return false }
        
       let notebook = notebooks[indexPath.row]
        return !notebook.isDefault
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete
        {
            
        }
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let changeNameAction = UITableViewRowAction(style: .normal, title: NSLocalizedString("ChangeName", comment: "")) { (tableViewRowAction, indexPath) in
            let notebook = self.notebooks[indexPath.row]
            self.createOrEditedNotebook(notebook: notebook, isNew: false)
            
        }
        let makeAsDefaultAction = UITableViewRowAction(style: .normal, title: NSLocalizedString("Make default", comment: "")) { (tableViewAction, indexPath) in
            self.makeADefaul(notebook: self.notebooks[indexPath.row])
        }
        
        
        
        let deleteAction = UITableViewRowAction(style: .destructive, title: NSLocalizedString("Delete", comment: "")) { (tableViewAction, indexPath) in
            self.deleteNotebook(self.notebooks[indexPath.row])
        }
        
       
       return [deleteAction,makeAsDefaultAction,changeNameAction,]
    }
  



    // MARK: UIBarButtons Actions
    
    @objc func addNewNotebook()  {

        createOrEditedNotebook(notebook: nil, isNew: true)
        
    }
    
    func createOrEditedNotebook(notebook:Notebook?, isNew:Bool)
    {
        var title = NSLocalizedString("New Notebook", comment: "")
        if isNew == false {
            title = NSLocalizedString("Change Notebook Name", comment: "")
        }
        let actionAlertController = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        actionAlertController.addTextField { (textField) in
            if isNew {
            textField.placeholder = NSLocalizedString("Enter name", comment: "")
            }
            else {
                textField.text = notebook?.name
            }
        }
        var actionTitle = NSLocalizedString("Change", comment: "")
        if isNew {
            actionTitle = NSLocalizedString("Create", comment: "")
        }
        
        actionAlertController.addAction(UIAlertAction(title: actionTitle, style: .default, handler: { (alert) in
            if let text = actionAlertController.textFields![0].text
            {
               if !text.isEmpty
               {
                let privateMOC = DataManager.sharedManager.persistentContainer.newBackgroundContext()
                
                if isNew {
                    privateMOC.perform {
                        
                        let notebook = NSEntityDescription.insertNewObject(forEntityName: "Notebook", into: privateMOC) as! Notebook
                        
                        notebook.name = text
                        
                        try! privateMOC.save()
                        
                        DispatchQueue.main.async {
                        self.notebooks.append(DataManager.sharedManager.persistentContainer.viewContext.object(with: notebook.objectID) as! Notebook)
                            self.tableView.reloadData()
                        }

                }
                }
                else {

                        privateMOC.perform {
                            let backNotebook = privateMOC.object(with: (notebook?.objectID)!) as! Notebook
                            backNotebook.name = text
                            try! privateMOC.save()
                            
                            DispatchQueue.main.async {
                                
                                self.tableView.reloadData()
                            }
                        }
               
                }
                
               }
            }
        }))
        
        actionAlertController.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil))
        self.present(actionAlertController, animated: true, completion: nil)
    }
    
    @objc func closeViewController()
    {
       self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: Swipe bottons
    
    func makeADefaul(notebook:Notebook)  {
      
        let privateMOC = DataManager.sharedManager.persistentContainer.newBackgroundContext()
        
        let currentDefault = notebooks.first
        privateMOC.perform {
            let backNotebook = privateMOC.object(with: notebook.objectID) as! Notebook
            let backCurrentDefault = privateMOC.object(with: (currentDefault?.objectID)!) as! Notebook
        
            backNotebook.isDefault = true
            backCurrentDefault.isDefault = false
            try! privateMOC.save()
            
            DispatchQueue.main.async {
                self.notebooks = self.notebooks.sorted(by: { (notebook1, notebook2) -> Bool in
                    if notebook1.isDefault
                    {
                        return true
                    }
                    else if notebook2.isDefault
                    {
                        return false
                    }
                    else
                    {
                        return notebook1.name! < notebook2.name!
                    }
                })
                self.tableView.reloadData()
            }
        }
    }
    
    func deleteNotebook(_ notebook:Notebook)  {
        
        func delete(book:Notebook)
        {
            DispatchQueue.main.async {
            self.notebooks.remove(at: self.notebooks.index(of: book)!)
            self.tableView.reloadData()
            }
            let privateMOC = DataManager.sharedManager.persistentContainer.newBackgroundContext()
            privateMOC.perform {
                let backNotebook = privateMOC.object(with: (notebook.objectID)) as! Notebook
                privateMOC.delete(backNotebook)
                try! privateMOC.save()
            }
            
        }
        let numberOfNotes = notebook.notes?.count ?? 0
        if numberOfNotes == 0 {
            delete(book: notebook)
        }
        else {
            let actionAlertController = UIAlertController(title: NSLocalizedString("This notebook has notes", comment: ""), message: NSLocalizedString("You can move all notes to default notebook before delete or delete them", comment: ""), preferredStyle: .alert)
            
            actionAlertController.addAction(UIAlertAction(title: NSLocalizedString("Move notes before delete", comment: ""), style: .default, handler: { (alertAction) in
                
                let privateMOC = DataManager.sharedManager.persistentContainer.newBackgroundContext()
                let currentDefault = self.notebooks.first
                privateMOC.perform {
                    let backNotebook = privateMOC.object(with: notebook.objectID) as! Notebook
                    let backCurrentDefault = privateMOC.object(with: (currentDefault?.objectID)!) as! Notebook
                    
                    backCurrentDefault.addToNotes(backNotebook.notes!)
                    try! privateMOC.save()
                    
                    delete(book: notebook)
                }
                
            }))
            actionAlertController.addAction(UIAlertAction(title: NSLocalizedString("Delete All", comment: ""), style: .default, handler: { (alertAction) in
                delete(book: notebook)
            }))
            actionAlertController.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil))
            self.present(actionAlertController, animated: true, completion: nil)
            
        }
        
    }

}
