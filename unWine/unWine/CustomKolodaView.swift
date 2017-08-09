//
//  CustomKolodaView.swift
//  Koloda
//
//  Created by Eugene Andreyev on 7/11/15.
//  Copyright (c) 2015 CocoaPods. All rights reserved.
//

import UIKit
import Koloda
import SwiftyBeaver

let defaultTopOffset: CGFloat = 20
let defaultHorizontalOffset: CGFloat = 10
let defaultHeightRatio: CGFloat = 1.25
let backgroundCardHorizontalMarginMultiplier: CGFloat = 0.25
let backgroundCardScalePercent: CGFloat = 1.5

class CustomKolodaView: KolodaView {

    override func frameForCard(at index: Int) -> CGRect {
        if index == 0 {
            // Actual Card Frame
            /*
            let topOffset: CGFloat = defaultTopOffset
            let xOffset: CGFloat = defaultHorizontalOffset
            let width = (self.frame).width - 2 * defaultHorizontalOffset
            let height = width * defaultHeightRatio
            let yOffset: CGFloat = topOffset
            let frame = CGRect(x: xOffset, y: yOffset, width: width, height: height)
            */

            let screenSize = UIScreen.main.bounds
            let screenHeight = screenSize.height
            
            // iPhone 4 =
            // iPhone SE = 568
            // iPhone 6,7 = 667
            // iPhone 6+,7+ = 736
            //log.info("screen size \(screenHeight)")
            var frame:CGRect? = nil
            let height = self.bounds.height - 16
            //log.info("koloda height: \(self.bounds.height)")
            //log.info("card height: \(height)")

            if screenHeight > 667 {
                frame =  CGRect(x: 8, y: 8, width: 398, height: height)//581)
                
            } else if screenHeight > 568 {
                frame =  CGRect(x: 8, y: 8, width: 359, height: height)
                
            } else if screenHeight > 480 {
                frame =  CGRect(x: 8, y: 8, width: 304, height: height)
                
            } else {
                frame =  CGRect(x: 8, y: 8, width: 304, height: height)
                
            }
            
            //log.info("frame size: \(String(describing: frame))")

            return frame!

        } else if index == 1 {
            // Background Card Frame
            let horizontalMargin = -self.bounds.width * backgroundCardHorizontalMarginMultiplier
            let width = self.bounds.width * backgroundCardScalePercent
            let height = width * defaultHeightRatio
            //log.info("Index 1 \(CGRect(x: horizontalMargin, y: 0, width: width, height: height))")
            return CGRect(x: horizontalMargin, y: 0, width: width, height: height)
        }
        return CGRect.zero
    }

}
