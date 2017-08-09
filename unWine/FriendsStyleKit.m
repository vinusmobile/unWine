//
//  FriendsStyleKit.m
//  unWine
//
//  Created by Fabio Gomez on 6/14/17.
//  Copyright © 2017 LION Mobile LLC. All rights reserved.
//
//  Generated by PaintCode
//  http://www.paintcodeapp.com
//
//  This code was generated by Trial version of PaintCode, therefore cannot be used for commercial purposes.
//

#import "FriendsStyleKit.h"


@implementation FriendsStyleKit

#pragma mark Cache

static UIColor* _fbBlue = nil;

#pragma mark Initialization

+ (void)initialize
{
    // Colors Initialization
    _fbBlue = [UIColor colorWithRed: 0.231 green: 0.349 blue: 0.596 alpha: 1];

}

#pragma mark Colors

+ (UIColor*)fbBlue { return _fbBlue; }

//// In Trial version of PaintCode, the code generation is limited to 3 canvases.
#pragma mark Drawing Methods

+ (void)drawFacebook
{
    [FriendsStyleKit drawFacebookWithFrame: CGRectMake(0, 0, 17, 31) resizing: FriendsStyleKitResizingBehaviorStretch];
}

+ (void)drawFacebookWithFrame: (CGRect)targetFrame resizing: (FriendsStyleKitResizingBehavior)resizing
{
    //// General Declarations
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //// Resize to Target Frame
    CGContextSaveGState(context);
    CGRect resizedFrame = FriendsStyleKitResizingBehaviorApply(resizing, CGRectMake(0, 0, 17, 31), targetFrame);
    CGContextTranslateCTM(context, resizedFrame.origin.x, resizedFrame.origin.y);
    CGContextScaleCTM(context, resizedFrame.size.width / 17, resizedFrame.size.height / 31);


    //// _002-facebook-logo
    {
        //// Path_490 Drawing
        UIBezierPath* path_490Path = [UIBezierPath bezierPath];
        [path_490Path moveToPoint: CGPointMake(15.97, 0.01)];
        [path_490Path addLineToPoint: CGPointMake(11.99, 0)];
        [path_490Path addCurveToPoint: CGPointMake(4.63, 7.55) controlPoint1: CGPointMake(7.52, 0) controlPoint2: CGPointMake(4.63, 2.96)];
        [path_490Path addLineToPoint: CGPointMake(4.63, 11.03)];
        [path_490Path addLineToPoint: CGPointMake(0.63, 11.03)];
        [path_490Path addLineToPoint: CGPointMake(0.63, 11.03)];
        [path_490Path addCurveToPoint: CGPointMake(0, 11.66) controlPoint1: CGPointMake(0.28, 11.03) controlPoint2: CGPointMake(0, 11.31)];
        [path_490Path addLineToPoint: CGPointMake(0, 16.7)];
        [path_490Path addLineToPoint: CGPointMake(0, 16.7)];
        [path_490Path addCurveToPoint: CGPointMake(0.63, 17.33) controlPoint1: CGPointMake(0, 17.05) controlPoint2: CGPointMake(0.28, 17.33)];
        [path_490Path addLineToPoint: CGPointMake(4.63, 17.33)];
        [path_490Path addLineToPoint: CGPointMake(4.63, 30.06)];
        [path_490Path addLineToPoint: CGPointMake(4.63, 30.06)];
        [path_490Path addCurveToPoint: CGPointMake(5.25, 30.68) controlPoint1: CGPointMake(4.63, 30.4) controlPoint2: CGPointMake(4.91, 30.68)];
        [path_490Path addLineToPoint: CGPointMake(10.47, 30.68)];
        [path_490Path addLineToPoint: CGPointMake(10.47, 30.68)];
        [path_490Path addCurveToPoint: CGPointMake(11.1, 30.06) controlPoint1: CGPointMake(10.82, 30.68) controlPoint2: CGPointMake(11.1, 30.4)];
        [path_490Path addLineToPoint: CGPointMake(11.1, 17.33)];
        [path_490Path addLineToPoint: CGPointMake(15.77, 17.33)];
        [path_490Path addLineToPoint: CGPointMake(15.78, 17.33)];
        [path_490Path addCurveToPoint: CGPointMake(16.4, 16.7) controlPoint1: CGPointMake(16.12, 17.33) controlPoint2: CGPointMake(16.4, 17.05)];
        [path_490Path addLineToPoint: CGPointMake(16.4, 11.66)];
        [path_490Path addLineToPoint: CGPointMake(16.4, 11.66)];
        [path_490Path addCurveToPoint: CGPointMake(15.77, 11.03) controlPoint1: CGPointMake(16.4, 11.31) controlPoint2: CGPointMake(16.12, 11.03)];
        [path_490Path addLineToPoint: CGPointMake(11.1, 11.03)];
        [path_490Path addLineToPoint: CGPointMake(11.1, 8.08)];
        [path_490Path addCurveToPoint: CGPointMake(13.29, 5.94) controlPoint1: CGPointMake(11.1, 6.66) controlPoint2: CGPointMake(11.44, 5.94)];
        [path_490Path addLineToPoint: CGPointMake(15.97, 5.94)];
        [path_490Path addLineToPoint: CGPointMake(15.97, 5.94)];
        [path_490Path addCurveToPoint: CGPointMake(16.59, 5.32) controlPoint1: CGPointMake(16.31, 5.94) controlPoint2: CGPointMake(16.59, 5.66)];
        [path_490Path addLineToPoint: CGPointMake(16.59, 0.63)];
        [path_490Path addLineToPoint: CGPointMake(16.59, 0.63)];
        [path_490Path addCurveToPoint: CGPointMake(15.97, 0.01) controlPoint1: CGPointMake(16.59, 0.29) controlPoint2: CGPointMake(16.31, 0.01)];
        [path_490Path closePath];
        [FriendsStyleKit.fbBlue setFill];
        [path_490Path fill];
    }
    
    CGContextRestoreGState(context);

}

