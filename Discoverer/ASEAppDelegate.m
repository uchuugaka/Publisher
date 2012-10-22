#import "ASEAppDelegate.h"

#import <ServiceDiscovery/ServiceDiscovery.h>
#import <CocoaLumberjack/DDLog.h>
#import <CocoaLumberjack/DDTTYLogger.h>

@interface ASEAppDelegate ()

@property (nonatomic, strong) SDServiceDiscovery * serviceDiscovery;

@end

@implementation ASEAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [DDLog addLogger:[DDTTYLogger sharedInstance]];

    self.serviceDiscovery = [SDServiceDiscovery new];
    [self.serviceDiscovery searchForServicesOfType:@"_intairact._tcp"];
    [self.serviceDiscovery publishServiceOfType:@"_intairact._tcp" onPort:80];
}

-(void)applicationWillTerminate:(NSNotification *)notification
{
    [self.serviceDiscovery stop];
}

-(BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
    return YES;
}

@end
