//
//  PhotoSettingsViewController.swift
//  TempShot
//
//  Created by Ryan Tsang on 8/9/16.
//  Copyright © 2016 Ryan Tsang. All rights reserved.
//

import UIKit
import CoreData

class PhotoSettingsViewController: UIViewController, UINavigationControllerDelegate, NSFetchedResultsControllerDelegate {
    
    var transiphoto: Transiphoto!
    var sliderValue = 5
    
    let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
    var fetchedResultsController: NSFetchedResultsController<Transiphoto>? = NSFetchedResultsController()

    @IBOutlet weak var lifespanLabel: UILabel!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var currentInformationLabel: UILabel!
    @IBOutlet weak var currentDaysRemainingLabel: UILabel!
    @IBOutlet weak var dateInitializedLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Navigation bar, toolbar, and button setup
        navigationController?.title = "Settings"
        navigationController?.isToolbarHidden = true
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(PhotoSettingsViewController.cancelPressed(_:)))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(PhotoSettingsViewController.savePressed(_:)))
        
        
        // Labels
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        currentDaysRemainingLabel.text = "Expires In: \(transiphoto.daysRemaining as! Int) Days"
        dateInitializedLabel.text = "Date Created or Renewed: \(formatter.string(from: transiphoto.dateInitialized! as Date))"
        
        // Theme
        self.view.backgroundColor = UIColor.black
        lifespanLabel.textColor = UIColor.white
        currentInformationLabel.textColor = UIColor.white
        currentDaysRemainingLabel.textColor = UIColor.white
        dateInitializedLabel.textColor = UIColor.white
        lifespanLabel.font = UIFont(name: "Roboto-Thin", size: 20.0)
        currentInformationLabel.font = UIFont(name: "Roboto-Thin", size: 18.0)
        currentDaysRemainingLabel.font = UIFont(name: "Roboto-Thin", size: 16.0)
        dateInitializedLabel.font = UIFont(name: "Roboto-Thin", size: 16.0)
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var shouldAutorotate : Bool {
        return true
    }
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return [UIInterfaceOrientationMask.portrait, UIInterfaceOrientationMask.landscapeLeft, UIInterfaceOrientationMask.landscapeRight]
    }
    
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        let currentSliderValue = Int(sender.value)
        sliderValue = currentSliderValue
        
        if currentSliderValue < 5 {
            lifespanLabel.text = "Reset Photo Lifespan: \(currentSliderValue + 2) days"
        } else if currentSliderValue < 8 {
            lifespanLabel.text = "Reset Photo Lifespan: \(currentSliderValue - 4) week(s)"
        } else {
            lifespanLabel.text = "Reset Photo Lifespan: Max"        }
    }
    
    func cancelPressed(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
    
    func savePressed(_ sender: UIBarButtonItem) {
        
        var alertMessage: String = ""
        
        if (sliderValue < 5) {
            alertMessage = "Photo will be kept for \(sliderValue + 2) days"
        } else if (sliderValue < 8) {
            alertMessage = "Photo will be kept for \(sliderValue - 4) week(s)"
        } else {
            alertMessage = "Photo will be kept for 999 days"
        }
        
        let alertController = UIAlertController(title: "Change Photo Lifespan?", message: alertMessage, preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Save", style: .default) { (action) -> Void in
            
            self.transiphoto.dateInitialized = Date()
            
            if self.sliderValue < 5 {
                self.transiphoto.daysRemaining = ((self.sliderValue + 2) - 1) as NSNumber
                self.transiphoto.expirationDate = self.transiphoto.dateInitialized!.addingTimeInterval((24*60*60) * (Double(self.sliderValue + 2)))
            } else if self.sliderValue < 8 {
                self.sliderValue - 4
                self.transiphoto.daysRemaining = (((self.sliderValue - 4) * 7) - 1) as NSNumber
                self.transiphoto.expirationDate = self.transiphoto.dateInitialized!.addingTimeInterval((24*60*60) * (Double((self.sliderValue - 4) * 7)))
            } else {
                self.transiphoto.daysRemaining = 999
                self.transiphoto.expirationDate = self.transiphoto.dateInitialized!.addingTimeInterval((24*60*60) * (999 + 1))
            }
            
            // print(self.transiphoto.daysRemaining)
            
            do {
                try self.managedObjectContext.save()
            } catch {
                return
            }
            
            self.navigationController?.popViewController(animated: true)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) -> Void in
            // Do nothing
        }
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        
        // present the alert
        self.navigationController?.present(alertController, animated: true, completion: nil)
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
