//
//  ViewController.swift
//  Paging_Swift
//
//  Created by Olga Dalton on 26/10/14.
//  Copyright (c) 2014 swiftiostutorials.com. All rights reserved.
//

import UIKit

class IntroViewController: UIViewController, UIPageViewControllerDataSource {
    
    // MARK: - Variables
    @IBOutlet weak var skipButton : UIButton?
    @IBOutlet weak var readyButton : UIButton?
    private var pageViewController: UIPageViewController?
    var getredyButtonFlag: Int = 0
    
    // Initialize it right away here
    private let contentImages = ["1.png",
        "2.png",
        "3.png",
        "4.png","5.png","6.png"];
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBarHidden = true
       
        createPageViewController()
        setupPageControl()
        self.readyButton?.hidden = true
        if getredyButtonFlag == 1{
           self.readyButton!.setTitle("Done", forState: UIControlState.Normal)
        }else {
            self.readyButton!.setTitle("Get Started", forState: UIControlState.Normal)
        }
    }
    
    @IBAction func skipButtonClicked(sender: UIButton){
        
        
    }
    private func createPageViewController() {
        
        let pageController = self.storyboard!.instantiateViewControllerWithIdentifier("PageController") as! UIPageViewController
        pageController.dataSource = nil
        pageController.dataSource = self
        
        if contentImages.count > 0 {
            let firstController = getItemController(0)!
            let startingViewControllers: NSArray = [firstController]
            pageController.setViewControllers(startingViewControllers as [AnyObject], direction: UIPageViewControllerNavigationDirection.Forward, animated: false, completion: nil)
        }
        
        pageViewController = pageController
        //pageViewController?.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-50)
        addChildViewController(pageViewController!)
        self.view.addSubview(pageViewController!.view)
        pageViewController!.didMoveToParentViewController(self)
        self.skipButton!.superview!.bringSubviewToFront(self.skipButton!)
        self.readyButton!.superview!.bringSubviewToFront(self.readyButton!)
    }
    
    private func setupPageControl() {
        let appearance = UIPageControl.appearance()
        appearance.pageIndicatorTintColor = UIColor.whiteColor()
        appearance.currentPageIndicatorTintColor = AppColor.boxBorderColor
        appearance.backgroundColor = UIColor.clearColor()
        //appearance.superview!.bringSubviewToFront(appearance)
    }
    
    // MARK: - UIPageViewControllerDataSource
    
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        
        let itemController = viewController as! PageItemController
        println("Count before\(itemController.itemIndex)")
        
        if itemController.itemIndex == 5{
            self.readyButton?.hidden = false
            self.skipButton?.hidden  = true
        }else {
            self.readyButton?.hidden = true
            self.skipButton?.hidden  = false
        }
        if itemController.itemIndex > 0 {
            return getItemController(itemController.itemIndex-1)
        }
        
        return nil
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        
        
        let itemController = viewController as! PageItemController
        if itemController.itemIndex == 5{
            self.readyButton?.hidden = false
            self.skipButton?.hidden  = true
        }else {
            self.readyButton?.hidden = true
            self.skipButton?.hidden  = false
        }
        println("Count after \(itemController.itemIndex)")
        if itemController.itemIndex+1 < contentImages.count {
            return getItemController(itemController.itemIndex+1)
        }
        
        return nil
    }
    private func getItemController(itemIndex: Int) -> PageItemController? {
        println("Count \(itemIndex)")
        if itemIndex < contentImages.count {
            let pageItemController = self.storyboard!.instantiateViewControllerWithIdentifier("ItemController") as! PageItemController
            pageItemController.itemIndex = itemIndex
            pageItemController.imageName = contentImages[itemIndex]
            return pageItemController
        }
        return nil
    }
    
    // MARK: - Page Indicator
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return contentImages.count
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        println("Count after \(pageViewController)")
        return 0
    }
    
}