+ (void)drawContactsCanvas
{
    [FriendsStyleKit drawContactsCanvasWithFrame: CGRectMake(0, 0, 32, 26) resizing: FriendsStyleKitResizingBehaviorStretch];
}

+ (void)drawContactsCanvasWithFrame: (CGRect)targetFrame resizing: (FriendsStyleKitResizingBehavior)resizing
{
    //// General Declarations
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //// Resize to Target Frame
    CGContextSaveGState(context);
    CGRect resizedFrame = FriendsStyleKitResizingBehaviorApply(resizing, CGRectMake(0, 0, 32, 26), targetFrame);
    CGContextTranslateCTM(context, resizedFrame.origin.x, resizedFrame.origin.y);
    CGContextScaleCTM(context, resizedFrame.size.width / 32, resizedFrame.size.height / 26);


    //// Color Declarations
    UIColor* unWineRed = [UIColor colorWithRed: 0.502 green: 0.145 blue: 0.243 alpha: 1];

    //// Group_356
    {
        //// Path_492 Drawing
        UIBezierPath* path_492Path = [UIBezierPath bezierPath];
        [path_492Path moveToPoint: CGPointMake(15.58, 15.27)];
        [path_492Path addLineToPoint: CGPointMake(14.8, 15.27)];
        [path_492Path addLineToPoint: CGPointMake(14.8, 15.28)];
        [path_492Path addCurveToPoint: CGPointMake(14.07, 14.55) controlPoint1: CGPointMake(14.4, 15.28) controlPoint2: CGPointMake(14.07, 14.95)];
        [path_492Path addLineToPoint: CGPointMake(14.07, 14.54)];
        [path_492Path addCurveToPoint: CGPointMake(14.24, 14.14) controlPoint1: CGPointMake(14.07, 14.39) controlPoint2: CGPointMake(14.13, 14.25)];
        [path_492Path addLineToPoint: CGPointMake(14.21, 14.17)];
        [path_492Path addCurveToPoint: CGPointMake(15.33, 12.51) controlPoint1: CGPointMake(14.69, 13.7) controlPoint2: CGPointMake(15.07, 13.13)];
        [path_492Path addLineToPoint: CGPointMake(15.34, 12.48)];
        [path_492Path addCurveToPoint: CGPointMake(15.53, 12.55) controlPoint1: CGPointMake(15.39, 12.52) controlPoint2: CGPointMake(15.46, 12.55)];
        [path_492Path addCurveToPoint: CGPointMake(16.48, 10.93) controlPoint1: CGPointMake(15.96, 12.55) controlPoint2: CGPointMake(16.48, 11.59)];
        [path_492Path addCurveToPoint: CGPointMake(15.98, 9.74) controlPoint1: CGPointMake(16.48, 10.27) controlPoint2: CGPointMake(16.42, 9.74)];
        [path_492Path addLineToPoint: CGPointMake(15.98, 9.74)];
        [path_492Path addCurveToPoint: CGPointMake(15.82, 9.76) controlPoint1: CGPointMake(15.92, 9.74) controlPoint2: CGPointMake(15.87, 9.75)];
        [path_492Path addCurveToPoint: CGPointMake(12.62, 5.76) controlPoint1: CGPointMake(15.78, 7.98) controlPoint2: CGPointMake(15.33, 5.76)];
        [path_492Path addCurveToPoint: CGPointMake(9.42, 9.76) controlPoint1: CGPointMake(9.78, 5.76) controlPoint2: CGPointMake(9.45, 7.98)];
        [path_492Path addLineToPoint: CGPointMake(9.41, 9.76)];
        [path_492Path addCurveToPoint: CGPointMake(9.29, 9.74) controlPoint1: CGPointMake(9.37, 9.75) controlPoint2: CGPointMake(9.33, 9.74)];
        [path_492Path addCurveToPoint: CGPointMake(8.8, 10.93) controlPoint1: CGPointMake(8.86, 9.74) controlPoint2: CGPointMake(8.8, 10.28)];
        [path_492Path addCurveToPoint: CGPointMake(9.75, 12.55) controlPoint1: CGPointMake(8.8, 11.59) controlPoint2: CGPointMake(9.31, 12.55)];
        [path_492Path addLineToPoint: CGPointMake(9.75, 12.55)];
        [path_492Path addCurveToPoint: CGPointMake(9.9, 12.51) controlPoint1: CGPointMake(9.8, 12.55) controlPoint2: CGPointMake(9.85, 12.54)];
        [path_492Path addLineToPoint: CGPointMake(9.9, 12.51)];
        [path_492Path addCurveToPoint: CGPointMake(11.02, 14.17) controlPoint1: CGPointMake(10.16, 13.13) controlPoint2: CGPointMake(10.54, 13.7)];
        [path_492Path addLineToPoint: CGPointMake(11, 14.15)];
        [path_492Path addCurveToPoint: CGPointMake(11.17, 14.55) controlPoint1: CGPointMake(11.11, 14.25) controlPoint2: CGPointMake(11.17, 14.4)];
        [path_492Path addLineToPoint: CGPointMake(11.17, 14.55)];
        [path_492Path addCurveToPoint: CGPointMake(10.44, 15.28) controlPoint1: CGPointMake(11.17, 14.96) controlPoint2: CGPointMake(10.84, 15.28)];
        [path_492Path addLineToPoint: CGPointMake(9.66, 15.28)];
        [path_492Path addLineToPoint: CGPointMake(9.66, 15.28)];
        [path_492Path addCurveToPoint: CGPointMake(6.65, 18.29) controlPoint1: CGPointMake(7.99, 15.28) controlPoint2: CGPointMake(6.65, 16.63)];
        [path_492Path addLineToPoint: CGPointMake(6.65, 19.12)];
        [path_492Path addLineToPoint: CGPointMake(6.65, 19.12)];
        [path_492Path addCurveToPoint: CGPointMake(7.6, 20.07) controlPoint1: CGPointMake(6.65, 19.65) controlPoint2: CGPointMake(7.07, 20.07)];
        [path_492Path addLineToPoint: CGPointMake(17.64, 20.07)];
        [path_492Path addLineToPoint: CGPointMake(17.64, 20.08)];
        [path_492Path addCurveToPoint: CGPointMake(18.59, 19.13) controlPoint1: CGPointMake(18.16, 20.08) controlPoint2: CGPointMake(18.59, 19.65)];
        [path_492Path addLineToPoint: CGPointMake(18.59, 18.29)];
        [path_492Path addLineToPoint: CGPointMake(18.59, 18.28)];
        [path_492Path addCurveToPoint: CGPointMake(15.58, 15.27) controlPoint1: CGPointMake(18.59, 16.62) controlPoint2: CGPointMake(17.24, 15.27)];
        [path_492Path closePath];
        [unWineRed setFill];
        [path_492Path fill];


        //// Path_493 Drawing
        UIBezierPath* path_493Path = [UIBezierPath bezierPath];
        [path_493Path moveToPoint: CGPointMake(24.59, 7.02)];
        [path_493Path addLineToPoint: CGPointMake(16.17, 7.02)];
        [path_493Path addLineToPoint: CGPointMake(16.18, 7.05)];
        [path_493Path addCurveToPoint: CGPointMake(16.66, 9.03) controlPoint1: CGPointMake(16.45, 7.68) controlPoint2: CGPointMake(16.61, 8.35)];
        [path_493Path addLineToPoint: CGPointMake(16.65, 9.04)];
        [path_493Path addCurveToPoint: CGPointMake(17.08, 9.53) controlPoint1: CGPointMake(16.84, 9.16) controlPoint2: CGPointMake(16.98, 9.33)];
        [path_493Path addLineToPoint: CGPointMake(24.59, 9.54)];
        [path_493Path addLineToPoint: CGPointMake(24.59, 9.54)];
        [path_493Path addCurveToPoint: CGPointMake(25.29, 8.84) controlPoint1: CGPointMake(24.98, 9.54) controlPoint2: CGPointMake(25.29, 9.23)];
        [path_493Path addLineToPoint: CGPointMake(25.29, 7.72)];
        [path_493Path addLineToPoint: CGPointMake(25.29, 7.72)];
        [path_493Path addCurveToPoint: CGPointMake(24.59, 7.02) controlPoint1: CGPointMake(25.29, 7.33) controlPoint2: CGPointMake(24.98, 7.02)];
        [path_493Path closePath];
        [unWineRed setFill];
        [path_493Path fill];


        //// Path_494 Drawing
        UIBezierPath* path_494Path = [UIBezierPath bezierPath];
        [path_494Path moveToPoint: CGPointMake(24.59, 11.62)];
        [path_494Path addLineToPoint: CGPointMake(17.25, 11.62)];
        [path_494Path addLineToPoint: CGPointMake(17.25, 11.62)];
        [path_494Path addCurveToPoint: CGPointMake(15.89, 13.37) controlPoint1: CGPointMake(17.1, 12.39) controlPoint2: CGPointMake(16.6, 13.04)];
        [path_494Path addCurveToPoint: CGPointMake(15.82, 13.48) controlPoint1: CGPointMake(15.87, 13.41) controlPoint2: CGPointMake(15.84, 13.44)];
        [path_494Path addLineToPoint: CGPointMake(15.82, 14.15)];
        [path_494Path addLineToPoint: CGPointMake(24.59, 14.15)];
        [path_494Path addLineToPoint: CGPointMake(24.59, 14.15)];
        [path_494Path addCurveToPoint: CGPointMake(25.29, 13.45) controlPoint1: CGPointMake(24.97, 14.15) controlPoint2: CGPointMake(25.29, 13.83)];
        [path_494Path addLineToPoint: CGPointMake(25.29, 12.32)];
        [path_494Path addLineToPoint: CGPointMake(25.29, 12.32)];
        [path_494Path addCurveToPoint: CGPointMake(24.59, 11.62) controlPoint1: CGPointMake(25.29, 11.93) controlPoint2: CGPointMake(24.98, 11.62)];
        [path_494Path closePath];
        [unWineRed setFill];
        [path_494Path fill];


        //// Path_495 Drawing
        UIBezierPath* path_495Path = [UIBezierPath bezierPath];
        [path_495Path moveToPoint: CGPointMake(24.59, 16.22)];
        [path_495Path addLineToPoint: CGPointMake(18.86, 16.22)];
        [path_495Path addLineToPoint: CGPointMake(18.88, 16.25)];
        [path_495Path addCurveToPoint: CGPointMake(19.46, 18.28) controlPoint1: CGPointMake(19.26, 16.86) controlPoint2: CGPointMake(19.46, 17.56)];
        [path_495Path addLineToPoint: CGPointMake(19.46, 18.74)];
        [path_495Path addLineToPoint: CGPointMake(24.59, 18.74)];
        [path_495Path addLineToPoint: CGPointMake(24.59, 18.74)];
        [path_495Path addCurveToPoint: CGPointMake(25.29, 18.04) controlPoint1: CGPointMake(24.98, 18.74) controlPoint2: CGPointMake(25.29, 18.43)];
        [path_495Path addLineToPoint: CGPointMake(25.29, 16.93)];
        [path_495Path addLineToPoint: CGPointMake(25.29, 16.92)];
        [path_495Path addCurveToPoint: CGPointMake(24.59, 16.22) controlPoint1: CGPointMake(25.29, 16.54) controlPoint2: CGPointMake(24.98, 16.22)];
        [path_495Path closePath];
        [unWineRed setFill];
        [path_495Path fill];


        //// Path_496 Drawing
        UIBezierPath* path_496Path = [UIBezierPath bezierPath];
        [path_496Path moveToPoint: CGPointMake(27.61, -0)];
        [path_496Path addLineToPoint: CGPointMake(4.33, -0)];
        [path_496Path addLineToPoint: CGPointMake(4.32, -0)];
        [path_496Path addCurveToPoint: CGPointMake(-0, 4.32) controlPoint1: CGPointMake(1.94, -0) controlPoint2: CGPointMake(-0, 1.94)];
        [path_496Path addLineToPoint: CGPointMake(0, 21.5)];
        [path_496Path addLineToPoint: CGPointMake(-0, 21.5)];
        [path_496Path addCurveToPoint: CGPointMake(4.32, 25.83) controlPoint1: CGPointMake(-0, 23.89) controlPoint2: CGPointMake(1.94, 25.83)];
        [path_496Path addLineToPoint: CGPointMake(27.61, 25.83)];
        [path_496Path addLineToPoint: CGPointMake(27.62, 25.83)];
        [path_496Path addCurveToPoint: CGPointMake(31.94, 21.5) controlPoint1: CGPointMake(30, 25.83) controlPoint2: CGPointMake(31.94, 23.89)];
        [path_496Path addLineToPoint: CGPointMake(31.94, 4.32)];
        [path_496Path addLineToPoint: CGPointMake(31.94, 4.32)];
        [path_496Path addCurveToPoint: CGPointMake(27.61, -0) controlPoint1: CGPointMake(31.94, 1.94) controlPoint2: CGPointMake(30, -0)];
        [path_496Path closePath];
        [path_496Path moveToPoint: CGPointMake(29.9, 21.5)];
        [path_496Path addLineToPoint: CGPointMake(29.9, 21.5)];
        [path_496Path addCurveToPoint: CGPointMake(27.61, 23.78) controlPoint1: CGPointMake(29.9, 22.76) controlPoint2: CGPointMake(28.87, 23.78)];
        [path_496Path addLineToPoint: CGPointMake(4.33, 23.78)];
        [path_496Path addLineToPoint: CGPointMake(4.33, 23.78)];
        [path_496Path addCurveToPoint: CGPointMake(2.04, 21.5) controlPoint1: CGPointMake(3.07, 23.78) controlPoint2: CGPointMake(2.04, 22.76)];
        [path_496Path addLineToPoint: CGPointMake(2.04, 4.32)];
        [path_496Path addLineToPoint: CGPointMake(2.04, 4.33)];
        [path_496Path addCurveToPoint: CGPointMake(4.33, 2.04) controlPoint1: CGPointMake(2.04, 3.07) controlPoint2: CGPointMake(3.07, 2.04)];
        [path_496Path addLineToPoint: CGPointMake(27.61, 2.04)];
        [path_496Path addLineToPoint: CGPointMake(27.62, 2.04)];
        [path_496Path addCurveToPoint: CGPointMake(29.9, 4.33) controlPoint1: CGPointMake(28.88, 2.04) controlPoint2: CGPointMake(29.9, 3.07)];
        [path_496Path addLineToPoint: CGPointMake(29.9, 21.5)];
        [path_496Path addLineToPoint: CGPointMake(29.9, 21.5)];
        [path_496Path closePath];
        [unWineRed setFill];
        [path_496Path fill];
    }
    
    CGContextRestoreGState(context);

}

