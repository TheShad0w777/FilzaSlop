
#import "AirLiftStatus.h"
#import <UIKit/UIKit.h>

@interface UIViewController (AirLiftStatus)
- (void)al_openAirLiftStatus;
@end

@interface AirLiftStatusViewController : UIViewController
@end

@implementation AirLiftStatusViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"AirLift";
    self.view.backgroundColor = UIColor.systemBackgroundColor;

    UILabel *heading = [[UILabel alloc] init];
    heading.text = @"AirLift Status";
    heading.font = [UIFont boldSystemFontOfSize:25];
    heading.translatesAutoresizingMaskIntoConstraints = NO;

    UILabel *status = [[UILabel alloc] init];
    status.text =
        @"Interface: Connected\n\n"
        @"AirLift FFI: Not integrated\n\n"
        @"Pairing: Not verified\n\n"
        @"Sandbox access: Not tested\n\n"
        @"This panel is informational only; it does not execute AirLift.";
    status.font = [UIFont systemFontOfSize:16];
    status.numberOfLines = 0;
    status.translatesAutoresizingMaskIntoConstraints = NO;

    [self.view addSubview:heading];
    [self.view addSubview:status];

    [NSLayoutConstraint activateConstraints:@[
        [heading.topAnchor constraintEqualToAnchor:
            self.view.safeAreaLayoutGuide.topAnchor constant:28],
        [heading.leadingAnchor constraintEqualToAnchor:
            self.view.leadingAnchor constant:22],
        [status.topAnchor constraintEqualToAnchor:
            heading.bottomAnchor constant:22],
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

@implementation UIViewController (AirLiftStatus)

- (void)al_openAirLiftStatus {
    if (self.presentedViewController) return;

    AirLiftStatusViewController *panel =
        [[AirLiftStatusViewController alloc] init];

    UINavigationController *navigation =
        [[UINavigationController alloc] initWithRootViewController:panel];

    navigation.modalPresentationStyle = UIModalPresentationPageSheet;
    [self presentViewController:navigation animated:YES completion:nil];
}

@end

void AirLiftStatusInstall(void) {
    NSLog(@"[AirLiftStatus] waiting for Filza browser");
}

void AirLiftStatusConfigureBrowser(UIViewController *controller) {
    if (![NSThread isMainThread]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            AirLiftStatusConfigureBrowser(controller);
        });
        return;
    }

    if (!controller || !controller.isViewLoaded) return;

    UINavigationItem *item = controller.navigationItem;

    NSMutableArray<UIBarButtonItem *> *items =
        [item.rightBarButtonItems mutableCopy];

    if (!items) {
        items = [NSMutableArray array];
        if (item.rightBarButtonItem)
            [items addObject:item.rightBarButtonItem];
    }

    for (UIBarButtonItem *existing in items) {
        if ([existing.accessibilityIdentifier
                isEqualToString:@"AirLiftStatusButton"] ||
            [existing.title isEqualToString:@"AirLift"]) {
            return;
        }
    }

    UIBarButtonItem *button =
        [[UIBarButtonItem alloc] initWithTitle:@"AirLift"
                                         style:UIBarButtonItemStylePlain
                                        target:controller
                                        action:@selector(al_openAirLiftStatus)];

    button.accessibilityIdentifier = @"AirLiftStatusButton";

    [items addObject:button];
    item.rightBarButtonItems = items;

    NSLog(@"[AirLiftStatus] attached to %@",
          NSStringFromClass(controller.class));
}
