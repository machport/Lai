//
//  ViewController.h
//  OpenIDE
//
//  Created by machport on 4/15/20.
//  Copyright © 2020 machport. All rights reserved.
//

#import <UIKit/UIKit.h>
#include "RegexHighlightView.h"
@interface ViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate>
@property (strong, nonatomic) IBOutlet RegexHighlightView *highlightView;

@property (weak, nonatomic) IBOutlet UITextView *output;

@end

