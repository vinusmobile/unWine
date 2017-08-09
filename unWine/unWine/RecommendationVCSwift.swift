//
//  RecommendationVCSwift.swift
//  unWine
//
//  Created by Fabio Gomez on 5/9/17.
//  Copyright © 2017 LION Mobile. All rights reserved.
//

import UIKit
import Koloda
import pop
import ParseUI
import SwiftyBeaver
import Branch
import PKHUD
import Appboy_iOS_SDK
//import NUI

enum RecommendationABCType: Int {
    case None = 0
    case FriendInvite
    case Purchase
    case Both
}

let log = SwiftyBeaver.self
let UNWINE_RED = UIColor.init(colorLiteralRed: 171.0/255, green: 17.0/255, blue: 36.0/255, alpha: 1.0)

// add log destinations. at least one is needed!
let console = ConsoleDestination()  // log to Xcode Console

private let numberOfCards: Int = 5
private let frameAnimationSpringBounciness: CGFloat = 9
private let frameAnimationSpringSpeed: CGFloat = 16
private let kolodaCountOfVisibleCards = 2
private let kolodaAlphaValueSemiTransparent: CGFloat = 0.1
private let user = User.current()!
private let kSwipeLimit = PFConfig.current()["RECOMMENDATION_SWIPE_LIMIT"] as! Int
private let kColorWhite = 0xFFFCFA
private let kColorBlack = 0x333333
private let kColorRed = 0x9C2C31
private let kColorGreen = 0x61B24E

// User Defaults Stuff
private let kFirstTime = "RecommendationFirstTimeSeeingRecommendation"
private let kFirstRightSwipe = "RecommendationFirstRightSwipe"
private let kFirstLeftSwipe = "RecommendationFirstLeftSwipe"
private let kFirstRightButton = "RecommendationFirstRightButton"
private let kFirstLeftButton = "RecommendationFirstLeftButton"
private let kSwipeCounter = "RecommendationSwipeCounter"
private let kWineRecommendationsIdentifier = "com.LionMobile.unWine.WineRecommendations"

class RecommendationVCSwift: UIViewController {
    // UI Stuff
    @IBOutlet var kolodaView: CustomKolodaView!
    @IBOutlet var topBar: UIView!
    @IBOutlet var OKButton: UIButton!
    @IBOutlet var cancelButton: UIButton!
    @IBOutlet var restorePurchaseButton: UIButton!

    // Track View State
    private var loaded = false
    var tappedButton = false
    
    // Analytics Stuff
    var firstTime:Bool = (UserDefaults.standard.object(forKey: kFirstTime) == nil)
    var firstRightSwipe:Bool = (UserDefaults.standard.object(forKey: kFirstRightSwipe) == nil)
    var firstLeftSwipe:Bool = (UserDefaults.standard.object(forKey: kFirstLeftSwipe) == nil)
    var firstRightButton:Bool = (UserDefaults.standard.object(forKey: kFirstRightButton) == nil)
    var firstLeftButton:Bool = (UserDefaults.standard.object(forKey: kFirstLeftButton) == nil)
    
    // App Invite Stuff
    private var inviteURL:NSString? = nil
    var inviteCounter = 0
    let branchUniversalObject: BranchUniversalObject = BranchUniversalObject(canonicalIdentifier: "invite/\(user.objectId!)")
    
    // Recommendation Wines
    var wines: NSArray = [PFObject]() as NSArray
    var pages = 0
    var swipeCounter:Int = (UserDefaults.standard.object(forKey: kSwipeCounter) == nil) ? 0 :
        UserDefaults.standard.object(forKey: kSwipeCounter) as! Int
    
    func increaseSwipeCounter() {
        self.swipeCounter += 1
        UserDefaults.standard.set(self.swipeCounter, forKey: kSwipeCounter)
    }

