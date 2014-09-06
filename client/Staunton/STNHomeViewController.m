#import "STNHomeViewController.h"
#import "STNChessBoardViewController.h"
#import "STNDiff.h"
#import "FCTWebSocket.h"

/// EXERCISE 0: FORMALITIES
///
/// Please Build and Run on the iPad Air simulator.
/// Let us know in chat or in person if you have any
/// problems. The chat URL is:
///
///  http://www.hipchat.com/gBH2nxWKC

@interface STNHomeViewController ()

@property (strong, nonatomic) STNChessBoardViewController *boardController;
@property (strong, nonatomic) UILabel *label;
@property (strong, nonatomic) FCTWebSocket *socket;
@property (strong, nonatomic) RACSubject *JSONSubject;

@end

@implementation STNHomeViewController

- (void)viewDidLoad {
    [self prepareSocket];
    [self prepareStateMachine];
}

- (void)prepareSocket {
    self.label = [[UILabel alloc] init];
    self.label.font = [UIFont fontWithName:@"Futura" size:18];

    self.JSONSubject = [RACSubject subject];
    self.socket = [[FCTWebSocket alloc] initWithJSONSignal:self.JSONSubject];

    /// EXERCISE ONE: HELLO, REACTIVE COCOA
    ///
    /// As self.socket.openedSignal sends you @YESes and @NOs, please
    /// reactively update self.label.text. This will give you a fun and,
    /// more importantly, useful indicator of the server status.
    ///
    /// Solution: git stash; git co 1

    RAC(self, label.text) = [[self.socket.openedSignal map:^id(NSNumber *n) {
        return n.boolValue ? @"+ WebSocket: connected ∰." : @"+ WebSocket: disconnected ☁.";
    }] startWith:@"+ WebSocket: initializing..."];
}

- (void)prepareStateMachine {
    @weakify(self);
    /// EXERCISE TWO: ACTION & REACTION
    ///
    /// Opening a socket is all and good, but we'd like to now register
    /// ourselves with the server. And to do that we need to send a
    /// little bit of JSON with our email address (which will only be
    /// used to find a Gravatar).
    NSDictionary *registration = @{@"email": @"me@haolian.org"};

    /// We want to execute the next bit of code:
    ///
    ///   [self.JSONSubject sendNext:registration];
    ///
    /// However, we only want to do it when the socket is opened. We
    /// have self.socket.openedSignal. How do we make sure our code
    /// runs only when the signal sends a @YES?
    ///
    /// Solution: git stash; git co 2
    [[[self.socket.openedSignal ignore:@NO] take:1] subscribeNext:^(id x) {
        @strongify(self);
        [self.JSONSubject sendNext:registration];

        RACSignal *onDisconnect = [[self.socket.openedSignal ignore:@YES] take:1];
        [[self.socket.messageSignal takeUntil:onDisconnect] subscribeNext:^(NSDictionary *json) {
            if (json[@"ping"]) {
                [self.JSONSubject sendNext:@{@"pong": @YES}];
            }
        }];

        [onDisconnect subscribeNext:^(id x) {
            [self prepareStateMachine];
        }];
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    RACSignal *diffSignal = [self fakeDiffSignal];
    self.boardController = [[STNChessBoardViewController alloc] initWithDiffSignal:diffSignal];
    
    CGFloat side = MIN(self.view.frameSizeHeight, self.view.frameSizeWidth);
    self.boardController.view.frame = CGRectMake(0, 0, side, side);
    self.boardController.view.center = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds));
    self.boardController.view.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin;
    [self.view addSubview:self.boardController.view];
    [self.boardController didMoveToParentViewController:self];

    CGFloat bottom = self.boardController.view.frameOriginY + self.boardController.view.frameSizeHeight;
    self.label.frame = CGRectMake(0, bottom, side, side);
    [self.view addSubview:self.label];
    self.label.frameSizeHeight = [self.label sizeThatFits:CGSizeMake(side, CGFLOAT_MAX)].height;

    [self.socket start];
}

- (RACSignal *)fakeDiffSignal {
    NSString *hao = @"me@haolian.org";
    NSString *ian = @"ianthehenry@gmail.com";
    
    return [[[@[[[STNDiffInsert alloc] initWithEmail:hao point:CGPointMake(0.5, 0.25)],
                [[STNDiffInsert alloc] initWithEmail:ian point:CGPointMake(0.5, 0.75)]]
              rac_sequence] signalWithScheduler:[RACScheduler mainThreadScheduler]]
            concat: [[RACSignal interval:2 onScheduler:[RACScheduler mainThreadScheduler]] map:^(id x) {
        NSString *email = arc4random_uniform(2) ? hao : ian;
        CGPoint point = CGPointMake(randfloat(), randfloat());
        return [[STNDiffUpdate alloc] initWithEmail:email point:point];
    }]];
}

@end
