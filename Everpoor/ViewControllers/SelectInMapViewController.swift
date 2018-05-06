//
//  SelectInMapViewController.swift
//  Chekin
//
//  Created by Joaquin Perez Barroso on 24/6/17.
//  Copyright © 2017 invibe. All rights reserved.
//

import UIKit
import MapKit
import AddressBook
import CoreLocation
import Contacts


protocol SelectInMapDelegate
{
    func address(_ address:String, lat:Double, lon:Double)
}

class SelectInMapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    
    let mapView = MKMapView()
    let tableView = UITableView.init(frame: CGRect(), style: .plain)
    let bottonButton = UIButton.init()
    
    var delegate:SelectInMapDelegate?
    
    var location: CLLocation?
    var label = UILabel()
    
    
    override func loadView()
    {
        let backView = UIView.init()
        backView.backgroundColor = .white

        backView.addSubview(mapView)
        backView.addSubview(bottonButton)
        backView.addSubview(label)
        
        let selectImage = UIImageView.init(image: #imageLiteral(resourceName: "mapSelect"))
        
        backView.addSubview(selectImage)
        
        label.backgroundColor = .white
        label.layer.cornerRadius = 0.3
        label.layer.masksToBounds = true
        label.numberOfLines = 0

        
        bottonButton.translatesAutoresizingMaskIntoConstraints = false
        mapView.translatesAutoresizingMaskIntoConstraints = false
        selectImage.translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false
        
        let views = ["bottonButton":bottonButton,"mapView":mapView,"selectImage":selectImage, "label":label]
        var constraints = NSLayoutConstraint.constraints(withVisualFormat: "|-0-[bottonButton]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views)
        constraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "|-0-[mapView]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        
        constraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "|-0-[label]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        constraints.append(NSLayoutConstraint.init(item: selectImage, attribute: .centerX, relatedBy: .equal, toItem: mapView, attribute: .centerX, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint.init(item: selectImage, attribute: .centerX, relatedBy: .equal, toItem: mapView, attribute: .centerX, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint.init(item: selectImage, attribute: .centerY, relatedBy: .equal, toItem: mapView, attribute: .centerY, multiplier: 1, constant: -17))
        constraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "[selectImage(34)]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        constraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "V:[selectImage(34)]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        constraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "V:|-75-[label]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        
        constraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[mapView]-0-[bottonButton(60)]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        

        backView.addConstraints(constraints)
        
        self.view = backView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let cancelBarButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        
        navigationItem.rightBarButtonItem = cancelBarButton
        
        title = NSLocalizedString("Center in Map", comment: "Select in Map title")


        
        mapView.delegate = self
        
        bottonButton.setTitle(NSLocalizedString("Select", comment: ""), for: .normal)
        bottonButton.setTitleColor(self.view.tintColor, for: .normal)
        bottonButton.addTarget(self, action: #selector(confirmAddress), for: .touchUpInside)
        
    }

    
    
    // MARK: - Map view
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool)
    {
        
        let centerCoordinate = mapView.centerCoordinate
        let currentMapLocation = CLLocation(latitude: centerCoordinate.latitude, longitude: centerCoordinate.longitude)
        
        let geoCoder = CLGeocoder()
        
        geoCoder.reverseGeocodeLocation(currentMapLocation) { (placeMarkArray, error) in
            
            if placeMarkArray != nil && placeMarkArray!.count > 0 {
                
                let placeMark = placeMarkArray?.first
                
                DispatchQueue.main.async
                {
                    
                    if let postalAddres = placeMark?.postalAddress
                    {
                    self.label.text = "\(postalAddres.street) \(postalAddres.city)"
                    self.location = placeMark?.location
                    }
                }
            }
        }
    }
    
   @objc func cancel()  {
    
        dismiss(animated: false, completion: nil)
    }
   @objc func confirmAddress() {
    
       if let loc = location
       {
        
        if self.delegate != nil
        {
            self.delegate?.address(self.label.text!, lat: loc.coordinate.latitude, lon: loc.coordinate.longitude)
            
        }
         dismiss(animated: false, completion: nil)
    }
    }
    
 
}