+ (void)drawEmailCanvas
{
    [FriendsStyleKit drawEmailCanvasWithFrame: CGRectMake(0, 0, 33, 24) resizing: FriendsStyleKitResizingBehaviorStretch];
}

+ (void)drawEmailCanvasWithFrame: (CGRect)targetFrame resizing: (FriendsStyleKitResizingBehavior)resizing
{
    //// General Declarations
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //// Resize to Target Frame
    CGContextSaveGState(context);
    CGRect resizedFrame = FriendsStyleKitResizingBehaviorApply(resizing, CGRectMake(0, 0, 33, 24), targetFrame);
    CGContextTranslateCTM(context, resizedFrame.origin.x, resizedFrame.origin.y);
    CGContextScaleCTM(context, resizedFrame.size.width / 33, resizedFrame.size.height / 24);


    //// Color Declarations
    UIColor* unWineRed = [UIColor colorWithRed: 0.502 green: 0.145 blue: 0.243 alpha: 1];

    //// Group_357
    {
        //// Path_498 Drawing
        UIBezierPath* path_498Path = [UIBezierPath bezierPath];
        [path_498Path moveToPoint: CGPointMake(16.19, 16.19)];
        [path_498Path addLineToPoint: CGPointMake(12.18, 12.68)];
        [path_498Path addLineToPoint: CGPointMake(0.73, 22.5)];
        [path_498Path addLineToPoint: CGPointMake(0.73, 22.5)];
        [path_498Path addCurveToPoint: CGPointMake(2.33, 23.12) controlPoint1: CGPointMake(1.16, 22.9) controlPoint2: CGPointMake(1.73, 23.12)];
        [path_498Path addLineToPoint: CGPointMake(30.05, 23.12)];
        [path_498Path addLineToPoint: CGPointMake(30.05, 23.12)];
        [path_498Path addCurveToPoint: CGPointMake(31.64, 22.5) controlPoint1: CGPointMake(30.64, 23.12) controlPoint2: CGPointMake(31.21, 22.9)];
        [path_498Path addLineToPoint: CGPointMake(20.19, 12.68)];
        [path_498Path addLineToPoint: CGPointMake(16.19, 16.19)];
        [path_498Path closePath];
        [unWineRed setFill];
        [path_498Path fill];


        //// Path_499 Drawing
        UIBezierPath* path_499Path = [UIBezierPath bezierPath];
        [path_499Path moveToPoint: CGPointMake(31.64, 0.63)];
        [path_499Path addLineToPoint: CGPointMake(31.64, 0.63)];
        [path_499Path addCurveToPoint: CGPointMake(30.06, -0) controlPoint1: CGPointMake(31.21, 0.22) controlPoint2: CGPointMake(30.64, -0)];
        [path_499Path addLineToPoint: CGPointMake(2.33, -0)];
        [path_499Path addLineToPoint: CGPointMake(2.33, -0)];
        [path_499Path addCurveToPoint: CGPointMake(0.74, 0.62) controlPoint1: CGPointMake(1.74, -0) controlPoint2: CGPointMake(1.17, 0.22)];
        [path_499Path addLineToPoint: CGPointMake(16.19, 13.88)];
        [path_499Path addLineToPoint: CGPointMake(31.64, 0.63)];
        [path_499Path closePath];
        [unWineRed setFill];
        [path_499Path fill];


        //// Path_500 Drawing
        UIBezierPath* path_500Path = [UIBezierPath bezierPath];
        [path_500Path moveToPoint: CGPointMake(-0, 2.03)];
        [path_500Path addLineToPoint: CGPointMake(-0, 21.24)];
        [path_500Path addLineToPoint: CGPointMake(11.18, 11.74)];
        [path_500Path addLineToPoint: CGPointMake(-0, 2.03)];
        [path_500Path closePath];
        [unWineRed setFill];
        [path_500Path fill];


        //// Path_501 Drawing
        UIBezierPath* path_501Path = [UIBezierPath bezierPath];
        [path_501Path moveToPoint: CGPointMake(21.2, 11.75)];
        [path_501Path addLineToPoint: CGPointMake(32.38, 21.25)];
        [path_501Path addLineToPoint: CGPointMake(32.38, 2.02)];
        [path_501Path addLineToPoint: CGPointMake(21.2, 11.75)];
        [path_501Path closePath];
        [unWineRed setFill];
        [path_501Path fill];
    }
    
    CGContextRestoreGState(context);

}

