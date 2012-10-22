#import "ASEAppDelegate.h"

#import <ServiceDiscovery/ServiceDiscovery.h>
#import <CocoaLumberjack/DDLog.h>
#import <CocoaLumberjack/DDTTYLogger.h>

@interface ASEAppDelegate ()

@property (nonatomic, strong) SDServiceDiscovery * serviceDiscovery;
@property (weak) IBOutlet NSButton *startStopButton;
@property BOOL isRunning;

@end

@implementation ASEAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [DDLog addLogger:[DDTTYLogger sharedInstance]];

    self.serviceDiscovery = [SDServiceDiscovery new];
    [self.serviceDiscovery searchForServicesOfType:@"_intairact._tcp"];
    [self.serviceDiscovery publishServiceOfType:@"_intairact._tcp" onPort:80];
    self.isRunning = YES;
}

-(void)applicationWillTerminate:(NSNotification *)notification
{
    [self.serviceDiscovery stop];
    self.isRunning = NO;
}

-(BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
    return YES;
}

- (IBAction)startStop:(id)sender {
    if(self.isRunning) {
        [self.serviceDiscovery stop];
        self.isRunning = NO;
        self.startStopButton.title = @"Start";
    } else {
        [self.serviceDiscovery searchForServicesOfType:@"_intairact._tcp"];
        [self.serviceDiscovery publishServiceOfType:@"_intairact._tcp" onPort:80];
        self.isRunning = YES;
        self.startStopButton.title = @"Stop";
    }
}

@end
