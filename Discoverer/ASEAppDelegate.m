#import "ASEAppDelegate.h"

#import <ServiceDiscovery/ServiceDiscovery.h>
#import <CocoaLumberjack/DDLog.h>
#import <CocoaLumberjack/DDTTYLogger.h>

@interface ASEAppDelegate ()

@property (nonatomic, strong) SDServiceDiscovery * serviceDiscovery;
@property BOOL isSearching;
@property BOOL isPublishing;

@property (weak) IBOutlet NSButton *searchToggleButton;
@property (weak) IBOutlet NSButton *publishToggleButton;
@property (weak) IBOutlet NSButton *pingPongButton;

@end

@implementation ASEAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [DDLog addLogger:[DDTTYLogger sharedInstance]];

    self.serviceDiscovery = [SDServiceDiscovery new];
    [self.serviceDiscovery searchForServicesOfType:@"_intairact._tcp"];
    [self.serviceDiscovery publishServiceOfType:@"_intairact._tcp" onPort:80];
    self.isSearching = YES;
    self.isPublishing = YES;
}

-(void)applicationWillTerminate:(NSNotification *)notification
{
    [self.serviceDiscovery stop];
    self.isSearching = NO;
    self.isPublishing = NO;
}

-(BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
    return YES;
}

- (IBAction)toggleSearch:(id)sender
{
    if(self.isSearching) {
        [self.serviceDiscovery stopSearching];
        self.isSearching = NO;
        self.searchToggleButton.title = @"Start Search";
    } else {
        [self.serviceDiscovery searchForServicesOfType:@"_intairact._tcp"];
        self.isSearching = YES;
        self.searchToggleButton.title = @"Stop Search";
    }    
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
    [self.searchToggleButton setEnabled:NO];
    [self.publishToggleButton setEnabled:NO];
    [self.pingPongButton setEnabled:NO];
    
    __block int i = 0;
    __block dispatch_block_t block;
    block = ^{
        if(i < 10) {
            [self togglePublishing:nil];
            i++;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC), dispatch_get_main_queue(), block);
        } else {
            [self.searchToggleButton setEnabled:YES];
            [self.publishToggleButton setEnabled:YES];
            [self.pingPongButton setEnabled:YES];
        }
    };
    dispatch_async(dispatch_get_main_queue(), block);
}

@end
