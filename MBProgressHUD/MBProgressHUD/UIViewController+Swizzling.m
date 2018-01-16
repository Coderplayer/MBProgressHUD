//
//  UIViewController+Swizzling.m
//  NIM
//
//  Created by chris on 15/6/15.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import "UIViewController+Swizzling.h"
#import "SwizzlingDefine.h"
static NSString *kIsViewControllerForceLandscape = @"IsViewControllerForceLandscape";
static NSString *kBaseViewControllerMBPHUD = @"BaseViewControllerMBPHUD";
static CGFloat const kHUDAnimatedDuring = 3;

@interface UIViewController ()
@property (nonatomic, assign) MBProgressHUD *hud;
@end
@implementation UIViewController (Swizzling)

+ (void)load{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        swizzling_exchangeMethod([UIViewController class], @selector(shouldAutorotate), @selector(swizzling_shouldAutorotate));
        swizzling_exchangeMethod([UIViewController class], @selector(supportedInterfaceOrientations), @selector(swizzling_supportedInterfaceOrientations));
    });
}

#pragma mark - add new property
- (void)setIsForceLandscape:(BOOL)isForceLandscape {
    objc_setAssociatedObject(self, &kIsViewControllerForceLandscape, @(isForceLandscape), OBJC_ASSOCIATION_ASSIGN);
}
- (MBProgressHUD *)hud {
    return  objc_getAssociatedObject(self, &kBaseViewControllerMBPHUD);
}

- (BOOL)isForceLandscape {
    NSNumber *value = objc_getAssociatedObject(self, &kIsViewControllerForceLandscape);
    return [value boolValue];
}

- (void)setHud:(MBProgressHUD *)hud {
    objc_setAssociatedObject(self, &kBaseViewControllerMBPHUD, hud, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - method exchange
- (BOOL)swizzling_shouldAutorotate {
    return YES;//self.isForceLandscape ? YES : NO;
}
- (UIInterfaceOrientationMask)swizzling_supportedInterfaceOrientations {
    return self.isForceLandscape ? UIInterfaceOrientationMaskLandscape : UIInterfaceOrientationMaskPortrait; //
}

#pragma mark - HUD method
- (MBProgressHUD *)showLoadingWithInfo:(NSString *)info {
    MBProgressHUD *hud = [self showHUDAddedTo:self.view InfoWith:info withImage:nil];
    hud.mode = MBProgressHUDModeIndeterminate;
    self.hud = hud;
    return hud;
}

- (void)showNormalInfo:(NSString *)info {
    [self showAndAutoHideHUDAddedTo:self.view withInfo:info withImage:nil withComplication:nil];
}

- (void)showInWindowWithNormalInfo:(NSString *)info {
    [self showAndAutoHideHUDAddedTo:nil withInfo:info withImage:nil withComplication:nil];
}

- (void)showSuccess:(NSString *)success {
    [self showSuccess:success withComplication:nil];
}

- (void)showSuccess:(NSString *)success withComplication:(MBProgressHUDCompletionBlock)completionBlock {
    [self showAndAutoHideHUDAddedTo:self.view withInfo:success withImage:@"success" withComplication:completionBlock];
}

- (void)showInWindowWithSuccess:(NSString *)success {
    [self showInWindowWithError:success withComplication:nil];
}

- (void)showInWindowWithSuccess:(NSString *)success withComplication:(MBProgressHUDCompletionBlock)completionBlock {
    [self showAndAutoHideHUDAddedTo:nil withInfo:success withImage:@"success" withComplication:completionBlock];
}

- (void)showError:(NSString *)error {
    [self showInWindowWithError:error withComplication:nil];
}

-(void)showError:(NSString *)error withComplication:(MBProgressHUDCompletionBlock)completionBlock {
    [self showAndAutoHideHUDAddedTo:self.view withInfo:error withImage:@"error" withComplication:completionBlock];
}

- (void)showInWindowWithError:(NSString *)error {
    [self showInWindowWithError:error withComplication:nil];
}

- (void)showInWindowWithError:(NSString *)error withComplication:(MBProgressHUDCompletionBlock)completionBlock {
    [self showAndAutoHideHUDAddedTo:nil withInfo:error withImage:@"error" withComplication:completionBlock];
}

- (void)showAndAutoHideHUDAddedTo:(UIView *)view
                      withInfo:(NSString *)info
                     withImage:(NSString *)imageName
              withComplication:(MBProgressHUDCompletionBlock)completionBlock
{
    MBProgressHUD *hud = [self showHUDAddedTo:view InfoWith:info withImage:imageName];
    if (completionBlock) {
        hud.completionBlock = [completionBlock copy];
    }
    [hud hideAnimated:YES afterDelay:kHUDAnimatedDuring];
}

- (MBProgressHUD *)showHUDAddedTo:(UIView *)view
                      InfoWith:(NSString *)info
                     withImage:(NSString *)imageName
{
    if (view == nil) {
        view = [[UIApplication sharedApplication].windows lastObject];
    }
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.removeFromSuperViewOnHide = YES;
    hud.contentColor = [UIColor whiteColor];
    
    hud.label.font = [UIFont systemFontOfSize:5];
    hud.label.text = @"  ";
    hud.detailsLabel.text = info;
    hud.detailsLabel.font = [UIFont systemFontOfSize:15];
    hud.detailsLabel.preferredMaxLayoutWidth = 92.0f;
    // 去除毛玻璃效果相当于隐藏UIVisualEffectView    
    hud.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
    hud.bezelView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
    hud.margin = 15.0;
    //hud.detailsLabel.text = @"lalalalalalala";
    //整个大遮盖颜色
    //hud.backgroundView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    if (imageName) {
        hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"MBProgressHUD.bundle/%@",imageName]]];
        hud.mode = MBProgressHUDModeCustomView;
    }else {
       hud.mode = MBProgressHUDModeText;
    }
    return hud;
}

- (void)hideHUD {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.hud) {
            [self.hud hideAnimated:YES];
        }
    });
}

#pragma mark - ViewWillAppear
- (void)swizzling_viewDidLoad{
    if (self.navigationController) {
        UIImage *buttonNormal = [[UIImage imageNamed:@"icon_back_normal.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        [self.navigationController.navigationBar setBackIndicatorImage:buttonNormal];
        [self.navigationController.navigationBar setBackIndicatorTransitionMaskImage:buttonNormal];
        UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
        self.navigationItem.backBarButtonItem = backItem;
    }
    [self swizzling_viewDidLoad];
}

static char UIFirstResponderViewAddress;

#pragma mark - ViewDidAppear
- (void)swizzling_viewDidAppear:(BOOL)animated{
    [self swizzling_viewDidAppear:animated];
    UIView *view = objc_getAssociatedObject(self, &UIFirstResponderViewAddress);
    [view becomeFirstResponder];
}
@end
