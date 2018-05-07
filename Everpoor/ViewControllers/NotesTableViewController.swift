//
//  NotesTableViewController.swift
//  Everpoor
//
//  Created by Joaquin Perez on 29/04/2018.
//  Copyright © 2018 Joaquin Perez. All rights reserved.
//

import UIKit
import CoreData

class NotesTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
      var fetchedResultController : NSFetchedResultsController<Notebook>!
    
      let defaultNoteSorts = [NSSortDescriptor(key: "title", ascending: true)]

    override func viewDidLoad() {
        super.viewDidLoad()

        let addNote = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewNote))
        
        let addNoteInN = UIBarButtonItem(title: NSLocalizedString("+inBook", comment: ""), style: .plain, target: self, action: #selector(addNoteSelectinNotebbok))
        
        navigationItem.rightBarButtonItems = [addNote,addNoteInN]
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Notebooks", comment: "Notebooks barButton"), style: .plain, target: self, action: #selector(manageNotebooks))
        
        // MARK: Fetch Request.
        
        let viewMOC = DataManager.sharedManager.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<Notebook>(entityName: "Notebook")
        
        let sortByDefault = NSSortDescriptor(key: "isDefault", ascending: false)
        let sortByTitle = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortByDefault,sortByTitle]
        
        fetchedResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: viewMOC, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultController.delegate = self
        
        try! fetchedResultController.performFetch()
        
        if fetchedResultController.fetchedObjects?.count == 0
        {
          // Sólo la primera vez, cuando no hay default. Lo hacemos en el ViewContext porque es indispensable para la App.
            let defaultNotebook = NSEntityDescription.insertNewObject(forEntityName: "Notebook", into: viewMOC) as! Notebook
            defaultNotebook.isDefault = true
            defaultNotebook.name = NSLocalizedString("My Notebook", comment: "Default Notebook Name")
            
            try! viewMOC.save()
            
        }
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTableView), name: Notification.Name.NSManagedObjectContextDidSave, object: nil)
    }


    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return (fetchedResultController.fetchedObjects?.count)!
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let notebook = fetchedResultController.object(at: IndexPath(row: section, section: 0))
        return notebook.notes?.count ?? 0
    }

  
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
     var cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier")
     if cell == nil {
     cell = UITableViewCell(style: .default, reuseIdentifier: "reuseIdentifier")
     }
     let notebook = fetchedResultController.object(at: IndexPath(row: indexPath.section, section: 0))
     let notes = notebook.notes!.sortedArray(using: defaultNoteSorts) as! [Note]
     cell?.textLabel?.text = notes[indexPath.row].title
     
     return cell!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let notebook = fetchedResultController.object(at: IndexPath(row: indexPath.section, section: 0))
        let notes = notebook.notes!.sortedArray(using: defaultNoteSorts) as! [Note]
        let note = notes[indexPath.row]
        
        let noteVC = NoteViewController()
        noteVC.note = note
        
        let detailNavController = UINavigationController(rootViewController: noteVC)
        
        splitViewController?.showDetailViewController(detailNavController, sender: nil)
        
    }
 

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let notebook = fetchedResultController.object(at: IndexPath(row: section, section: 0))
        return notebook.name
    }
    
    // MARK: UIBarButtons Actions

    @objc func addNewNote()  {
        
        let defaultNotebook = fetchedResultController.fetchedObjects!.first!
        addNewNoteToNotebook(defaultNotebook)
    }
    
    func addNewNoteToNotebook(_ notebook:Notebook)  {
        
        let privateMOC = DataManager.sharedManager.persistentContainer.newBackgroundContext()

        privateMOC.perform {
            
            let note = NSEntityDescription.insertNewObject(forEntityName: "Note", into: privateMOC) as! Note
            
            note.title = "Nueva nota"
            note.createdAtTI = Date().timeIntervalSince1970
            note.notebook = (privateMOC.object(with: notebook.objectID) as! Notebook)
            
            try! privateMOC.save()
        }
    }
    
    @objc func addNoteSelectinNotebbok(barButton:UIBarButtonItem)
    {
    let notebookTVC = NotebooksTableViewController(style: .plain)
    notebookTVC.notebooks = fetchedResultController.fetchedObjects!
    notebookTVC.isToSelect = true
    notebookTVC.completionBlock = addNewNoteToNotebook
    let navController = UINavigationController(rootViewController: notebookTVC)
    navController.modalPresentationStyle = UIModalPresentationStyle.popover
    let popOverCont = navController.popoverPresentationController
    popOverCont?.barButtonItem = barButton
        
    present(navController, animated: true, completion: nil)
        
    }
    
    @objc func manageNotebooks(barButton:UIBarButtonItem)
    {
        let notebookTVC = NotebooksTableViewController(style: .plain)
        notebookTVC.notebooks = fetchedResultController.fetchedObjects!
        let navController = UINavigationController(rootViewController: notebookTVC)
        navController.modalPresentationStyle = UIModalPresentationStyle.popover
        let popOverCont = navController.popoverPresentationController
        popOverCont?.barButtonItem = barButton
        
        present(navController, animated: true, completion: nil)
    }
    
    // MARK: fetchedResultController Delegate
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {

        tableView.reloadData()
    }
    
    @objc func reloadTableView() {
        
        DispatchQueue.main.async {
        self.tableView.reloadData()
        }
    
    }
    
    

}
