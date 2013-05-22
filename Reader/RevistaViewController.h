//
//  RevistaViewController.h
//  
//
//  Created by Daniel Bonates on 5/22/13.
//
//

#import <PSPDFKit/PSPDFKit.h>
@class Issue;
@interface RevistaViewController : PSPDFViewController
@property (nonatomic, strong) Issue *issue;
@end
