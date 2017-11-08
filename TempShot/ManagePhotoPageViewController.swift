//
//  ManagePhotoPageViewController.swift
//  TempShot
//
//  Created by Ryan Tsang on 8/29/16.
//  Copyright © 2016 Ryan Tsang. All rights reserved.
//

import UIKit
import CoreData


class ManagePhotoPageViewController: UIPageViewController {
    // var photos = ["photo1", "photo2", "photo3", "photo4", "photo5"]
    // TODO get managedObjectContext
    var currentIndex: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self
        
        // 1
        if let viewController = viewPhotoCommentController(currentIndex ?? 0) {
            let viewControllers = [viewController]
            // 2
            setViewControllers(
                viewControllers,
                direction: .Forward,
                animated: false,
                completion: nil
            )
        }
    }
    
    // TODO change return of the function
    func viewPhotoCommentController(index: Int) -> EnlargedPhotoViewController? {
        if let storyboard = storyboard,
            page = storyboard.instantiateViewControllerWithIdentifier("EnlargedPhotoViewController")
                as? EnlargedPhotoViewController {
                    page.photoName = photos[index]
                    page.photoIndex = index
                    return page
        }
        return nil
    }
}
