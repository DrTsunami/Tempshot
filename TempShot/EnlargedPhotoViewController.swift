//
//  EnlargedPhotoViewController.swift
//  TempShot
//
//  Created by Ryan Tsang on 7/30/16.
//  Copyright © 2016 Ryan Tsang. All rights reserved.
//

import UIKit
import CoreData
import GoogleMobileAds

class EnlargedPhotoViewController: UIViewController, UIScrollViewDelegate, UINavigationControllerDelegate, NSFetchedResultsControllerDelegate, UIPopoverPresentationControllerDelegate, GADBannerViewDelegate {
    
    // Declare required variables
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    var toolbarStandardItems: [UIBarButtonItem] = [UIBarButtonItem]()
    var toolbarEditItems: [UIBarButtonItem] = [UIBarButtonItem]()
    var fullScreen: Bool = false
    @IBOutlet weak var bannerView: GADBannerView!
    
    var transiphoto: Transiphoto!
    let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
    var fetchedResultsController: NSFetchedResultsController<Transiphoto> = NSFetchedResultsController<Transiphoto>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Reset button touched boolean
        buttonTouched = false
        
        // Set up scrollview
        self.scrollView.delegate = self
        // TODO minimum zoom scale to allow for entire photo in landscape mode
        self.scrollView.minimumZoomScale = 1.0
        self.scrollView.maximumZoomScale = 3.0
        self.scrollView.backgroundColor = UIColor.black
        
        // Load transiphoto
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationItem.title = transiphoto.name
        
        
        imageView.backgroundColor = UIColor.black
        imageView.image = UIImage(data: transiphoto.image! as Data)
        
        // Perform layout setup
        self.loadToolbarItems()
        
