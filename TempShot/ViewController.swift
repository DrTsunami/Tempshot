//
//  ViewController.swift
//  TempShot
//
//  Created by Ryan Tsang on 6/10/16.
//  Copyright (c) 2016 Ryan Tsang. All rights reserved.
//

import UIKit
import CoreData
import GoogleMobileAds

// set vars for time components
var date = Date()
var calendar = Calendar.current
var components = (calendar as NSCalendar).components([.day , .month , .year , .hour , .minute , .second], from: date)
var year =  components.year
var month = components.month
var day = components.day
var hour = components.hour
var minute = components.minute
var second = components.second
var timestamp: String = ""

// set public vars
var cellWidth: CGFloat = 0
var cellHeight: CGFloat = 0
var popoverSliderValue: Int = 0
var buttonTouched: Bool = false
let prefs = UserDefaults.standard
var imagePicking: Bool = false

/*
// enable to use test dates
let dateFormatter = NSDateFormatter()
var testDate = NSDate()
*/

// returns days between dates - I'm not quite sure what the "_" does in front of "fromDate"
func daysBetweenDates(_ fromDate: Date, toDate: Date) -> Int {
    let gregorian: Calendar = Calendar(identifier: Calendar.Identifier.gregorian)
    let unitFlags: NSCalendar.Unit = .day
    let components: DateComponents = (gregorian as NSCalendar).components(unitFlags, from: fromDate, to: toDate,
        options: [])
    return components.day!
}

//-----     CLASS EXTENSIONS     -----//

extension UINavigationController {
    
    
    override open var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        if (!imagePicking) {
            return (visibleViewController?.supportedInterfaceOrientations)!
        } else {
            return UIInterfaceOrientationMask.portrait
        }
    }
    
    override open var shouldAutorotate : Bool {
        if (!imagePicking) {
            return (visibleViewController?.shouldAutorotate)!
        } else {
            return false
        }
    }
}

extension UIImagePickerController
{
    
    override open var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return [UIInterfaceOrientationMask.portrait]
    }
    
    override open var shouldAutorotate : Bool {
        return true
    }
}

extension NSLayoutConstraint {
    
    override open var description: String {
        let id = identifier ?? ""
        return "id: \(id), constant: \(constant)" //you may print whatever you want here
    }
}


//********************************************    BEGIN CLASS     ********************************************//



@available(iOS 9.0, *)
class ViewController: UIViewController, UINavigationControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, NSFetchedResultsControllerDelegate, UIImagePickerControllerDelegate, GADBannerViewDelegate {
    
    // Declare required variables
    @IBOutlet weak var collectionView: UICollectionView!
    fileprivate var selectedPhotos: [IndexPath] = [IndexPath]()
    fileprivate var expiredPhotosIndexPaths: [IndexPath] = [IndexPath]()
    @IBOutlet weak var bannerView: GADBannerView!
    
    // Set up CoreData objects such as the Managed Object Context and NSFetchedResultsController
    let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
    var fetchedResultsController: NSFetchedResultsController<Transiphoto> = NSFetchedResultsController<Transiphoto>()
    
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //  Initial Loading and Setup
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    

    
    // Run when view initially loads
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // First Time Setup and checks
        if prefs.object(forKey: "adsDisplayed") == nil {
            prefs.set(true, forKey: "adsDisplayed")
        } else {
            print("bool key = \(prefs.bool(forKey: "adsDisplayed"))")
        }
        
        // FIXME removes ads for shooting only!!!!!!
        // prefs.setBool(false, forKey: "adsDisplayed")
        
        // FIXME maybe set a boolean for if ads have been purchased, then transfer that to if ads are displayed...
        
        // Navigation and bar setup
        navigationController?.isToolbarHidden = true
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Info", style: .plain, target: self, action: #selector(ViewController.pressedInfo(_:)))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(ViewController.newPhoto(_:)))
        navigationItem.title = "TEMPSHOT"
        for view in navigationController!.navigationBar.subviews {
            view.isExclusiveTouch = true
        }
        
