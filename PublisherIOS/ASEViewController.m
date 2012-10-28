#import "ASEViewController.h"

#import <ServiceDiscovery/ServiceDiscovery.h>

@interface ASEViewController ()

@property (nonatomic, strong) SDServiceDiscovery * serviceDiscovery;
@property BOOL isPublishing;

@property (weak, nonatomic) IBOutlet UITextField *typeField;
@property (weak, nonatomic) IBOutlet UITextField *portField;
@property (weak, nonatomic) IBOutlet UILabel *statusField;
@property (weak, nonatomic) IBOutlet UIButton *publishToggleButton;
@property (weak, nonatomic) IBOutlet UIButton *pingPongButton;

@end

@implementation ASEViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reset) name:UIApplicationWillResignActiveNotification object:nil];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)reset
{
    [self.statusField setText:@"Not published!"];
    [self.publishToggleButton setTitle:@"Publish" forState:UIControlStateNormal];
    [self.publishToggleButton setEnabled:YES];
    [self.pingPongButton setEnabled:YES];
    [self.portField setEnabled:YES];
    [self.typeField setEnabled:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    if (_serviceDiscovery) {
        _serviceDiscovery = nil;
    }
}

- (IBAction)togglePublish:(id)sender {
    if(self.isPublishing) {
        [self.portField setEnabled:YES];
        [self.typeField setEnabled:YES];
    } else {
        [self.portField setEnabled:NO];
        [self.typeField setEnabled:NO];
    }
    [self togglePublishing];
}

-(void)togglePublishing
{
    if(self.isPublishing) {
        [self.serviceDiscovery stopPublishing];
        self.isPublishing = NO;
        [self.statusField setText:@"Not published!"];
        [self.publishToggleButton setTitle:@"Publish" forState:UIControlStateNormal];
    } else {
        [self.serviceDiscovery publishServiceOfType:self.typeField.text onPort:[self.portField.text intValue]];
        self.isPublishing = YES;
        [self.statusField setText:@"Published!"];
        [self.publishToggleButton setTitle:@"Stop Publishing" forState:UIControlStateNormal];
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

-(SDServiceDiscovery *)serviceDiscovery
{
    if (!_serviceDiscovery) {
        _serviceDiscovery = [SDServiceDiscovery new];
    }
    return _serviceDiscovery;
}

@end
