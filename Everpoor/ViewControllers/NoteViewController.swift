//
//  NoteViewController.swift
//  Everpoor
//
//  Created by Joaquin Perez on 29/04/2018.
//  Copyright © 2018 Joaquin Perez. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation

class NoteViewController: UIViewController, UITextFieldDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate, SelectInMapDelegate {
    
    var placemark: CLPlacemark?
    var userAddress: String?
    
    let dateLabel = UILabel()
    let expirationDate = UITextField()
    let titleTextField = UITextField()
    let noteTextView = UITextView()
    
    let locationLabel = UILabel()
    
    
    var note: Note!
    var pictures: [Picture] = []
    var imageViews: [UIImageView] = []
    
    
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
        expirationDate.textAlignment = .center
        
        backView.addSubview(titleTextField)
        titleTextField.delegate = self
        
        backView.addSubview(locationLabel)
        
        backView.addSubview(noteTextView)
        noteTextView.delegate = self
        
        // titles labels:
        let titleLabel = UILabel()
        titleLabel.text = NSLocalizedString("Title", comment: "title note label")
        titleLabel.font = UIFont.systemFont(ofSize: UIFont.smallSystemFontSize)
        backView.addSubview(titleLabel)
        
        let expirationTitleLabel = UILabel()
        expirationTitleLabel.text = NSLocalizedString("Expiration", comment: "Expiration note label")
        expirationTitleLabel.font = UIFont.systemFont(ofSize: UIFont.smallSystemFontSize)

        backView.addSubview(expirationTitleLabel)
        
        let createTitleLabel = UILabel()
        createTitleLabel.text = NSLocalizedString("Created", comment: "Created note label")
        createTitleLabel.font = UIFont.systemFont(ofSize: UIFont.smallSystemFontSize)
        backView.addSubview(createTitleLabel)
        
        
        
        
        // MARK: Autolayout.
    
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        noteTextView.translatesAutoresizingMaskIntoConstraints = false
        titleTextField.translatesAutoresizingMaskIntoConstraints = false
        expirationDate.translatesAutoresizingMaskIntoConstraints = false
        locationLabel.translatesAutoresizingMaskIntoConstraints = false
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        expirationTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        createTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        
        let viewDict = ["dateLabel":dateLabel,"noteTextView":noteTextView,"titleTextField":titleTextField,"expirationDate":expirationDate,"locationLabel":locationLabel,"titleLabel":titleLabel,"expirationTitleLabel":expirationTitleLabel,"createTitleLabel":createTitleLabel]
        
        // Horizontals
        var constraints = NSLayoutConstraint.constraints(withVisualFormat: "|-10-[titleTextField]-10-[expirationDate]-10-[dateLabel]-10-|", options: [], metrics: nil, views: viewDict)
         constraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "|-10-[noteTextView]-10-|", options: [], metrics: nil, views: viewDict))
        constraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "|-10-[locationLabel]-10-|", options: [], metrics: nil, views: viewDict))
        
        constraints.append(NSLayoutConstraint(item: titleLabel, attribute: .left, relatedBy: .equal, toItem: titleTextField, attribute: .left, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: expirationTitleLabel, attribute: .centerX, relatedBy: .equal, toItem: expirationDate, attribute: .centerX, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: createTitleLabel, attribute: .right, relatedBy: .equal, toItem: dateLabel, attribute: .right, multiplier: 1, constant: 0))
        
        
        // Verticals
        
        constraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "V:[dateLabel]-4-[createTitleLabel]-[locationLabel]-[noteTextView]-10-|", options: [], metrics: nil, views: viewDict))
        
        constraints.append(NSLayoutConstraint(item: dateLabel, attribute: .top, relatedBy: .equal, toItem: backView.safeAreaLayoutGuide, attribute: .top, multiplier: 1, constant: 10))
        
        constraints.append(NSLayoutConstraint(item: titleTextField, attribute: .lastBaseline, relatedBy: .equal, toItem: dateLabel, attribute: .lastBaseline, multiplier: 1, constant: 0))
        
        constraints.append(NSLayoutConstraint(item: expirationDate, attribute: .lastBaseline, relatedBy: .equal, toItem: dateLabel, attribute: .lastBaseline, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: titleLabel, attribute: .lastBaseline, relatedBy: .equal, toItem: createTitleLabel, attribute: .lastBaseline, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: expirationTitleLabel, attribute: .lastBaseline, relatedBy: .equal, toItem: createTitleLabel, attribute: .lastBaseline, multiplier: 1, constant: 0))
        
        backView.addConstraints(constraints)
        
        self.view = backView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        titleTextField.text = note.title
        noteTextView.text = note.content
        dateLabel.text = dateFormatter.string(from: Date(timeIntervalSince1970: note.createdAtTI))
        if note.expirationTI > 0 {
        expirationDate.text = dateFormatter.string(from: Date(timeIntervalSince1970: note.expirationTI))
        } else {
            expirationDate.placeholder = NSLocalizedString("Expiration date", comment: "")
        }
        locationLabel.text = note.address
        
        pictures = note.pictures?.sortedArray(using: [NSSortDescriptor(key: "tag", ascending: true)]) as! [Picture]
  
        for picture  in pictures {
                addNewImage(UIImage(data: picture.imgData!)!, tag: Int(picture.tag), relativeX: picture.x, relativeY: picture.y)
        }
        
        // MARK: Views
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        expirationDate.inputView = datePicker
        
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
        else if expirationDate.isFirstResponder
        {
            expirationDate.resignFirstResponder()
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
    
    // MARK: Date Picker
    @objc func dateChanged(_ datePicker:UIDatePicker)
    {
        expirationDate.text = dateFormatter.string(from: datePicker.date)
        let privateMOC = DataManager.sharedManager.persistentContainer.newBackgroundContext()
        privateMOC.perform {
            let privateNote = privateMOC.object(with: self.note.objectID) as! Note
            privateNote.expirationTI = datePicker.date.timeIntervalSince1970
            try! privateMOC.save()
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
    
    @objc func catchPhoto(_ barButton:UIBarButtonItem)
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
                
        let popOverCont = actionSheetAlert.popoverPresentationController
        popOverCont?.barButtonItem = barButton
        
        present(actionSheetAlert, animated: true, completion: nil)
    }
    
    @objc func addLocation(_ barButton:UIBarButtonItem)
    {
        let selectAddress = SelectInMapViewController()
        selectAddress.delegate = self
        let navController = UINavigationController(rootViewController: selectAddress)
        navController.modalPresentationStyle = UIModalPresentationStyle.popover
        let popOverCont = navController.popoverPresentationController
        popOverCont?.barButtonItem = barButton
        
        present(navController, animated: true, completion: nil)
        
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
    
    // MARK: Select In Map Delegate
    func address(_ address: String, lat: Double, lon: Double) {
        locationLabel.text = address
        let backMOC = DataManager.sharedManager.persistentContainer.newBackgroundContext()
        
        backMOC.perform {
            
           let backNote = (backMOC.object(with: self.note.objectID) as! Note)
           
            backNote.address = address
            backNote.lat = lat
            backNote.lon = lon
            
            try! backMOC.save()
        }
        
    }
    


}
