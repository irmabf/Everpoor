//
//  NoteViewController.swift
//  Everpoor
//
//  Created by Joaquin Perez on 29/04/2018.
//  Copyright © 2018 Joaquin Perez. All rights reserved.
//

import UIKit

class NoteViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate {
    
    let dateLabel = UILabel()
    let expirationDate = UILabel()
    let titleTextField = UITextField()
    let noteTextView = UITextView()
    
    var note: Note!
    
    let dateFormatter = { () -> DateFormatter in
        let dateF = DateFormatter()
        dateF.dateStyle = .short  // Usar este tipo nos garantiza la localización.
        dateF.timeStyle = .none
        return dateF
    }()
    
    override func loadView() {
        
        let backView = UIView()
        backView.backgroundColor = .white
        
        backView.addSubview(dateLabel)
        backView.addSubview(expirationDate)
        
        backView.addSubview(titleTextField)
        titleTextField.delegate = self
        
        backView.addSubview(noteTextView)
        noteTextView.delegate = self
        
        // MARK: Autolayout.
    
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        noteTextView.translatesAutoresizingMaskIntoConstraints = false
        titleTextField.translatesAutoresizingMaskIntoConstraints = false
        expirationDate.translatesAutoresizingMaskIntoConstraints = false
        
        let viewDict = ["dateLabel":dateLabel,"noteTextView":noteTextView,"titleTextField":titleTextField,"expirationDate":expirationDate]
        
        // Horizontals
        var constraints = NSLayoutConstraint.constraints(withVisualFormat: "|-10-[titleTextField]-10-[expirationDate]-10-[dateLabel]-10-|", options: [], metrics: nil, views: viewDict)
        constraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "|-10-[noteTextView]-10-|", options: [], metrics: nil, views: viewDict))
        
        // Verticals
        
        constraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "V:[dateLabel]-10-[noteTextView]-10-|", options: [], metrics: nil, views: viewDict))
        
        constraints.append(NSLayoutConstraint(item: dateLabel, attribute: .top, relatedBy: .equal, toItem: backView.safeAreaLayoutGuide, attribute: .top, multiplier: 1, constant: 10))
        
        constraints.append(NSLayoutConstraint(item: titleTextField, attribute: .lastBaseline, relatedBy: .equal, toItem: dateLabel, attribute: .lastBaseline, multiplier: 1, constant: 0))
        
        constraints.append(NSLayoutConstraint(item: expirationDate, attribute: .lastBaseline, relatedBy: .equal, toItem: dateLabel, attribute: .lastBaseline, multiplier: 1, constant: 0))
        
        backView.addConstraints(constraints)
        
        self.view = backView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        titleTextField.text = note.title
        noteTextView.text = note.content
        dateLabel.text = dateFormatter.string(from: Date(timeIntervalSince1970: note.createdAtTI))
        
        // MARK: Gestures
        
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(closeKeyboard))
        swipeGesture.direction = .down
        
        view.addGestureRecognizer(swipeGesture)
        
    }
    
    @objc func closeKeyboard()
    {
        
        if noteTextView.isFirstResponder
        {
            noteTextView.resignFirstResponder()
        }
        else if titleTextField.isFirstResponder
        {
            titleTextField.resignFirstResponder()
        }
    }
    
    // MARK: TextField Delegate
    func textFieldDidEndEditing(_ textField: UITextField)
    {
        let newText = textField.text ?? ""
        if newText.count > 0
        {
        let privateMOC = DataManager.sharedManager.persistentContainer.newBackgroundContext()
        privateMOC.perform {
            let privateNote = privateMOC.object(with: self.note.objectID) as! Note
            privateNote.title = newText
            try! privateMOC.save()
        }
        }
    }

    // MARK: TextView Delegate
    func textViewDidEndEditing(_ textView: UITextView)
    {
        let newText = textView.text ?? ""
            let privateMOC = DataManager.sharedManager.persistentContainer.newBackgroundContext()
            privateMOC.perform {
                let privateNote = privateMOC.object(with: self.note.objectID) as! Note
                privateNote.content = newText
                try! privateMOC.save()
            }
       
    }
    



}
