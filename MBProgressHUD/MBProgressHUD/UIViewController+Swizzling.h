//
//  UIViewController+Swizzling.h
//  NIM
//
//  Created by chris on 15/6/15.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MBProgressHUD.h>
@interface UIViewController (Swizzling)
@property (nonatomic, assign) BOOL isForceLandscape;

- (MBProgressHUD *)showLoadingWithInfo:(NSString *)info;

- (void)showNormalInfo:(NSString *)info;
- (void)showInWindowWithNormalInfo:(NSString *)info;

- (void)showError:(NSString *)error;
- (void)showError:(NSString *)error withComplication:(MBProgressHUDCompletionBlock)completionBlock;

- (void)showInWindowWithError:(NSString *)error;
- (void)showInWindowWithError:(NSString *)error withComplication:(MBProgressHUDCompletionBlock)completionBlock;

- (void)showSuccess:(NSString *)success;
- (void)showSuccess:(NSString *)success withComplication:(MBProgressHUDCompletionBlock)completionBlock;

- (void)showInWindowWithSuccess:(NSString *)success;
- (void)showInWindowWithSuccess:(NSString *)success withComplication:(MBProgressHUDCompletionBlock)completionBlock;

- (void)hideHUD;
@end
