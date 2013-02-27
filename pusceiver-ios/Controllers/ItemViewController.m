#import "ItemViewController.h"

@interface ItemViewController ()

@property (nonatomic, retain) FDataSnapshot *snapshot;

@end

@implementation ItemViewController

- (id)initWithDataSnapshot:(FDataSnapshot *)snapshot
{
    self = [super init];
    if (self) {
        self.snapshot = snapshot;
    }
    return self;
}

- (void)loadView
{
    UITextView *textView = [UITextView new];
    textView.text = self.snapshot.val;
    textView.font = [UIFont systemFontOfSize:16];
    textView.editable = NO;
    self.view = textView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
