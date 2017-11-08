//
//  InfoHelpViewController.swift
//  TempShot
//
//  Created by Ryan Tsang on 8/8/16.
//  Copyright © 2016 Ryan Tsang. All rights reserved.
//

import UIKit
import StoreKit

class InfoHelpViewController: UIViewController {
    
    @IBOutlet weak var removeAdsButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        buttonTouched = false
        /*
        // Set IAPs
        if (SKPaymentQueue.canMakePayments()) {
            print("IAP is enabled")
            var productID: NSSet = NSSet(object: "com.tsunamisoftware.TempShot.RemoveAds")
            var request: SKProductsRequest = SKProductsRequest(productIdentifiers: productID as! Set<String>)
            request.delegate = self
            request.start()
            // maybe add?
            SKPaymentQueue.defaultQueue().addTransactionObserver(self)
        } else  {
            print("please enable iaps")
        }
        
        removeAdsButton.enabled = false
        */
        
        // Theme
        view.backgroundColor = UIColor.black
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var shouldAutorotate : Bool {
        return true
    }
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return [UIInterfaceOrientationMask.portrait]
    }
    
    @IBAction func aboutUsPressed(_ sender: UIButton) {
        UIApplication.shared.openURL(URL(string: "https://drtsunami.github.io/Tsunametry")!)
    }
    
    /*
    var list = [SKProduct]()
    var p = SKProduct()
    
    @IBAction func removeAdsPressed(sender: UIButton) {
        
        for product in list {
            var prodID = product.productIdentifier
            if prodID == "com.tsunamisoftware.TempShot.RemoveAds" {
                p = product
                buyProduct()
                break
            }
        }
    }
    
    @IBAction func RestorePurchases(sender: UIButton) {
        // SKPaymentQueue.defaultQueue().addTransactionObserver(self)
        SKPaymentQueue.defaultQueue().restoreCompletedTransactions()
    }
    
    
    func buyProduct() {
        print("buy \(p.productIdentifier)")
        let pay = SKPayment(product: p)
        SKPaymentQueue.defaultQueue().addPayment(pay as SKPayment)
        // SKPaymentQueue.defaultQueue().addTransactionObserver(self)
    }
    
    func productsRequest(request: SKProductsRequest, didReceiveResponse response: SKProductsResponse) {
        print("product request")
        let myProduct = response.products
        
        for product in myProduct {
            print("product added")
            print(product.productIdentifier)
            print(product.localizedTitle)
            print(product.localizedDescription)
            print(product.price)
            
            list.append(product as SKProduct)
        }
        
        removeAdsButton.enabled = true
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(queue: SKPaymentQueue) {
        print("transactions restored")
        
        let purchasedItemsIDs = []
        for transaction in queue.transactions {
            let t: SKPaymentTransaction = transaction as SKPaymentTransaction
            
            let prodID = t.payment.productIdentifier as String
            
            switch prodID {
            case "com.tsunamisoftware.TempShot.RemoveAds":
                print("remove ads")
                removeAds()
                break
            default:
                print("iap not setup")
                break
            }
            
        }
    }
    
    func paymentQueue(queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        print("add payment")
        
        for transaction: AnyObject in transactions {
            let trans = transaction as! SKPaymentTransaction
            print(trans.error)
            
            switch trans.transactionState {
            
                case .Purchased:
                    print("buy, unlock iap here")
                    print(p.productIdentifier)
                
                    let prodID = p.productIdentifier
                    
                    switch prodID {
                        case "com.tsunamisoftware.TempShot.RemoveAds":
                            print("remove ads")
                            removeAds()
                            break
                        default:
                            print("iap not setup")
                            break
                    }
                    queue.finishTransaction(trans)
                    break
                case .Failed:
                    print("buy error")
                    queue.finishTransaction(trans)
                    break
                default:
                    print("default")
                    break
            }
        }
    }
  
    func finishTransaction(trans: SKPaymentTransaction) {
        print("finish here")
    }
    
    func paymentQueue(queue: SKPaymentQueue, removedTransactions transactions: [SKPaymentTransaction]) {
        print("remove trans")
    }
    
    func removeAds() {
        prefs.setBool(false, forKey: "adsDisplayed")
        print("adsDisplayer = \(prefs.boolForKey("adsDisplayed"))")
    }
    */
    

}