        // Enable gestures
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(EnlargedPhotoViewController.handleTap(_:)))
        let swipeGestureRight: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(EnlargedPhotoViewController.didSwipe(_:)))
        swipeGestureRight.direction = UISwipeGestureRecognizerDirection.right
        let swipeGestureLeft: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(EnlargedPhotoViewController.didSwipe(_:)))
        swipeGestureLeft.direction = UISwipeGestureRecognizerDirection.left
        view.addGestureRecognizer(tapGesture)
        view.addGestureRecognizer(swipeGestureRight)
        view.addGestureRecognizer(swipeGestureLeft)
        
        // CoreData setup and reload
        fetchedResultsController = getFetchRequestController()
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("Failed to do inital fetch")
        }
        
        // Theme setup
        navigationController?.toolbar.barTintColor = UIColor.black
        navigationController?.toolbar.backgroundColor = UIColor.black
        
        // Ad Setup
        if (prefs.bool(forKey: "adsDisplayed") == true) {
            let request = GADRequest()
            request.testDevices = [kGADSimulatorID]
            bannerView.delegate = self
            bannerView.adUnitID = "ca-app-pub-1107580950774526/6963973891"
            bannerView.rootViewController = self
            bannerView.load(request)
        } else {
            bannerView.isHidden = true
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Navigation item setup
        isEditing = false
        navigationItem.leftBarButtonItem = navigationItem.backBarButtonItem
        navigationController?.isToolbarHidden = false
        navigationController?.toolbar.setItems(toolbarStandardItems, animated: true)
        navigationItem.rightBarButtonItem = editButtonItem
        navigationItem.leftBarButtonItem = navigationItem.backBarButtonItem
        
    }
    
    // Rotation
    override var shouldAutorotate : Bool {
        return true
    }
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return [UIInterfaceOrientationMask.portrait, UIInterfaceOrientationMask.landscapeLeft, UIInterfaceOrientationMask.landscapeRight]
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //  CoreData
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    
    // CoreData fetching
    func fetchRequest() -> NSFetchRequest<Transiphoto> {
        let fetchRequest = NSFetchRequest<Transiphoto>(entityName: "Transiphoto")
        
        // Sorting
        let sortDescriptor = NSSortDescriptor(key: "dateCreated", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        // TODO fix sorting
        
        return fetchRequest
    }
    
    // Gets the fetch request controller. More CoreData stuff
    func getFetchRequestController() -> NSFetchedResultsController<Transiphoto> {
        fetchedResultsController = NSFetchedResultsController<Transiphoto>(fetchRequest: fetchRequest(), managedObjectContext: managedObjectContext, sectionNameKeyPath:  nil, cacheName: nil)
        return fetchedResultsController
    }
    
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //  Photo Viewing Functionality
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
    
    // Tap gesture detection to hide nav and toolbar
    func handleTap(_ sender: UITapGestureRecognizer) {
        if !fullScreen {
            navigationController?.setNavigationBarHidden(true, animated: true)
            navigationController?.setToolbarHidden(true, animated: true)
            fullScreen = true
            print("fullscreen is true")
        } else if fullScreen {
            navigationController?.setNavigationBarHidden(false, animated: true)
            navigationController?.setToolbarHidden(false, animated: true)
            if isEditing {
                navigationController?.toolbar.setItems(toolbarEditItems, animated: true)
            } else {
                navigationController?.toolbar.setItems(toolbarStandardItems, animated: true)
            }
            fullScreen = false
            print("fullscreen is false")
        }
        
    }
    
    // Supposed to hide status bar but it doesn't
    // TODO hide status bar properly
    override var prefersStatusBarHidden : Bool {
        return (navigationController?.isNavigationBarHidden)!
    }
    
    override var preferredStatusBarUpdateAnimation : UIStatusBarAnimation {
        return UIStatusBarAnimation.slide
    }
    
    func didSwipe(_ sender: UISwipeGestureRecognizer) {
        let direction = sender.direction as UISwipeGestureRecognizerDirection
        
        switch (direction) {
        case UISwipeGestureRecognizerDirection.left:
            print("swiped left")
            break
        case UISwipeGestureRecognizerDirection.right:
            print("swiped right")
            break
        default:
            print("No Direction Detected")
            break
        }
    }
    
    func loadToolbarItems() {
        toolbarStandardItems.append(UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(EnlargedPhotoViewController.shareImage(_:))))
        toolbarStandardItems.append(UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil))        
        toolbarStandardItems.append(UIBarButtonItem(title: "\(transiphoto.daysRemaining as! Int) DAYS REMAINING", style: .plain, target: self, action: nil))
        toolbarStandardItems.append(UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil))
        toolbarStandardItems.append(UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(EnlargedPhotoViewController.refreshTime(_:))))
        
        toolbarEditItems.append(UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(EnlargedPhotoViewController.trashPressed(_:))))
        toolbarEditItems.append(UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil))
        toolbarEditItems.append(UIBarButtonItem(title: "Settings", style: .plain, target: self, action: #selector(EnlargedPhotoViewController.settingsPressed(_:))))
        
        
        // THEME
        toolbarStandardItems[2].setTitleTextAttributes([NSFontAttributeName: UIFont(name: "Roboto-Thin", size: 16.0)!], for: UIControlState())
        toolbarStandardItems[2].tintColor = UIColor.white
    }
    
    func shareImage(_ sender: UIButton!) {
        let vc = UIActivityViewController(activityItems: [transiphoto.image!], applicationActivities: nil)
        self.present(vc, animated: true, completion: nil)
    }
    
    // Function handling quick refresh button
    func refreshTime(_ sender: UIButton!) {
        
        if ((transiphoto.daysRemaining as! Int) + 7 < 999) {
            transiphoto.expirationDate = transiphoto.expirationDate!.addingTimeInterval((24*60*60) * 7)
            transiphoto.daysRemaining = (transiphoto.daysRemaining as! Int + 7) as NSNumber
            navigationController!.toolbar.items![2].title = "\(transiphoto.daysRemaining as! Int) DAYS REMAINING"
        } else {
            // sets cap at 999 days
            transiphoto.daysRemaining = 999
            navigationController!.toolbar.items![2].title = "\(transiphoto.daysRemaining as! Int) DAYS REMAINING"
            transiphoto.expirationDate = transiphoto.dateInitialized!.addingTimeInterval((24*60*60) * 999)
        }
        
        print("DAYS REMAINING: \(transiphoto.daysRemaining) Expiration Date: \(transiphoto.expirationDate)")
        
        // Update Core Data
        do {
            try managedObjectContext.save()
        } catch {
            return
        }
    }
    
    func settingsPressed(_ sender: UIButton!) {
        self.performSegue(withIdentifier: "showPhotoSettings", sender: self)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "showPhotoSettings"?:
            let vc = segue.destination as! PhotoSettingsViewController
            vc.transiphoto = self.transiphoto
            break
        default:
            print("no such segue")
            break
        }
    }
    
    func trashPressed(_ sender: UIButton!) {
        // Alert controller setup
        let alertController = UIAlertController(title: "Delete?", message: "Photo will not be recoverable!", preferredStyle: .alert)
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (action) -> Void in
            // call the delete method
            self.deletePhoto()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) -> Void in
            // Do nothing
        }
        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)
        
        // present the alert
        self.navigationController?.present(alertController, animated: true, completion: nil)
    }
    
    // Delete function for photo
    func deletePhoto() {
        let indexPath = fetchedResultsController.indexPath(forObject: transiphoto)
        managedObjectContext.delete(fetchedResultsController.object(at: indexPath!) as NSManagedObject) // changed from as! to as
        do {
            try managedObjectContext.save()
        } catch {
            return
        }
        navigationController?.popViewController(animated: true)
    }
    
    // if editing
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: true)
        
        if editing {
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(EnlargedPhotoViewController.cancelEdit(_:)))
            navigationItem.title = "Editing"
            navigationController?.toolbar.setItems(toolbarEditItems, animated: true)
        } else {
            // When DONE is pressed
            print("not editing")
            self.stopEditing()
        }
    }
    
    func stopEditing() {
        navigationItem.leftBarButtonItem = navigationItem.backBarButtonItem
        navigationItem.title = transiphoto.name
        navigationController?.toolbar.setItems(toolbarStandardItems, animated: true)
        navigationController!.toolbar.items![2].title = "\(transiphoto.daysRemaining as! Int) DAYS REMAINING"
    }
    
    func cancelEdit(_ sender: UIBarButtonItem) {
        isEditing = false
        self.stopEditing()
    }
}

extension UIAlertController {
    open override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return [UIInterfaceOrientationMask.portrait, UIInterfaceOrientationMask.landscapeRight, UIInterfaceOrientationMask.landscapeLeft]
    }
    open override var shouldAutorotate : Bool {
        return false
    }
}
