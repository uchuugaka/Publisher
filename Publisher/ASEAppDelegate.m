#import "ASEAppDelegate.h"

#import <ServiceDiscovery/ServiceDiscovery.h>
#import <CocoaLumberjack/DDLog.h>
#import <CocoaLumberjack/DDTTYLogger.h>

@interface ASEAppDelegate ()

@property (nonatomic, strong) SDServiceDiscovery * serviceDiscovery;
@property BOOL isPublishing;

@property (weak) IBOutlet NSButton *publishToggleButton;
@property (weak) IBOutlet NSButton *pingPongButton;
@property (weak) IBOutlet NSTextField *typeField;
@property (weak) IBOutlet NSTextField *portField;
@property (weak) IBOutlet NSTextField *statusField;

@end

@implementation ASEAppDelegate
@synthesize statusField = _statusField;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [DDLog addLogger:[DDTTYLogger sharedInstance]];

    self.serviceDiscovery = [SDServiceDiscovery new];
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
        self.publishToggleButton.title = @"Publish";
        [self.portField setEnabled:YES];
        [self.typeField setEnabled:YES];
    } else {
        [self.typeField.window makeFirstResponder:nil];
        [self.portField.window makeFirstResponder:nil];
        [self.portField setEnabled:NO];
        [self.typeField setEnabled:NO];
        self.publishToggleButton.title = @"Stop Publishing";
    }
    [self togglePublishing];
}

-(void)togglePublishing
{
    if(self.isPublishing) {
        [self.serviceDiscovery stopPublishing];
        self.isPublishing = NO;
        [self.statusField setStringValue:@"Not published!"];
    } else {
        [self.serviceDiscovery publishServiceOfType:self.typeField.stringValue onPort:[self.portField.stringValue intValue]];
        self.isPublishing = YES;
        [self.statusField setStringValue:@"Published!"];
    }
}

- (IBAction)pingPong:(id)sender {
    [self.publishToggleButton setEnabled:NO];
    [self.pingPongButton setEnabled:NO];
    [self.portField setEnabled:NO];
    [self.typeField setEnabled:NO];
    
    __block int i = 0;
    __block dispatch_block_t block;
    block = ^{
        i++;
        [self togglePublishing];
        if(i < 10) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC), dispatch_get_main_queue(), block);
        } else {
            [self.publishToggleButton setEnabled:YES];
            [self.pingPongButton setEnabled:YES];
            [self.portField setEnabled:YES];
            [self.typeField setEnabled:YES];
        }
    };
    dispatch_async(dispatch_get_main_queue(), block);
}

@end
