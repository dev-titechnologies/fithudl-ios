//
//  IAPHelper.swift
//  inappragedemo
//
//  Created by Ray Fix on 5/1/15.
//  Copyright (c) 2015 Razeware LLC. All rights reserved.
//
import UIKit
import StoreKit

/// Notification that is generated when a product is purchased.
public let IAPHelperProductPurchasedNotification = "IAPHelperProductPurchasedNotification"

/// Product identifiers are unique strings registered on the app store.
public typealias ProductIdentifier = String

/// Completion handler called when products are fetched.
public typealias RequestProductsCompletionHandler = (success: Bool, products: [SKProduct]) -> ()


/// A Helper class for In-App-Purchases, it can fetch products, tell you if a product has been purchased,
/// purchase products, and restore purchases.  Uses NSUserDefaults to cache if a product has been purchased.

protocol IAPHelperClassDelegate {
    
    func requestForSendingTransactionId(string: NSString)
}




public class IAPHelper : NSObject  {
  
  /// MARK: - Private Properties
  
    var helperdelegate : IAPHelperClassDelegate?
    
  // Used to keep track of the possible products and which ones have been purchased.
  private let productIdentifiers: Set<ProductIdentifier>
  private var purchasedProductIdentifiers = Set<ProductIdentifier>()
  
  // Used by SKProductsRequestDelegate
  private var productsRequest: SKProductsRequest?
  private var completionHandler: RequestProductsCompletionHandler?
  
  /// MARK: - User facing API
  
  /// Initialize the helper.  Pass in the set of ProductIdentifiers supported by the app.
  public init(productIdentifiers: Set<ProductIdentifier>) {
    
    self.productIdentifiers = productIdentifiers
    for productIdentifier in productIdentifiers {
      let purchased = NSUserDefaults.standardUserDefaults().boolForKey(productIdentifier)
      if purchased {
        purchasedProductIdentifiers.insert(productIdentifier)
        println("Previously purchased: \(productIdentifier)")
      }
      else {
        println("Not purchased: \(productIdentifier)")
      }
    }
    super.init()
    SKPaymentQueue.defaultQueue().addTransactionObserver(self)
  }
  
  /// Gets the list of SKProducts from the Apple server calls the handler with the list of products.
  public func requestProductsWithCompletionHandler(handler: RequestProductsCompletionHandler) {
    println("Request product with completion handler")
    completionHandler = handler
    productsRequest = SKProductsRequest(productIdentifiers: productIdentifiers)
    productsRequest?.delegate = self
    productsRequest?.start()
  }
  
  /// Initiates purchase of a product.
  public func purchaseProduct(product: SKProduct) {
    
    println("Buying \(product.productIdentifier)...")
    let payment = SKPayment(product: product)
    SKPaymentQueue.defaultQueue().addPayment(payment)
  }
  
  /// Given the product identifier, returns true if that product has been purchased.
  public func isProductPurchased(productIdentifier: ProductIdentifier) -> Bool {
    return purchasedProductIdentifiers.contains(productIdentifier)
  }
  
  /// If the state of whether purchases have been made is lost  (e.g. the
  /// user deletes and reinstalls the app) this will recover the purchases.
  public func restoreCompletedTransactions() {
    
    SKPaymentQueue.defaultQueue().restoreCompletedTransactions()
  }
  
  public class func canMakePayments() -> Bool {
    return SKPaymentQueue.canMakePayments()
  }
}

// This extension is used to get a list of products, their titles, descriptions,
// and prices from the Apple server.

extension IAPHelper: SKProductsRequestDelegate {
  public func productsRequest(request: SKProductsRequest!, didReceiveResponse response: SKProductsResponse!) {
    println("Loaded list of products...\(response)")
    let products = response.products as! [SKProduct]
    
    println("IAP products \(products)")
    
    completionHandler?(success: true, products: products)
    clearRequest()
    
    // debug printing
    for p in products {
      println("Found product: \(p.productIdentifier) \(p.localizedTitle) \(p.price.floatValue)")
    }
    
    NSNotificationCenter.defaultCenter().postNotificationName("LoadingCompleted", object: nil)

  }
  
  public func request(request: SKRequest!, didFailWithError error: NSError!) {
    println("Failed to load list of products.")
    println("Error: \(error)")
    clearRequest()
    NSNotificationCenter.defaultCenter().postNotificationName("LoadingCompleted", object: nil)
  }
  
  private func clearRequest() {
    productsRequest = nil
    completionHandler = nil
  }
}


extension IAPHelper: SKPaymentTransactionObserver {
    
    
    
  /// This is a function called by the payment queue, not to be called directly.
  /// For each transaction act accordingly, save in the purchased cache, issue notifications,
  /// mark the transaction as complete.o
    
  public func paymentQueue(queue:
    SKPaymentQueue!, updatedTransactions transactions: [AnyObject]!) {
        
        println("IN LLLOOOOO")
    for transaction in transactions as! [SKPaymentTransaction] {
      switch (transaction.transactionState) {
      case .Purchased:
        completeTransaction(transaction)
        break
      case .Failed:
        println("failed trnsaction")
       failedTransaction(transaction)
        break
      case .Restored:
        restoreTransaction(transaction)
        break
      case .Deferred:
        break
      case .Purchasing:
        break
      }
    }
  }
  
  private func completeTransaction(transaction: SKPaymentTransaction) {
    
    //self.helperdelegate?.requestForSendingTransactionId(transaction.transactionIdentifier)
    println("completeTransaction... \(transaction.transactionIdentifier)")
    provideContentForProductIdentifier(transaction.payment.productIdentifier)
    
    SKPaymentQueue.defaultQueue().finishTransaction(transaction)
    
    let defaults = NSUserDefaults.standardUserDefaults()
    defaults.setObject(transaction.transactionIdentifier, forKey: "transaction_id")
    
   // NSUserDefaults().setValue(transaction.transactionIdentifier, forKey: "transaction_id")
    NSNotificationCenter.defaultCenter().postNotificationName("transactionCompleted", object: nil)
    NSNotificationCenter.defaultCenter().postNotificationName("LoadingCompleted", object: nil)
    
  }
  
  private func restoreTransaction(transaction: SKPaymentTransaction) {
    
    let productIdentifier = transaction.originalTransaction.payment.productIdentifier
    println("restoreTransaction... \(productIdentifier)")
    provideContentForProductIdentifier(productIdentifier)
    NSNotificationCenter.defaultCenter().postNotificationName("LoadingCompleted", object: nil)
    SKPaymentQueue.defaultQueue().finishTransaction(transaction)
    
  }
  
  // Helper: Saves the fact that the product has been purchased and posts a notification.
    
  private func provideContentForProductIdentifier(productIdentifier: String) {
    
    purchasedProductIdentifiers.insert(productIdentifier)
    NSUserDefaults.standardUserDefaults().setBool(true, forKey: productIdentifier)
    NSUserDefaults.standardUserDefaults().synchronize()
    NSNotificationCenter.defaultCenter().postNotificationName(IAPHelperProductPurchasedNotification, object: productIdentifier)
    
  }
  
  private func failedTransaction(transaction: SKPaymentTransaction) {
    
    println("failedTransaction... ghgh")
    if transaction.error.code != SKErrorPaymentCancelled {
        println("transaction cancelled")
       println("Transaction error: \(transaction.error.localizedDescription)")
    } else {
        println("transaction not cancelled")
    }
    NSNotificationCenter.defaultCenter().postNotificationName("LoadingCompleted", object: nil)
    SKPaymentQueue.defaultQueue().finishTransaction(transaction)
  }
}