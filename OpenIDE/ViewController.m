//
//  ViewController.m
//  OpenIDE
//
//  Created by machport on 4/15/20.
//  Copyright © 2020 machport. All rights reserved.
//

#import "ViewController.h"
#include "luacore.h"
#include "JavaScript.h"
@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextView *linputtextfield;
@property (weak, nonatomic) IBOutlet UIButton *saveb;
@property (weak, nonatomic) IBOutlet UIButton *openb;
@property (weak, nonatomic) IBOutlet UIButton *runb;

@end

@implementation ViewController
lua_State *L;
UITextView *outputview;
UITextView *linputview;
@synthesize highlightView;
NSArray *langs;

int java = 1;
- (void)donebuttonpressed {
    [self.linputtextfield resignFirstResponder];

}
NSString* selectedlang;
- (IBAction)execute:(id)sender {
    NSString *le = [_linputtextfield text];
    le = [le stringByReplacingOccurrencesOfString:@"”" withString:@"\""];
    le = [le stringByReplacingOccurrencesOfString:@"“" withString:@"\""];
    [highlightView setText:le];
    [outputview setText:@""];
    if ([selectedlang isEqualToString:@"Lua"]){
    if (    luaL_dostring(L,[le UTF8String]) != LUA_OK) {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"LuaError"
                                   message:[NSString stringWithUTF8String:lua_tostring(L,-1)]
                                   preferredStyle:UIAlertControllerStyleAlert];

        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                       handler:^(UIAlertAction * action) {}];

        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
    } else {
        NSString *e = EvalJavascript(highlightView.text);
        extern int exceptiontriggeredjava;
        if (exceptiontriggeredjava) {
            UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"JavaScriptError"
                                       message:e
                                       preferredStyle:UIAlertControllerStyleAlert];

            UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                           handler:^(UIAlertAction * action) {}];

            [alert addAction:defaultAction];
            [self presentViewController:alert animated:YES completion:nil];
        } else {
            [outputview insertText:@"\n"];
            [outputview insertText:[NSString stringWithFormat:@"Script Returned: %@",e]];
        }
    }
}
- (void)presentActivityController:(UIActivityViewController *)controller {

    // for iPad: make the presentation a Popover
    controller.modalPresentationStyle = UIModalPresentationPopover;
    [self presentViewController:controller animated:YES completion:nil];

    UIPopoverPresentationController *popController = [controller popoverPresentationController];
    popController.permittedArrowDirections = UIPopoverArrowDirectionAny;
    popController.barButtonItem = self.navigationItem.leftBarButtonItem;

    // access the completion handler
    controller.completionWithItemsHandler = ^(NSString *activityType,
                                              BOOL completed,
                                              NSArray *returnedItems,
                                              NSError *error){
        // react to the completion
        if (completed) {
            // user shared an item
            NSLog(@"We used activity type%@", activityType);
        } else {
            // user cancelled
            NSLog(@"We didn't want to share anything after all.");
        }

        if (error) {
            NSLog(@"An Error occured: %@, %@", error.localizedDescription, error.localizedFailureReason);
        }
    };
}
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return langs[row];
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return langs.count;
}
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    selectedlang = langs[row];
}
- (IBAction)save:(id)sender {
    //create a message
    NSString *theMessage = highlightView.text;
    NSArray *items = @[theMessage];

    // build an activity view controller
    UIActivityViewController *controller = [[UIActivityViewController alloc]initWithActivityItems:items applicationActivities:nil];
    controller.popoverPresentationController.sourceView =_saveb;
    // and present it
    
    [self presentActivityController:controller];
}
int uptodate = 0;
- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSError *error;
    NSString *urlString = [NSString stringWithFormat:@"http://machport.net/laiversion"];
    NSURL *urlAdress = [NSURL URLWithString:urlString];
    NSString *urlContent = [[NSString alloc] initWithContentsOfURL:urlAdress encoding:NSUTF8StringEncoding error:&error];
    /* i tested updates but really wouldnt work out with this :\
    if ([urlContent isEqualToString:version]) {
        NSLog(@"Up to date");
        uptodate = 1;
    } else {
        NSLog(@"Please Update Lai");
    }
     */
    langs = @[@"Lua",@"JavaScript"];
    selectedlang = @"Lua";
    highlightView.textColor = [UIColor clearColor];
    // Set the syntax highlighting to use (the tempalate file contains the default highlighting)
    [highlightView setHighlightDefinitionWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"lua" ofType:@"plist"]];
    // Set the color theme to use (all XCode themes are fully supported!)
    // Do any additional setup after loading the view.
