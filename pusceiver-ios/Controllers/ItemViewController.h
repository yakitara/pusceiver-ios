#import <UIKit/UIKit.h>
#import <Firebase/Firebase.h>

@interface ItemViewController : UIViewController

- (id)initWithDataSnapshot:(FDataSnapshot *)snapshot;

@end