    func decreaseSwipeCounter() {
        self.swipeCounter -= 1
        UserDefaults.standard.set(self.swipeCounter, forKey: kSwipeCounter)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        log.addDestination(console)
        
        // Get Wine Recommendations
        self.getRecommendations()
        
        // SetUpBranch Link
        self.setUpBranchLink()
        
        // Setup In-App Purchase
        self.setUpInAppPurchaseObserver()
        
        // Setup AppBoy UI Delegate
        Appboy.sharedInstance()!.inAppMessageController.delegate = self;
        
        // Setup Recommendation Prompt, followed by UI
        user.randomlySetPromptType().continue(with: BFExecutor.mainThread(), with: { (task) -> Any? in
            if (task.error != nil) {
                log.error("Something happened: \(task.error!)")
                ParseMiddleMan.trackError(task.error!, name: "SettingRecommendationPromptType", andMessage: "Something happened")
                return nil
            }
            
            self.setUpUI()
            
            return nil;
        })
    }

    func setUpInAppPurchaseObserver() {
        // Use the product identifier from iTunes to register a handler.
        PFPurchase.addObserver(forProduct: kWineRecommendationsIdentifier) {
            (transaction: SKPaymentTransaction?) -> Void in

            user.awardRecommendations().continue(with: BFExecutor.mainThread(), with: { (task) -> Any? in
                HUD.hide()
                
                if (task.error != nil) {
                    log.error("Something happened: \(task.error!)")
                    ParseMiddleMan.trackError(task.error!, name: "AwardingWineRecommendations", andMessage: "Something happened")
                    return nil
                }
                
                if transaction?.transactionState == SKPaymentTransactionState.purchased {
                    log.info("Success Purchasing recommendations")
                    ParseMiddleMan.trackRecommendationUserPurchasedWineRecommendations()
                
                } else if transaction?.transactionState == SKPaymentTransactionState.restored {
                    log.info("Success Restoring recommendations")
                    ParseMiddleMan.trackRecommendationUserRestoredWineRecommendations()
                    self.showSimpleAlert("You have successfully restored the Wine Recommendation Engine", title: "Congrats!")
                }
                
                self.restorePurchaseButton.isHidden = true
                
                return nil
            })
        }
    }
    
