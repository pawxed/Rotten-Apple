#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

static NSArray *daemonsToDisable = @[

    // no need to change this file (if you want for some reason) as it does absolutely nothing as far as i know lol, the real work is under the permission and the file management as those are responsible for just saving the existing disabled.plist files and managinng permission
    // you only need to disable the daemon with icleaner pro then itll make the disabled.plist permanent, i tried testing it with geranium but the tweak wouldnt cooperate and geranium keep bypassing what the tweak does
    @"com.exampledaemon",
];

static void disableDaemons(void) {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *disabledPlistPath = @"/private/var/db/com.apple.xpc.launchd/disabled.501.plist";
    
    NSMutableDictionary *disabledDict = [NSMutableDictionary dictionaryWithContentsOfFile:disabledPlistPath] ?: [NSMutableDictionary dictionary];
    
    for (NSString *daemon in daemonsToDisable) {
        disabledDict[daemon] = @YES;
    }
    
    if ([disabledDict writeToFile:disabledPlistPath atomically:YES]) {
        NSDictionary *attrs = @{
            NSFilePosixPermissions: @(0644),
            NSFileOwnerAccountID: @(0),
            NSFileGroupOwnerAccountID: @(0)
        };
        [fileManager setAttributes:attrs ofItemAtPath:disabledPlistPath error:nil];
    }
}

%hook SpringBoard
- (void)applicationDidFinishLaunching:(UIApplication *)application {
    %orig;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        disableDaemons();
    });
