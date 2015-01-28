//
//  AppDelegate.h
//  vimeo_test
//
//  Created by Xiaohe Hu on 1/26/15.
//  Copyright (c) 2015 Neoscape. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Reachability.h"
@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    BOOL internetActive;
}
@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, retain) Reachability* internetReachable;
@property (nonatomic, retain) Reachability* hostReachable;
@property (nonatomic, retain) NSString *isWirelessAvailable;

+ (AppDelegate *)appDelegate;

@end

