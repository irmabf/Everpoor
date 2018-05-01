//
//  NoteViewController+Images.swift
//  Everpoor
//
//  Created by Joaquin Perez on 01/05/2018.
//  Copyright © 2018 Joaquin Perez. All rights reserved.
//

import UIKit

extension NoteViewController {
    
    
    // Vamos a realizar bastante trabajos con las imagenes, por ello lo creamos en nuevo archivo.
    
    func addNewImage(_ image:UIImage, tag:Int, relativeX: Double, relativeY: Double)
    {
        let imageView = UIImageView(image: image)
        imageView.tag = tag
        imageView.isUserInteractionEnabled = true
        self.view.addSubview(imageView)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        let heightConstraint = NSLayoutConstraint(item: imageView, attribute: .height, relatedBy: .equal, toItem: self.view, attribute: .height, multiplier: 0.20, constant: 0)
        let witdhConstraint = NSLayoutConstraint(item: imageView, attribute: .width, relatedBy: .equal, toItem: self.view, attribute: .width, multiplier: 0.25, constant: 0)
        
        let constantLeft = CGFloat(relativeX) * UIScreen.main.bounds.width
        
        let leftConstraint = NSLayoutConstraint(item: imageView, attribute: .left, relatedBy: .equal, toItem: self.view, attribute: .left, multiplier: 1, constant: constantLeft)
        
        leftConstraint.identifier = "left_\(tag)"
        
        let constantTop = CGFloat(relativeY) * UIScreen.main.bounds.height
        
        let topConstraint = NSLayoutConstraint(item: imageView, attribute: .top, relatedBy: .equal, toItem: self.noteTextView.contentLayoutGuide, attribute: .top, multiplier: 1, constant: constantTop)
        
        topConstraint.identifier = "top_\(tag)"
        
        self.view.addConstraints([heightConstraint,witdhConstraint,leftConstraint,topConstraint])
        
        // MARK: Gestures in images.
        
        let moveViewGesture = UILongPressGestureRecognizer(target: self, action: #selector(userMoveImage))
        
        imageView.addGestureRecognizer(moveViewGesture)
        
    }
    
    // MARK: Gestures Methods.
    
    @objc func userMoveImage(longPressGesture:UILongPressGestureRecognizer)
    {
        let leftImgConstraint = (self.view.constraints.filter { (constraint) -> Bool in
            return constraint.identifier == "left_\(longPressGesture.view!.tag)"
        }.first)!
        
        let topImgConstraint = (self.view.constraints.filter { (constraint) -> Bool in
            return constraint.identifier == "top_\(longPressGesture.view!.tag)"
            }.first)!
        
        
        switch longPressGesture.state {
        case .began:
            closeKeyboard()
            relativePoint = longPressGesture.location(in: longPressGesture.view)
            UIView.animate(withDuration: 0.1, animations: {
                longPressGesture.view!.transform = CGAffineTransform.init(scaleX: 1.2, y: 1.2)
            })
            
        case .changed:
            let location = longPressGesture.location(in: noteTextView)
            
            leftImgConstraint.constant = location.x - relativePoint.x
            topImgConstraint.constant = location.y - relativePoint.y
            
        case .ended, .cancelled:
            
            UIView.animate(withDuration: 0.1, animations: {
                longPressGesture.view!.transform = CGAffineTransform.init(scaleX: 1, y: 1)
            })
            
        default:
            break
        }
        
    }
    
}