        // Layout setup
        var layout = self.collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize.width = CGFloat((UIScreen.main.bounds.width / 3) - 1.2)
        layout.itemSize.height = layout.itemSize.width
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 1.2
        cellWidth = layout.itemSize.width
        cellHeight = layout.itemSize.height
        
        
    
        // CoreData setup and reload
        fetchedResultsController = getFetchRequestController()
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("Failed to do inital fetch")
        }
        
        
        // Enable gestures
        let longPressGesture: UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(ViewController.longPress(_:)))
        view.addGestureRecognizer(longPressGesture)
        
        // Theme Setup
        navigationController?.navigationBar.barTintColor = UIColor.black
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.white,
            NSFontAttributeName: UIFont(name: "Roboto", size: 20.0)!]
        self.collectionView.backgroundColor = UIColor.black
        navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "Roboto", size: 20.0)!], for: UIControlState())
        
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
        
        // Reload collection view to update data
        self.collectionView.reloadData()
    }
    
    // Run when view appears
    override func viewDidAppear(_ animated: Bool) {
        
        // Orientation to portrait mode
        let value = UIInterfaceOrientation.portrait.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
        
        // Navigation and bar setup
        navigationController?.isToolbarHidden = true
        
        // Fetch and reload for CoreData and collectionView
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("Failed to do appear fetch")
        }
        
        /* code used to change the date
        dateFormatter.dateFormat = "MM/dd/yyyy"
        testDate = dateFormatter.dateFromString("09/29/2016")!
        print(testDate)
        */
        
        // Check all transiphoto objects and update days remaining
        for object in fetchedResultsController.fetchedObjects! {
            let transiphoto = object as! Transiphoto
            let daysRemaining = daysBetweenDates(Date(), toDate: transiphoto.expirationDate!)
            
            if daysRemaining < 0 {
                expiredPhotosIndexPaths.append(fetchedResultsController.indexPath(forObject: object)!)
                print("added index path of expired transiphoto")
            } else {
                transiphoto.daysRemaining = daysRemaining as NSNumber?
            }
            
            print("\(transiphoto.name) DAYS REMAINING: \(transiphoto.daysRemaining)")
            
        }
        
        // Clear out expired photos
        if self.expiredPhotosIndexPaths.count > 0 {
            
            let expiredCount = expiredPhotosIndexPaths.count
            
            for indexPath in self.expiredPhotosIndexPaths{
                // delete and update the managed object context
                managedObjectContext.delete(fetchedResultsController.object(at: indexPath) as! NSManagedObject)
                do {
                    try managedObjectContext.save()
                } catch {
                    return
                }
            }
            
            // perform the post fetch
            do {
                try fetchedResultsController.performFetch()
                print("performed post fetch")
            } catch {
                print("Failed to fetch")
            }
            
            // Animate the changes
            self.collectionView.performBatchUpdates({self.collectionView.deleteItems(at: self.expiredPhotosIndexPaths)}, completion: nil)
            
            expiredPhotosIndexPaths = [IndexPath]()
            
            let expiredPhotosRemovedAlert = UIAlertController(title: "\(expiredCount) photos deleted", message: "Expired transiphotos have been removed", preferredStyle: .alert)
            expiredPhotosRemovedAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.navigationController?.present(expiredPhotosRemovedAlert, animated: true, completion: nil)
        }
        
        setNeedsStatusBarAppearanceUpdate()
        self.collectionView.reloadData()
    }
    
    // Calls the camera
    func takePicture(_ sender: AnyObject) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.camera
        imagePicker.allowsEditing = false
        present(imagePicker, animated: true, completion: nil)
    }
    
    // handles after picture is taken
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
        timestamp = "\(year)\(month)\(day)_\(hour)\(minute)\(second)"
        
        // print("Selected an image");
        
        // FIXME send image to next view controller
        self.dismiss(animated: true, completion: nil)
        
        // FIXME send image and maybe timestamp to NewPhotoViewController
        
    }
    
    // Status bar theme
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    // Autorotation
    override var shouldAutorotate : Bool {
        return true
    }
    
    override open var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return [UIInterfaceOrientationMask.portrait]
    }
    
    override var preferredInterfaceOrientationForPresentation : UIInterfaceOrientation {
        return UIInterfaceOrientation.portrait
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        // This is a default method
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
    //  CollectionView Setup and Functionality
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    // Number of sections
    func collectionView(_ collectionView: UICollectionView, numberOfSections section: Int) -> Int {
        let numberOfSections = fetchedResultsController.sections?.count
        return numberOfSections!
    }

    // Number of items in each section
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let numberOfItemsInSection = fetchedResultsController.sections?[section].numberOfObjects
        return numberOfItemsInSection!
    }
    
    // Configure the cell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! PhotoCell
        
        let transiphoto = fetchedResultsController.object(at: indexPath) as! Transiphoto
        cell.imageView?.image = UIImage(data: transiphoto.thumbnail!)
        // FIXME sizetofit testing
        cell.imageView.contentMode = .scaleAspectFill
        cell.checkmarkImageView.isHidden = true   // not sure why, but this is necessary
        
        // TODO let photo = some sort of index path so it chooses the photo to display
        cell.backgroundColor = UIColor.black
        return cell
    }
    
    
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // Adding, Editing, and Selecting
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    // handles newPhoto button action
    func newPhoto(_ sender: UIBarButtonItem) {
        if buttonTouched == false {
            self.performSegue(withIdentifier: "addNewPhotoSegue", sender: self)
        }
        buttonTouched = true
    }
    
    // When Info is pressed
    func pressedInfo(_ sender: UIBarButtonItem) {
        // TODO pass to new view controller
        if !buttonTouched {
            self.performSegue(withIdentifier: "infoPageSegue", sender: self)
        }
        buttonTouched = true
    }
    
    // When a photo is long pressed - enables editing
    func longPress(_ sender: UILongPressGestureRecognizer) {
        self.setEditing(true, animated: true)
    }
    
    // Executed when Edit mode is enabled
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: true)
        self.collectionView!.allowsMultipleSelection = editing
        let indexPaths: [IndexPath] = self.collectionView!.indexPathsForVisibleItems
        
        // Deselects every cell at the start of the editing process
        for indexPath in indexPaths {
            self.collectionView!.deselectItem(at: indexPath, animated: false)
        }
        
        // If editing
        if (editing) {
            navigationItem.title = "Editing"
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(ViewController.pushedDelete(_:)))
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(ViewController.pushedDone(_:)))
            do {
                try fetchedResultsController.performFetch()
                print("Initial fetch")
            } catch {
                print("Failed to fetch")
            }
            
        } else {
            // When done is pressed or if not editing anymore
            print("We are no longer editing")
            self.collectionView!.allowsMultipleSelection = false
            
            // hides checkmark views
            for indexPath in indexPaths {
                (self.collectionView!.cellForItem(at: indexPath) as! PhotoCell).checked(false)
                print((self.collectionView!.cellForItem(at: indexPath) as! PhotoCell).checkmarkImageView?.isHidden)
            }
            
            // Reset navigation items
            navigationItem.title = "TEMPSHOT"
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(ViewController.newPhoto(_:)))
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Info", style: .plain, target: self, action: #selector(ViewController.pressedInfo(_:)))
            self.collectionView.reloadData()
        }
    }
    
    // When done is pushed
    func pushedDone(_ sender: UIBarButtonItem) {
        // When done is pressed - copy of above method
        let indexPaths: [IndexPath] = self.collectionView!.indexPathsForVisibleItems
        print("We are no longer editing")
        self.collectionView!.allowsMultipleSelection = false
        
        for indexPath in indexPaths {
            (self.collectionView!.cellForItem(at: indexPath) as! PhotoCell).checked(false)
            print((self.collectionView!.cellForItem(at: indexPath) as! PhotoCell).checkmarkImageView?.isHidden)
        }
        
        navigationItem.title = "TEMPSHOT"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(ViewController.newPhoto(_:)))
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Info", style: .plain, target: self, action: #selector(ViewController.pressedInfo(_:)))
        
        self.isEditing = false
        
        self.collectionView.reloadData()
    }
    
    
    // Handle selection of cells
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if (isEditing) {
            (self.collectionView!.cellForItem(at: indexPath) as! PhotoCell).setupSubviews()
            (self.collectionView!.cellForItem(at: indexPath) as! PhotoCell).checked(true)
        } else {
            if !buttonTouched {
                self.performSegue(withIdentifier: "showLargeImageView", sender: self)
                buttonTouched = true
            }
        }
    }
    
    // Handle deselection of cells
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if (isEditing) {
            (self.collectionView!.cellForItem(at: indexPath) as! PhotoCell).checked(false)
        }
    }
    
    // Passes pertinent information to new view controllers
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // EnlargedPhotoViewController
        if (segue.identifier == "showLargeImageView") {
            let indexPaths = self.collectionView!.indexPathsForSelectedItems
            let indexPath = indexPaths![0]
            let vc = segue.destination as! EnlargedPhotoViewController
            let transiphoto = fetchedResultsController.object(at: indexPath) as! Transiphoto
            vc.transiphoto = transiphoto
        // InfoHelpViewController
        } else if (segue.identifier == "infoPageSegue") {
            let vc = segue.destination as! InfoHelpViewController
        }
    }
    
    // Called when user presses Delete
    func pushedDelete(_ sender: UIBarButtonItem) {
        if (self.collectionView!.indexPathsForSelectedItems!.count == 0) {
            // if nothing is selected
            let destructAlertController = UIAlertController(title: "Self-Destruct?", message: "All your photos will be deleted. No items will be recoverable and it would be a pity if you couldn't copy your friend's homework you took pictures of...this is a joke", preferredStyle: .alert)
            destructAlertController.addAction(UIAlertAction(title: "Yes, kindly delete everything", style: .destructive, handler: { (action) -> Void in
                // Do nothing lololol
                self.isEditing = false
            }))
            
            // present the alert
            self.navigationController?.present(destructAlertController, animated: true, completion: nil)
        } else  {
            // default delete action
            let alertController = UIAlertController(title: "Delete?", message: "Items are not recoverable!", preferredStyle: .alert)
            let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (action) -> Void in
                // call the delete method
                self.deleteSelectedItemsAction()
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) -> Void in
                // Do nothing
            }
            alertController.addAction(deleteAction)
            alertController.addAction(cancelAction)
            
            // present the alert
            self.navigationController?.present(alertController, animated: true, completion: nil)
        }
    }
    
    // called to delete and update the managed object context and collectionview
    func deleteSelectedItemsAction() {
        let selectedIndexPaths: [IndexPath] = self.collectionView!.indexPathsForSelectedItems!
        for indexPath in selectedIndexPaths  {
            // delete and update the managed object context
            managedObjectContext.delete(fetchedResultsController.object(at: indexPath) as! NSManagedObject)
            do {
                try managedObjectContext.save()
            } catch {
                return
            }
        }
        
        // perform the post fetch
        do {
            try fetchedResultsController.performFetch()
            print("performed post fetch")
        } catch {
            print("Failed to fetch")
        }
        
        // Animate the changes
        self.collectionView.performBatchUpdates({self.collectionView.deleteItems(at: selectedIndexPaths)}, completion: nil)
        self.isEditing = false
    }
    

    
    

}

