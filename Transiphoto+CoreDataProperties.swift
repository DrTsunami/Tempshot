//
//  Transiphoto+CoreDataProperties.swift
//  TransiPhoto
//
//  Created by Ryan Tsang on 8/10/16.
//  Copyright © 2016 Ryan Tsang. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Transiphoto {

    @NSManaged var dateInitialized: Date?
    @NSManaged var daysRemaining: NSNumber?
    @NSManaged var expirationDate: Date?
    @NSManaged var image: Data?
    @NSManaged var thumbnail: Data?
    @NSManaged var name: String?
    @NSManaged var dateCreated: Date?

}
