//
//  OptionsViewController.h
//  Teste
//
//  Created by Daniel Bonates on 5/4/13.
//  Copyright (c) 2013 Daniel Bonates. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OptionsViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIScrollView *scroller;
- (IBAction)changeBk:(id)sender;
- (IBAction)restaurarCompras:(id)sender;
@end
