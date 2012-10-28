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

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    [[DDTTYLogger sharedInstance] setColorsEnabled:YES];

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
    
    int64_t delayInSeconds = 3.0;
    int max = 10;
    for (int i = 0; i < max; i++) {
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, i * delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self togglePublishing];
        });
    }
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, max * delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self togglePublishing];
        [self.publishToggleButton setEnabled:YES];
        [self.pingPongButton setEnabled:YES];
        [self.portField setEnabled:YES];
        [self.typeField setEnabled:YES];
    });
}

@end
