//
//  NoteViewController.swift
//  Everpoor
//
//  Created by Joaquin Perez on 29/04/2018.
//  Copyright © 2018 Joaquin Perez. All rights reserved.
//

import UIKit
import CoreData

class NoteViewController: UIViewController, UITextFieldDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate {
    
    let dateLabel = UILabel()
    let expirationDate = UILabel()
    let titleTextField = UITextField()
    let noteTextView = UITextView()
    
    var imageViews:[UIImageView] = []
    
    var note: Note!
    
    let dateFormatter = { () -> DateFormatter in
        let dateF = DateFormatter()
        dateF.dateStyle = .short  // Usar este tipo nos garantiza la localización.
        dateF.timeStyle = .none
        return dateF
    }()
    
    var relativePoint = CGPoint.zero
    
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
        
        if let pictures = note.pictures as? Set<Picture> {
            for picture  in pictures {
                addNewImage(UIImage(data: picture.imgData!)!, tag: Int(picture.tag), relativeX: picture.x, relativeY: picture.y)
            }
        }
        
        // MARK: Toolbar
        
         navigationController?.isToolbarHidden = false
        
        let photoBarButton = UIBarButtonItem(title: NSLocalizedString("Add image", comment: "ToolbarButton"), style: .plain, target: self, action: #selector(catchPhoto))
            
        let flexible = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        let mapBarButton = UIBarButtonItem(title: NSLocalizedString("Add Location", comment: "ToolbarButton"), style: .plain, target: self, action: #selector(addLocation))
        
        self.setToolbarItems([photoBarButton,flexible,mapBarButton], animated: false)
        
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
    
    // MARK: Toolbar Buttons actions
    
    @objc func catchPhoto()
    {
        let actionSheetAlert = UIAlertController(title: NSLocalizedString("Add image", comment: "Action Sheet title"), message: nil, preferredStyle: .actionSheet)
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        let useCamera = UIAlertAction(title: NSLocalizedString("Camera", comment: "Action Sheet Value"), style: .default) { (alertAction) in
            imagePicker.sourceType = .camera
            self.present(imagePicker, animated: true, completion: nil)
        }
        
        let usePhotoLibrary = UIAlertAction(title: NSLocalizedString("Photo Library", comment: "Action Sheet Value"), style: .default) { (alertAction) in
            imagePicker.sourceType = .photoLibrary
            self.present(imagePicker, animated: true, completion: nil)
        }
        let cancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .destructive, handler: nil)
        
        actionSheetAlert.addAction(useCamera)
        actionSheetAlert.addAction(usePhotoLibrary)
        actionSheetAlert.addAction(cancel)
        
        
        
        present(actionSheetAlert, animated: true, completion: nil)
    }
    
    @objc func addLocation()
    {
        
    }
    
    // MARK: Image Picker Delegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        let currentImages = note.pictures?.count ?? 0
        let tag = currentImages + 1
        
        let xRelative = Double(tag*10) / Double(UIScreen.main.bounds.width)
        let yRelative = Double(tag*10) / Double(UIScreen.main.bounds.height)

        let backMOC = DataManager.sharedManager.persistentContainer.newBackgroundContext()
        
        backMOC.perform {
            
            let picture = NSEntityDescription.insertNewObject(forEntityName: "Picture", into: backMOC) as! Picture
            
            picture.x = xRelative
            picture.y = yRelative
            picture.tag = Int64(tag)
            picture.imgData = UIImagePNGRepresentation(image)
            
            picture.note = (backMOC.object(with: self.note.objectID) as! Note)
            
            try! backMOC.save()
        }
        addNewImage(image, tag: tag, relativeX: xRelative, relativeY: yRelative)
        
        picker.dismiss(animated: true, completion: nil)
        
    }
    


}
