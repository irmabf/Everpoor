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
        imageViews.append(imageView)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        let heightConstraint = NSLayoutConstraint(item: imageView, attribute: .height, relatedBy: .equal, toItem: self.view, attribute: .height, multiplier: 0.20, constant: 0)
        let witdhConstraint = NSLayoutConstraint(item: imageView, attribute: .width, relatedBy: .equal, toItem: self.view, attribute: .width, multiplier: 0.25, constant: 0)
        
        let constantLeft = CGFloat(relativeX) * UIScreen.main.bounds.width
        
        let leftConstraint = NSLayoutConstraint(item: imageView, attribute: .left, relatedBy: .equal, toItem: self.view, attribute: .left, multiplier: 1, constant: constantLeft)
        
        leftConstraint.priority = .defaultHigh
        
        leftConstraint.identifier = "left_\(tag)"
        
        let constantTop = CGFloat(relativeY) * UIScreen.main.bounds.height
        
        let topConstraint = NSLayoutConstraint(item: imageView, attribute: .top, relatedBy: .equal, toItem: self.noteTextView.contentLayoutGuide, attribute: .top, multiplier: 1, constant: constantTop)
        
        topConstraint.identifier = "top_\(tag)"
        
        topConstraint.priority = .defaultHigh
        
        var constraints = [heightConstraint,witdhConstraint,leftConstraint,topConstraint]
        
        // Limites.
        
        constraints.append(NSLayoutConstraint(item: imageView, attribute: .left, relatedBy: .greaterThanOrEqual, toItem: self.view, attribute: .left, multiplier: 1, constant: 10))
        constraints.append(NSLayoutConstraint(item: imageView, attribute: .right, relatedBy: .lessThanOrEqual, toItem: self.view, attribute: .right, multiplier: 1, constant: -10))
        
        constraints.append(NSLayoutConstraint(item: imageView, attribute: .top, relatedBy: .greaterThanOrEqual, toItem: self.noteTextView, attribute: .top, multiplier: 1, constant: 10))
        
        
        constraints.append(NSLayoutConstraint(item: imageView, attribute: .bottom, relatedBy: .lessThanOrEqual, toItem: self.view, attribute: .bottom, multiplier: 1, constant: -10))
        
        
        self.view.addConstraints(constraints)
        
        // MARK: Gestures in images.
        
        let moveViewGesture = UILongPressGestureRecognizer(target: self, action: #selector(userMoveImage))
        
        imageView.addGestureRecognizer(moveViewGesture)
        
        let rotateGesture = UIRotationGestureRecognizer(target: self, action: #selector(rotateImage))
        
        imageView.addGestureRecognizer(rotateGesture)
        
        let zoomingGesture = UIPinchGestureRecognizer(target: self, action: #selector(zoomImage))
        
        imageView.addGestureRecognizer(zoomingGesture)
        
    }
    
    // MARK: Gestures Methods.
    
    @objc func userMoveImage(longPressGesture:UILongPressGestureRecognizer)
    {
        let picture = pictures[(longPressGesture.view?.tag)! - 1]
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
            let relativeX = leftImgConstraint.constant / UIScreen.main.bounds.width
            let relativeY = topImgConstraint.constant / UIScreen.main.bounds.height
            saveIn(picture: picture, setValuesForKey: ["x": relativeX,"y":relativeY])
            
        default:
            break
        }
        
    }
    
    @objc func rotateImage(rotateGesture:UIRotationGestureRecognizer)
    {
        let picture = pictures[(rotateGesture.view?.tag)! - 1]
        switch rotateGesture.state {
        case .began, .changed:
          //  rotateGesture.view!.transform =
         //   let rotation = CGAffineTransform.init(rotationAngle: rotateGesture.rotation)
            let scale = CGAffineTransform.init(scaleX: CGFloat(picture.scale), y: CGFloat(picture.scale))
               rotateGesture.view!.transform = scale.rotated(by: rotateGesture.rotation)
        case .ended, .cancelled:
            let scale = CGAffineTransform.init(scaleX: CGFloat(picture.scale), y: CGFloat(picture.scale))
            rotateGesture.view!.transform = scale.rotated(by: rotateGesture.rotation)
            saveIn(picture: picture, setValuesForKey: ["rotation":rotateGesture.rotation])
            
        default:
            break;
        }
     
    }
    
    @objc func zoomImage(zoomGesture:UIPinchGestureRecognizer)
    {
        let picture = pictures[(zoomGesture.view?.tag)! - 1]
        
        var scale = zoomGesture.scale
        if scale > 1.3
        {
            scale = 1.3
        }
        else if scale < 0.7
        {
            scale = 0.7
        }
        saveIn(picture: picture, setValuesForKey: ["scale":scale])

       switch zoomGesture.state {
        case .began, .changed:
        //    zoomGesture.view?.transform = CGAffineTransform.init(rotationAngle: rotation)
            zoomGesture.view!.transform = zoomGesture.view!.transform.scaledBy(x: scale, y: scale)
        case .ended, .cancelled:
         //   zoomGesture.view?.transform = CGAffineTransform.init(rotationAngle: rotation)
            zoomGesture.view!.transform = zoomGesture.view!.transform.scaledBy(x: scale, y: scale)
        
        default:
            break;
        }
    }
    
    // MARK: Model save.
    func saveIn(picture: Picture, setValuesForKey:[String:Any]) {
        
        let backMOC = DataManager.sharedManager.persistentContainer.newBackgroundContext()
        backMOC.perform {
            let backPicture = backMOC.object(with: picture.objectID) as! Picture
            backPicture.setValuesForKeys(setValuesForKey)
            
            try! backMOC.save()
        }
    }
    
    
}
