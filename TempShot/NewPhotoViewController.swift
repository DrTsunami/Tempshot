//
//  NewPhotoViewController.swift
//  TempShot
//
//  Created by Ryan Tsang on 7/13/16.
//  Copyright © 2016 Ryan Tsang. All rights reserved.
//

import UIKit
import CoreData

class NewPhotoViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, NSFetchedResultsControllerDelegate {

    // Declare required variables
    var transiphoto: Transiphoto? = nil
    let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
    var transiphotoLength: NSNumber = 7 // change this value when messing with the default slider number

    @IBOutlet weak var keepLabel: UILabel!
    @IBOutlet weak var timeSlider: UISlider!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Navigation and bar setup
        navigationController?.isToolbarHidden = true
        
        // ImageView Setup
        
        // Theme setup
        view.backgroundColor = UIColor.black
        timeLabel.textColor = UIColor.white
        keepLabel.textColor = UIColor.white
        timeLabel.font = UIFont(name: "Roboto", size: 16.0)
        keepLabel.font = UIFont(name: "Roboto", size: 16.0)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // resets buttonTouched
        buttonTouched = false
        
        // Navigation and bar setup
        navigationController?.isToolbarHidden = true
    }
    
    // Autorotation
    override var shouldAutorotate : Bool {
        return true
    }
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return [UIInterfaceOrientationMask.portrait]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func saveTapped(_ sender: AnyObject) {
        // if the imageview exists then create a new transiphoto and dismiss the view controller
        if (imageView.image != nil) {
            createNewTransiphoto()
            dismissViewController()
            // print("saved photo and supposedly dismissed")
        }
    }
    
    @IBAction func cancelTapped(_ sender: AnyObject) {
        imagePicking = false
        dismissViewController()
    }
    
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        let currentSliderValue = Int(sender.value)
        
        if currentSliderValue < 5 {
            timeLabel.text = "\(currentSliderValue + 2) days"
            transiphotoLength = (currentSliderValue + 2) as NSNumber
        } else if currentSliderValue < 8 {
            timeLabel.text = "\(currentSliderValue - 4) week(s)"
            transiphotoLength = ((currentSliderValue - 4) * 7) as NSNumber
        } else {
            timeLabel.text = "Max Lifespan: 999 days"
            transiphotoLength = (999 + 1) as NSNumber
        }
        
        // print("Transiphoto length = \(transiphotoLength)")
    }
    
    // Calls the camera
    @IBAction func takePictureFromCamera(_ sender: AnyObject) {
        imagePicking = true
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.camera
        imagePicker.allowsEditing = false
        present(imagePicker, animated: true, completion: nil)
    }
    
    // Calls the photo album
    @IBAction func addImageFromAlbum(_ sender: AnyObject) {
        imagePicking = true
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        imagePicker.allowsEditing = false
        present(imagePicker, animated: true, completion: nil)
    }
    
    // When image has either been taken or picked from camera roll
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        // Updates the timestamp
        date = Date()
        calendar = Calendar.current
        components = (calendar as NSCalendar).components([.day , .month , .year , .hour , .minute , .second], from: date)
        year =  components.year
        month = components.month
        day = components.day
        hour = components.hour
        minute = components.minute
        second = components.second
        
        // Writes timestamp
        timestamp = "\(year! as Int)\(month! as Int)\(day! as Int)_\(hour! as Int)\(minute! as Int)\(second! as Int)"
        
        // print("Selected an image");
        
        imageView.image = image
        imagePicking = false
        self.dismiss(animated: true, completion: nil)

    }
    
    // Dismisses the pop view controller
    func dismissViewController() {
        navigationController?.popViewController(animated: true)
    }
    
    // Called to save transiphoto with photo
    func createNewTransiphoto() {
        let entityDescription = NSEntityDescription.entity(forEntityName: "Transiphoto", in: managedObjectContext)
        let transiphoto = Transiphoto(entity: entityDescription!, insertInto: managedObjectContext)
        
        transiphoto.name = ("IMG_\(timestamp)")
        transiphoto.dateCreated = Date()
        transiphoto.daysRemaining = transiphotoLength
        transiphoto.dateInitialized = Date()
        transiphoto.expirationDate = transiphoto.dateInitialized!.addingTimeInterval((24*60*60) * (transiphoto.daysRemaining as! Double))
        transiphoto.image = UIImageJPEGRepresentation(imageView.image!, 1.0)
        transiphoto.thumbnail = UIImageJPEGRepresentation(imageView.image!, 0.1)
        
        // print("transiphoto = \(transiphotoLength)")
        
        do {
            try managedObjectContext.save()
        } catch {
            return
        }

    }

}