    func purchaseRecommendations() {
        log.info("Enter")
        PFPurchase.buyProduct(kWineRecommendationsIdentifier) { (error) in
            if error == nil {
                // Run UI logic that informs user the product has been purchased, such as displaying an alert view.
                self.showSimpleAlert("You now have have the full blown Wine Recommendation Engine! 😎", title: "Thank You!")
                
            } else {
                ParseMiddleMan.trackError(error, name: "PurchaseWineRecommendations", andMessage: "Something happened")
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if firstTime == true {
            UserDefaults.standard.set(true, forKey: kFirstTime)
            self.firstTime = false
            self.showSimpleAlert("Welcome to Wine Discovery. You will see wines based on your taste preference. Swipe Right to add to your Wishlist and Swipe left to Discard", title: "Wine Discovery")
        }
        
        if loaded == false {
            self.kolodaView.reloadData()
            loaded = true
        }
    }
    
    func setUpUI () {
        kolodaView.backgroundColor = UNWINE_RED
        kolodaView.alphaValueSemiTransparent = kolodaAlphaValueSemiTransparent
        kolodaView.countOfVisibleCards = kolodaCountOfVisibleCards
        kolodaView.delegate = self as KolodaViewDelegate
        kolodaView.dataSource = self as KolodaViewDataSource
        kolodaView.animator = BackgroundKolodaAnimator(koloda: kolodaView)
        
        self.topBar.backgroundColor = UNWINE_RED
        self.view.backgroundColor = UNWINE_RED
        self.modalTransitionStyle = UIModalTransitionStyle.flipHorizontal
        
        // Hide Restore Purchase button if already have purchase
        if user.hasWineRecommendations == true {
            log.info("Already have purchase. Hidding")
            self.restorePurchaseButton.isHidden = true
            
        } else if user.recommendationPromptType == Int(RecommendationPromptTypeBoth.rawValue) {
            self.restorePurchaseButton.isHidden = false
            
        } else if user.recommendationPromptType == Int(RecommendationPromptTypeFriendInvite.rawValue) {
            self.restorePurchaseButton.isHidden = true
            
        } else if user.recommendationPromptType == Int(RecommendationPromptTypePurchase.rawValue) {
            self.restorePurchaseButton.isHidden = false
        }
    }
    
    func getRecommendations () {
        let query = PFQuery(className:"unWine")
        let pageSize = 100
        query.whereKey("userGeneratedFlag", equalTo: true)
        query.whereKeyExists("image")
        query.limit = pageSize
        
        if self.pages > 0 {
            HUD.show(.progress)
            query.skip = self.pages * pageSize
            log.info("Skipping \(query.skip) wines")
        } else {
            log.info("First Load")
        }
        
        log.info("Querying wines")

        query.findObjectsInBackground().continue(with: BFExecutor.mainThread(), withSuccessBlock: { task in
            log.info("Got \(String(describing: task.result!.count)) wines. Now checking if they are in wishlist")
            return user.filterOutWines(inWishlist: task.result as! [Any])
            
        }).continue(with: BFExecutor.mainThread(), with: { task in
            HUD.hide()
            
            if (task.error != nil) {
                log.error(task.error ?? "No error?")
                return nil
            }
            
            log.info("Found \(self.wines.count) wines. Reloading UI")
            
            self.wines = self.shuffle(array: task.result as! NSArray)
            
            if self.pages > 0 {
                self.kolodaView.reloadData()
            }
            
            return nil
        })
    }
    
    func shuffle(array: NSArray) -> NSArray {
        
        let newArray : NSMutableArray = NSMutableArray(array: array)
        
        let count : NSInteger = newArray.count
        
        for i in 0 ..< count {
            
            let remainingCount = count - i
            
            //figre out error below
            
            let exchangeIndex = i + Int(arc4random_uniform(UInt32(remainingCount)))
            
            newArray.exchangeObject(at: i, withObjectAt: exchangeIndex)
        }
        
        return NSArray(array: newArray)
        
    }
    
    func addWineToCellar(_ wine: unWine) {
        log.info("Enter")

        user.addWine(toCellar: wine).continue(with: BFExecutor.mainThread(), withSuccessBlock: { (task) -> Any? in
            log.info("Added to Wishlist! Now increasing swipe Right Counter")
            return wine.increaseSwipeRightCounter()
            
        }).continue(with: BFExecutor.mainThread(), with: { (task) -> Any? in
            
            if (task.error != nil) {
                log.error("Something happened: \(String(describing: task.error))")
                ParseMiddleMan.trackError(task.error!, name: "DiscoverAddWine", andMessage: "Something Happened")
                self.tappedButton = false
                return nil
            }
            
            log.info("Success!!!")
            
            return nil
        })
    }
    
    func removeWineFromCellar(_ wine: unWine) {
        log.info("Enter")

        user.removeWine(fromCellar: wine).continue(with: BFExecutor.mainThread(), withSuccessBlock: { (task) -> Any? in
            log.info("Removed from Wishlist! Now increasing swipe Left Counter")
            return wine.increaseSwipeLeftCounter()
            
        }).continue(with: BFExecutor.mainThread(), with: { (task) -> Any? in
            if (task.error != nil) {
                log.error("Something happened: \(String(describing: task.error))")
                ParseMiddleMan.trackError(task.error!, name: "DiscoverRemoveWine", andMessage: "Something Happened")
                self.tappedButton = false
                return nil
            }
            
            log.info("Success!!!")
            
            return nil
        })
    }

    //MARK: IBActions
    @IBAction func leftButtonTapped() {
        self.tappedButton = true
        kolodaView?.swipe(.left)
    }
    
    @IBAction func rightButtonTapped() {
        self.tappedButton = true
        kolodaView?.swipe(.right)
    }
    
    @IBAction func undoButtonTapped() {
        kolodaView?.revertAction()
        if self.swipeCounter > 0 {
            self.decreaseSwipeCounter()
        }
        ParseMiddleMan.trackRecommendationUserTappedRewindButton()
    }
    
    @IBAction func restorePurchase(_ sender: UIButton) {
        log.info("Restoring Purchase")
        HUD.show(.progress)
        PFPurchase.restore()
    }
    
    // App Sharing setup
    func setUpBranchLink() {
        // Setup sharing link
        self.branchUniversalObject.title = "I want you to try unWine App"
        self.branchUniversalObject.contentDescription = User.getShareMessage()
        self.branchUniversalObject.imageUrl = "https://parsefiles.back4app.com/wa6ntcTk5msrS1u6sNb009m2iEqM8ETcjgANoktj/mfp_mfp_384c5d3ed090267da9bc9c7f73e779e0u_app_invite.png"
        self.branchUniversalObject.addMetadataKey("userId", value: user.objectId!)
        self.branchUniversalObject.addMetadataKey("userName", value: user.getName())
        
        let linkProperties: BranchLinkProperties = BranchLinkProperties()
        linkProperties.feature = "invites"
        
        self.branchUniversalObject.getShortUrl(with: linkProperties) { (url, error) in
            if (error == nil) {
                log.info("Got my Branch link to share: \(url!)")
                self.inviteURL = url! as NSString
            } else {
                log.info(String(format: "Branch error : %@", error! as CVarArg))
            }
        }
    }
    
    
    /*
     UIAlert Stuff
     */
    func showShareSheet() {
        let linkProperties: BranchLinkProperties = BranchLinkProperties()
        linkProperties.feature = "invites"
        self.branchUniversalObject.showShareSheet(with: linkProperties,
                                                  andShareText: User.getShareMessage(),
                                                  from: self)
        { (activityType, completed) in
            
            if completed == false {
                log.info("Link sharing cancelled")
                return
            }
            
            let activity = activityType!.lowercased() as NSString
            log.info(String(format: "Completed sharing to %@", activityType!))

            // Count only if facebook, text, twitter, email, messenger, whatsapp
            if !(activity.contains("facebook")  ||
                activity.contains("twitter")    ||
                activity.contains("whatsapp")   ||
                activity.contains("messenger")  ||
                activity.contains("mail")       ||
                activity.contains("message")    ||
                activity.contains("slack")      ||
                activity.contains("linkedin")) {
                
                log.info("Not shared in the right place")
                self.showShareSheet()
                return
            }
            
            log.info("shared in right place")
            self.inviteCounter += 1
            ParseMiddleMan.trackRecommendationUserSharedApp(activity as String!)

            // Show again if app was not shared enough times
            if self.inviteCounter < 5 {
                // Flash some text
                HUD.flash(.label("Awesome. \(5 - self.inviteCounter) more to go! 😁"), delay: 1.0) { finished in
                    // Completion Handler
                    log.info("Showing Share Sheet again")
                    self.showShareSheet()
                }
                return
            }
            
            log.info("Awarding Recommendations")
            user.awardRecommendations().continue(with: BFExecutor.mainThread(), with: { (task) -> Any? in
                if (task.error != nil) {
                    log.error("Something happened: \(task.error!)")
                    return nil
                }
                log.info("Success awarding recommendations")
                ParseMiddleMan.trackRecommendationUserObtainedWineRecommendationsThroughAppInvites()
                
                // Show Success Alert
                self.showSimpleAlert("You have been awarded the full-featured Wine Recommendation Engine! 😎", title: "Congrats!!!")
                
                return nil
            })
        }
    }

    func showInviteAlert () {
        let inviteButton = ABKInAppMessageButton()
        inviteButton.buttonText = "Invite"
        inviteButton.buttonTextColor = UIColor(rgb: kColorWhite)
        inviteButton.buttonBackgroundColor = UIColor(rgb: kColorRed)
        inviteButton.setButtonClickAction(.noneClickAction, withURI: nil)
        
        let purchaseButton = ABKInAppMessageButton()
        purchaseButton.buttonText = "Purchase"
        purchaseButton.buttonTextColor = UIColor(rgb: kColorWhite)
        purchaseButton.buttonBackgroundColor = UIColor(rgb: kColorGreen)
        purchaseButton.setButtonClickAction(.noneClickAction, withURI: nil)
        
        let alert = ABKInAppMessageModal()
        alert.header = "Discover"
        alert.message = "You've reached your swipe limit. Please either share the app 5 times or purchase Recommendation Engine to get unlimited recommendations."
        alert.closeButtonColor = UIColor(rgb: kColorBlack)
        alert.backgroundColor = UIColor(rgb: kColorWhite)
        //alert.imageURI = NSURL(string: "https://appboy-images.com/appboy/communication/marketing/slide_up/slide_up_message_parameters/images/55e0c42664617307440c0000/147326cf775c7ce6f24ad5ad731254f040ed97f7/original.?1440793642")! as URL
        //alert.setInAppMessageButtons([inviteButton, purchaseButton])
        
        // ABC Testing
        if user.recommendationPromptType == Int(RecommendationPromptTypeBoth.rawValue) {
            alert.setInAppMessageButtons([inviteButton, purchaseButton])

        } else if user.recommendationPromptType == Int(RecommendationPromptTypeFriendInvite.rawValue) {
            alert.message = "You've reached your swipe limit. Please share the app 5 times to get unlimited recommendations."
            alert.setInAppMessageButtons([inviteButton])

        } else if user.recommendationPromptType == Int(RecommendationPromptTypePurchase.rawValue) {
            alert.message = "You've reached your swipe limit. Please purchase Recommendation Engine to get unlimited recommendations."
            alert.setInAppMessageButtons([purchaseButton])
        }
        
        let messageController = Appboy.sharedInstance()?.inAppMessageController
        messageController?.add(alert)
        
        ParseMiddleMan.trackRecommendationUserSawInviteAlert()
    }
    
    
    func showSimpleAlert (_ message: String, title: String? = "Wishlist") {
        //let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        //alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        //self.present(alert, animated: true, completion: nil)
        
        let button = ABKInAppMessageButton()
        button.buttonText = "OK"
        button.buttonTextColor = UIColor(rgb: kColorWhite)
        button.buttonBackgroundColor = UIColor(rgb: kColorGreen)
        button.setButtonClickAction(.noneClickAction, withURI: nil)
        
        let alert = ABKInAppMessageModal()
        alert.header = title!
        alert.message = message
        alert.closeButtonColor = UIColor(rgb: kColorBlack)
        alert.backgroundColor = UIColor(rgb: kColorWhite)
        alert.setInAppMessageButtons([button])

        let messageController = Appboy.sharedInstance()?.inAppMessageController
        messageController?.add(alert)
    }
    
    func showWishListAlert (_ wine: unWine) {

        let skipButton = ABKInAppMessageButton()
        skipButton.buttonText = "Skip"
        skipButton.buttonTextColor = UIColor(rgb: kColorWhite)
        skipButton.buttonBackgroundColor = UIColor(rgb: kColorRed)
        skipButton.setButtonClickAction(.noneClickAction, withURI: nil)
        
        let addButton = ABKInAppMessageButton()
        addButton.buttonText = "Add to Wishlist"
        addButton.buttonTextColor = UIColor(rgb: kColorWhite)
        addButton.buttonBackgroundColor = UIColor(rgb: kColorGreen)
        addButton.setButtonClickAction(.noneClickAction, withURI: nil)
        
        let alert = ABKInAppMessageModal()
        alert.header = "Wishlist"
        alert.message = "Add this great wine to your Wishlist! 🍾"
        alert.closeButtonColor = UIColor(rgb: kColorBlack)
        alert.backgroundColor = UIColor(rgb: kColorWhite)
        alert.setInAppMessageButtons([skipButton, addButton])
        
        let messageController = Appboy.sharedInstance()?.inAppMessageController
        messageController?.add(alert)
    }
}

extension RecommendationVCSwift : ABKInAppMessageControllerDelegate {
    func on(inAppMessageButtonClicked inAppMessage: ABKInAppMessageImmersive, button: ABKInAppMessageButton) -> Bool {
        log.info("HIlota")
        if button.buttonText == "Invite" {
            self.showShareSheet()

        } else if button.buttonText == "Purchase" {
            self.purchaseRecommendations()

        } else if button.buttonText == "Add to Wishlist" {
            self.tappedButton = true
            kolodaView?.swipe(.right)

        } else if button.buttonText == "Skip" {
            self.tappedButton = true
            kolodaView?.swipe(.left)
        }
        
        return false;
    }
}

//MARK: KolodaViewDelegate
extension RecommendationVCSwift : KolodaViewDelegate {
    
    // Card was swiped
    func koloda(_ koloda: KolodaView, didSwipeCardAt index: Int, in direction: SwipeResultDirection) {
        
        if self.swipeCounter >= (kSwipeLimit - 1) && user.hasWineRecommendations == false {
            kolodaView?.revertAction()
            // Show Alert
            self.showInviteAlert()
            return
        }
        
        self.increaseSwipeCounter()
        
        if direction == SwipeResultDirection.right ||
            direction == SwipeResultDirection.topRight ||
            direction == SwipeResultDirection.bottomRight ||
            direction == SwipeResultDirection.up {

            // Analytics
            if self.tappedButton {
                ParseMiddleMan.trackRecommendationUserTappedRightButton()
            } else {
                ParseMiddleMan.trackRecommendationUserSwipedRight()
            }
            
            // Show alert
            if self.firstRightSwipe == true && self.tappedButton == false {
                UserDefaults.standard.set(true, forKey: kFirstRightSwipe)
                self.firstRightSwipe = false
                self.showSimpleAlert("By swiping right, you just added this wine to your wishlist!")
                
            } else if self.firstRightButton == true && self.tappedButton == true {
                UserDefaults.standard.set(true, forKey: kFirstRightButton)
                self.firstRightButton = false
                self.showSimpleAlert("By pressing ✅ button, you just added this wine to your wishlist!")
            }
            
            self.tappedButton = false
            
            log.info("User swiped right")
            let wine:unWine = self.wines[index] as! unWine
            self.addWineToCellar(wine)
            
        } else {
            // Analytics
            if self.tappedButton {
                ParseMiddleMan.trackRecommendationUserTappedLeftButton()
            } else {
                ParseMiddleMan.trackRecommendationUserSwipedLeft()
            }

            // Show alert
            if self.firstLeftSwipe == true && self.tappedButton == false {
                UserDefaults.standard.set(true, forKey: kFirstLeftSwipe)
                self.firstLeftSwipe = false
                self.showSimpleAlert("By swiping left, you just discarded this wine!")
                
            } else if self.firstLeftButton == true && self.tappedButton == true {
                UserDefaults.standard.set(true, forKey: kFirstLeftButton)
                self.firstLeftButton = false
                self.showSimpleAlert("By pressing the ❌ button, you just discarded this wine!")
            }
            
            self.tappedButton = false
            
            log.info("User swiped left")
            
            let wine:unWine = self.wines[index] as! unWine
            self.removeWineFromCellar(wine)
        }
    }
    
    func kolodaDidRunOutOfCards(_ koloda: KolodaView) {
        kolodaView.resetCurrentCardIndex()
        self.pages += 1
        self.getRecommendations()
    }
    
    func koloda(_ koloda: KolodaView, didSelectCardAt index: Int) {
        let wine:unWine = self.wines[index] as! unWine
        self.showWishListAlert(wine)
    }
    
    func kolodaShouldApplyAppearAnimation(_ koloda: KolodaView) -> Bool {
        return true
    }
    
    func kolodaShouldMoveBackgroundCard(_ koloda: KolodaView) -> Bool {
        return false
    }
    
    func kolodaShouldTransparentizeNextCard(_ koloda: KolodaView) -> Bool {
        return true
    }
    
    func koloda(kolodaBackgroundCardAnimation koloda: KolodaView) -> POPPropertyAnimation? {
        let animation = POPSpringAnimation(propertyNamed: kPOPViewFrame)
        animation?.springBounciness = frameAnimationSpringBounciness
        animation?.springSpeed = frameAnimationSpringSpeed
        return animation
    }
}

// MARK: KolodaViewDataSource
extension RecommendationVCSwift: KolodaViewDataSource {
    
    func kolodaSpeedThatCardShouldDrag(_ koloda: KolodaView) -> DragSpeed {
        return .default
    }
    
    func kolodaNumberOfCards(_ koloda: KolodaView) -> Int {
        log.info("number of cards is \(self.wines.count)")
        return self.wines.count
    }
    
    func koloda(_ koloda: KolodaView, viewForCardAt index: Int) -> UIView {
        
        let wine:unWine = self.wines[index] as! unWine
        let screenSize = UIScreen.main.bounds
        let screenHeight = screenSize.height
        
        // iPhone 4 =
        // iPhone SE = 568
        // iPhone 6,7 = 667
        // iPhone 6+,7+ = 736
        let cardHeight = Int(koloda.bounds.height - 16)
        var cardWidth = 0
        
        //log.info("screen size \(screenHeight)")
        //log.info("koloda height: \(koloda.bounds.height)")
        //log.info("card height: \(cardHeight)")
    
        if screenHeight > 667 {
            cardWidth = 398
            
        } else if screenHeight > 568 {
            cardWidth = 359
            
        } else if screenHeight > 568 {
            cardWidth = 304
            
        } else {
            cardWidth = 304
        }

        let nameHeight = 40

        let frame =  CGRect(x: 8, y: 8, width: cardWidth, height: cardHeight)
        let imageFrame = CGRect(x: 0, y: 0, width: cardWidth, height: cardHeight - nameHeight)
        let nameViewFrame = CGRect(x: 0, y: cardHeight - 40, width: cardWidth, height: nameHeight)
        let nameLabelFrame = CGRect(x: 8, y: 0, width: cardWidth - 16, height: nameHeight)
        

        let card:UIView = UIView.init(frame: frame)
        
        let imageView = PFImageView(frame: imageFrame)
        imageView.image = UIImage(named: "placeholder2")
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFit
        imageView.contentMode = .scaleAspectFill
        imageView.file = wine.image
        imageView.loadInBackground()
        
        let nameView:UIView = UIView.init(frame: nameViewFrame)
        nameView.backgroundColor = UIColor.init(colorLiteralRed: 0, green: 0, blue: 0, alpha: 0.6)
        
        let nameLabel = UILabel(frame: nameLabelFrame)
        nameLabel.textAlignment = NSTextAlignment.center
        nameLabel.text = wine.getName() //wine.getWineName(wine)
        nameLabel.textColor = UIColor.white
        nameLabel.font = UIFont(name: "OpenSans-Bold", size: 14.0)
        nameView.addSubview(nameLabel)
        
        card.addSubview(imageView)
        card.addSubview(nameView)
        
        return card
    }
}

extension Array
{
    /** Randomizes the order of an array's elements. */
    mutating func shuffle()
    {
        for _ in 0..<10
        {
            sort { (_,_) in arc4random() < arc4random() }
        }
    }
}

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }
}