@end



CGRect FriendsStyleKitResizingBehaviorApply(FriendsStyleKitResizingBehavior behavior, CGRect rect, CGRect target)
{
    if (CGRectEqualToRect(rect, target) || CGRectEqualToRect(target, CGRectZero))
        return rect;

    CGSize scales = CGSizeZero;
    scales.width = ABS(target.size.width / rect.size.width);
    scales.height = ABS(target.size.height / rect.size.height);

    switch (behavior)
    {
        case FriendsStyleKitResizingBehaviorAspectFit:
        {
            scales.width = MIN(scales.width, scales.height);
            scales.height = scales.width;
            break;
        }
        case FriendsStyleKitResizingBehaviorAspectFill:
        {
            scales.width = MAX(scales.width, scales.height);
            scales.height = scales.width;
            break;
        }
        case FriendsStyleKitResizingBehaviorStretch:
            break;
        case FriendsStyleKitResizingBehaviorCenter:
        {
            scales.width = 1;
            scales.height = 1;
            break;
        }
    }

    CGRect result = CGRectStandardize(rect);
    result.size.width *= scales.width;
    result.size.height *= scales.height;
    result.origin.x = target.origin.x + (target.size.width - result.size.width) / 2;
    result.origin.y = target.origin.y + (target.size.height - result.size.height) / 2;
    return result;
}
