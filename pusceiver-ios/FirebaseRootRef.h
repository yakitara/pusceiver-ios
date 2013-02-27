#import <Firebase/Firebase.h>

@interface FirebaseRootRef : Firebase

+ (FirebaseRootRef *)sharedRef;
- (void)setToken:(NSString *)token;
- (void)auth;

@end
