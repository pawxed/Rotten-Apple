#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>



static NSArray *daemonsToDisable = @[
    // no need to change this file (if you want for some reason) as it does absolutely nothing as far as i know lol, the real work is under the permission and the file management as those are responsible for just saving the existing disabled.plist files and managinng permission


    // you only need to disable the daemon with icleaner pro then itll make the disabled.plist permanent, i tried testing it with geranium but the tweak wouldnt cooperate and geranium keep bypassing what the tweak does

    @"com.exampledaemon",
];

static void disableDaemons(void) {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    
   
    if (![fileManager fileExistsAtPath:@"/var/jb"]) {
        NSLog(@"stage 0.1, not jailbroken but thats not possible anyway");
        return;
    }
    
    NSLog(@"stage 0.2");
    
    
    NSString *disabledPlistPath = @"/private/var/db/com.apple.xpc.launchd/disabled.501.plist";
    
    
    NSString *plistDir = [disabledPlistPath stringByDeletingLastPathComponent];
    if (![fileManager fileExistsAtPath:plistDir]) {
        [fileManager createDirectoryAtPath:plistDir 
               withIntermediateDirectories:YES 
                                attributes:nil 
                                     error:&error];
        if (error) {
            NSLog(@"error: %@", error);
            error = nil;
        }
    }
    
    
    NSMutableDictionary *disabledDict = nil;
    if ([fileManager fileExistsAtPath:disabledPlistPath]) {
        disabledDict = [NSMutableDictionary dictionaryWithContentsOfFile:disabledPlistPath];
    }
    
    if (!disabledDict) {
        disabledDict = [NSMutableDictionary dictionary];
    }
    
    
    NSUInteger addedCount = 0;
    for (NSString *daemon in daemonsToDisable) {
        if (!disabledDict[daemon]) {
            disabledDict[daemon] = @(1);
            addedCount++;
            NSLog(@"adding disabled daemon (wouldnt work but the chmod will do the job): %@", daemon);
        }
    }
    
    
    BOOL success = [disabledDict writeToFile:disabledPlistPath atomically:YES];
    if (success) {
        NSLog(@"congrats, it works%lu", (unsigned long)addedCount);
    } else {
        NSLog(@"error %@", disabledPlistPath);
    }
    
    
    NSDictionary *attrs = @{NSFilePosixPermissions: @(0644)};
    [fileManager setAttributes:attrs ofItemAtPath:disabledPlistPath error:&error];
    if (error) {
        NSLog(@"error: %@", error);
    }
}

%hook SpringBoard

- (void)applicationDidFinishLaunching:(UIApplication *)application {
    %orig;
    
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        disableDaemons();
    });
}

%end

