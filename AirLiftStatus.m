#import "AirLiftStatus.h"
#import <UIKit/UIKit.h>

@interface AirLiftStatusViewController : UIViewController
@end

@implementation AirLiftStatusViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"AirLift";
    self.view.backgroundColor = UIColor.systemBackgroundColor;

    UILabel *title = [[UILabel alloc] init];
    title.text = @"AirLift Status";
    title.font = [UIFont boldSystemFontOfSize:25];
    title.translatesAutoresizingMaskIntoConstraints = NO;

    UILabel *status = [[UILabel alloc] init];
    status.text =
        @"Interface: Ready\n\n"
        @"AirLift FFI: Not integrated\n\n"
        @"Pairing: Not verified\n\n"
        @"Sandbox access: Not tested\n\n"
        @"This panel does not execute the AirLift exploit.";
    status.font = [UIFont systemFontOfSize:16];
    status.numberOfLines = 0;
    status.translatesAutoresizingMaskIntoConstraints = NO;

    [self.view addSubview:title];
    [self.view addSubview:status];

    [NSLayoutConstraint activateConstraints:@[
        [title.topAnchor constraintEqualToAnchor:
            self.view.safeAreaLayoutGuide.topAnchor constant:28],
        [title.leadingAnchor constraintEqualToAnchor:
            self.view.leadingAnchor constant:22],

        [status.topAnchor constraintEqualToAnchor:
            title.bottomAnchor constant:22],
        [status.leadingAnchor constraintEqualToAnchor:
            self.view.leadingAnchor constant:22],
        [status.trailingAnchor constraintEqualToAnchor:
            self.view.trailingAnchor constant:-22]
    ]];

    self.navigationItem.rightBarButtonItem =
        [[UIBarButtonItem alloc]
            initWithBarButtonSystemItem:UIBarButtonSystemItemDone
            target:self
            action:@selector(closePanel)];
}

- (void)closePanel {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end

static UIViewController *ALFindTopController(void) {
    for (UIWindow *window in UIApplication.sharedApplication.windows) {
        if (!window.isKeyWindow) continue;

        UIViewController *vc = window.rootViewController;

        while (vc) {
            UIViewController *next = vc.presentedViewController;

            if (!next && [vc isKindOfClass:UINavigationController.class])
                next = ((UINavigationController *)vc).visibleViewController;

            if (!next && [vc isKindOfClass:UITabBarController.class])
                next = ((UITabBarController *)vc).selectedViewController;

            if (!next) break;
            vc = next;
        }

        return vc;
    }

    return nil;
}

static void ALInstallAttempt(int remaining) {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIViewController *vc = ALFindTopController();

        if (!vc) {
            if (remaining > 0) {
                dispatch_after(
                    dispatch_time(DISPATCH_TIME_NOW,
                        1 * NSEC_PER_SEC),
                    dispatch_get_main_queue(), ^{
                        ALInstallAttempt(remaining - 1);
                    });
            }
            return;
        }

        UIBarButtonItem *existing = vc.navigationItem.rightBarButtonItem;

        if ([existing.title isEqualToString:@"AirLift"])
            return;

        UIBarButtonItem *button =
            [[UIBarButtonItem alloc]
                initWithTitle:@"AirLift"
                style:UIBarButtonItemStylePlain
                target:nil
                action:nil];

        button.target = vc;
        button.action = @selector(al_openAirLiftStatus);

        vc.navigationItem.rightBarButtonItem = button;
    });
}

@interface UIViewController (AirLiftStatus)
- (void)al_openAirLiftStatus;
@end

@implementation UIViewController (AirLiftStatus)

- (void)al_openAirLiftStatus {
    AirLiftStatusViewController *panel =
        [[AirLiftStatusViewController alloc] init];

    UINavigationController *navigation =
        [[UINavigationController alloc] initWithRootViewController:panel];

    navigation.modalPresentationStyle = UIModalPresentationPageSheet;

    [self presentViewController:navigation
                       animated:YES
                     completion:nil];
}

@end

void AirLiftStatusInstall(void) {
    ALInstallAttempt(15);
}
