//
//  DocumentBrowserViewController.h
//  test
//
//  Created by machport on 4/15/20.
//  Copyright © 2020 machport. All rights reserved.
//

#import <UIKit/UIKit.h>
#include "RegexHighlightView.h"

@interface DocumentBrowserViewController : UIDocumentBrowserViewController

- (void)presentDocumentAtURL:(NSURL *)documentURL;

@end