[highlightView setTintColor:[UIColor clearColor]];
    if([highlightView isFirstResponder]){
        [highlightView resignFirstResponder];
        [highlightView becomeFirstResponder];
    }
    outputview = _output;
    linputview = highlightView;
    L = luaL_newstate();
    luaL_openlibs(L);
    highlightView.layer.cornerRadius = 15;
    highlightView.layer.masksToBounds = true;
    outputview.layer.cornerRadius = 15;
    outputview.layer.masksToBounds = true;
     UIToolbar* keyboardToolbar = [[UIToolbar alloc] init];
     [keyboardToolbar sizeToFit];
     UIBarButtonItem *flexBarButton = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                       target:nil action:nil];
     UIBarButtonItem *doneBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Hide Keyboard" style:UIBarButtonItemStyleDone target:self action:@selector(donebuttonpressed)];

     keyboardToolbar.items = @[flexBarButton, doneBarButton];
     self.linputtextfield.inputAccessoryView = keyboardToolbar;
    if (@available(iOS 12.0, *)) {

    if( self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark ){
       //is dark
        [outputview setBackgroundColor:[UIColor colorWithRed:32.0/255.0 green:32.0/255.0 blue:32.0/255.0 alpha:1]];
        [highlightView setHighlightTheme:kRegexHighlightViewThemeMidnight];

#define blackcolor          [UIColor colorWithRed:32.0f/255.0f green:32.0f/255.0f blue:32.0f/255.0f alpha:1]
#define lightcolor [UIColor lightGrayColor]
        [highlightView setBackgroundColor:[UIColor colorWithRed:32.0/255.0 green:32.0/255.0 blue:32.0/255.0 alpha:1]];
        _runb.layer.cornerRadius = 15;
        _runb.backgroundColor =  blackcolor;
        _openb.layer.cornerRadius = 15;
        _openb.backgroundColor =  blackcolor;
        _saveb.layer.cornerRadius = 15;
        _saveb.backgroundColor = blackcolor;

    }else{
        //is light
        
        [highlightView setHighlightTheme:kRegexHighlightViewThemeBasic];

        [highlightView setBackgroundColor:[UIColor lightGrayColor]];
        [outputview setBackgroundColor:[UIColor lightGrayColor]];
        _runb.layer.cornerRadius = 15;
        _runb.backgroundColor =  lightcolor;
        _openb.layer.cornerRadius = 15;
        _openb.backgroundColor =  lightcolor;
        _saveb.layer.cornerRadius = 15;
        _saveb.backgroundColor = lightcolor;
    }
    }
    NSLog(@"Done Loading");
}
-(void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    if (@available(iOS 12.0, *)) {

        if( self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark ){
           //is dark
            [outputview setBackgroundColor:[UIColor colorWithRed:32.0/255.0 green:32.0/255.0 blue:32.0/255.0 alpha:1]];
            [highlightView setHighlightTheme:kRegexHighlightViewThemeMidnight];

    #define blackcolor          [UIColor colorWithRed:32.0f/255.0f green:32.0f/255.0f blue:32.0f/255.0f alpha:1]
    #define lightcolor [UIColor lightGrayColor]
            [highlightView setBackgroundColor:[UIColor colorWithRed:32.0/255.0 green:32.0/255.0 blue:32.0/255.0 alpha:1]];
            _runb.layer.cornerRadius = 15;
            _runb.backgroundColor =  blackcolor;
            _openb.layer.cornerRadius = 15;
            _openb.backgroundColor =  blackcolor;
            _saveb.layer.cornerRadius = 15;
            _saveb.backgroundColor = blackcolor;

        }else{
            //is light
            
            [highlightView setHighlightTheme:kRegexHighlightViewThemeBasic];

            [highlightView setBackgroundColor:[UIColor lightGrayColor]];
            [outputview setBackgroundColor:[UIColor lightGrayColor]];
            _runb.layer.cornerRadius = 15;
            _runb.backgroundColor =  lightcolor;
            _openb.layer.cornerRadius = 15;
            _openb.backgroundColor =  lightcolor;
            _saveb.layer.cornerRadius = 15;
            _saveb.backgroundColor = lightcolor;
        }
        }
}
-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (uptodate == 0) {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Out Of Date"
                                   message:@"Please Update Lai"
                                   preferredStyle:UIAlertControllerStyleAlert];

        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                       handler:^(UIAlertAction * action) {}];

        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
}
@end
