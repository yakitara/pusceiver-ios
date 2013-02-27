#import "FirebaseRootRef.h"

@interface FirebaseRootRef ()

- (void)authWithToken:(NSString *)token;
- (void)login;

@end

@implementation FirebaseRootRef

+ (FirebaseRootRef *)sharedRef
{
    static FirebaseRootRef *ref;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ref = [[FirebaseRootRef alloc] initWithUrl:[[NSUserDefaults standardUserDefaults] objectForKey:@"FirebaseRootURL"]];
    });
    return ref;
}

- (void)setToken:(NSString *)token
{
    [[NSUserDefaults standardUserDefaults] setObject:token forKey:@"AuthToken"];
    [self authWithToken:token];
}

- (void)auth
{
    NSString *token = [[NSUserDefaults standardUserDefaults] objectForKey:@"AuthToken"];
    if (token) {
        [self authWithToken:token];
    } else {
        [self login];
    }
    
}

- (void)login
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[[NSUserDefaults standardUserDefaults] objectForKey:@"LoginURL"]]];
}

- (void)authWithToken:(NSString *)token
{
    [self authWithCredential:token onComplete:^(NSError *error, id data) {
        // data example = {auth: {id: 14338979, provider: 'twitter'}, expires: 1361670326}
        NSLog(@"firebase auth complete: error=%@, data=%@", error, data);
        if (error) {
            [self login];
        }
    } onCancel:^(NSError *error) {
        NSLog(@"firebase auth canceled: %@", error);
    }];
};

@end
