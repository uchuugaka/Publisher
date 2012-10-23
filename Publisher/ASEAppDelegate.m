#import "ASEAppDelegate.h"

#import <ServiceDiscovery/ServiceDiscovery.h>
#import <CocoaLumberjack/DDLog.h>
#import <CocoaLumberjack/DDTTYLogger.h>

@interface ASEAppDelegate ()

@property (nonatomic, strong) SDServiceDiscovery * serviceDiscovery;
@property BOOL isPublishing;

@property (weak) IBOutlet NSButton *publishToggleButton;
@property (weak) IBOutlet NSButton *pingPongButton;

@end

@implementation ASEAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [DDLog addLogger:[DDTTYLogger sharedInstance]];

    self.serviceDiscovery = [SDServiceDiscovery new];
    [self.serviceDiscovery publishServiceOfType:@"_intairact._tcp" onPort:80];
    self.isPublishing = YES;
}

-(void)applicationWillTerminate:(NSNotification *)notification
{
    [self.serviceDiscovery stop];
    self.isPublishing = NO;
}

-(BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
    return YES;
}

- (IBAction)togglePublishing:(id)sender
{
    if(self.isPublishing) {
        [self.serviceDiscovery stopPublishing];
        self.isPublishing = NO;
        self.publishToggleButton.title = @"Start Publishing";
    } else {
        [self.serviceDiscovery publishServiceOfType:@"_intairact._tcp" onPort:80];
        self.isPublishing = YES;
        self.publishToggleButton.title = @"Stop Publishing";
    }
}

- (IBAction)pingPong:(id)sender {
    [self.publishToggleButton setEnabled:NO];
    [self.pingPongButton setEnabled:NO];
    
    __block int i = 0;
    __block dispatch_block_t block;
    block = ^{
        i++;
        [self togglePublishing:nil];
        if(i < 10) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC), dispatch_get_main_queue(), block);
        } else {
            [self.publishToggleButton setEnabled:YES];
            [self.pingPongButton setEnabled:YES];
        }
    };
    dispatch_async(dispatch_get_main_queue(), block);
}

@end
