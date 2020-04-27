//
//  JavaScript.m
//  OpenIDE
//
//  Created by machport on 4/17/20.
//  Copyright © 2020 machport. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "JavaScript.h"
#include <JavaScriptCore/JavaScriptCore.h>
#include <UIKit/UIKit.h>

int exceptiontriggeredjava = 0;
extern UITextView *outputview;
NSString *EvalJavascript(NSString *s) {
    
    JSContext *context = [[JSContext alloc] init];
    [context evaluateScript:@"var console = {}"];

    context[@"console"][@"log"] = ^(NSString *message) {
        [outputview insertText:message];
         [outputview insertText:@"\n"];
    };
    context[@"alert"] = ^(NSString *title, NSString *message) {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:title
                                   message:message
                                   preferredStyle:UIAlertControllerStyleAlert];

        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                       handler:^(UIAlertAction * action) {}];

        [alert addAction:defaultAction];
        [[outputview _viewControllerForAncestor] presentViewController:alert animated:YES completion:nil];
    };
    JSValue *v = [context evaluateScript:s];
    __block NSString *e = @"no exception here lmao";
    context.exceptionHandler = ^(JSContext *context, JSValue *exception) {
        e = exception.toString;
        NSLog(@"%@", e);
        exceptiontriggeredjava = 1;
    };
    if ([e isEqualToString:@"no exception here lmao"]) {
        return v.toString;
    } else {
        return e;
    }
}
