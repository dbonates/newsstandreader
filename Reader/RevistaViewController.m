//
//  RevistaViewController.m
//  
//
//  Created by Daniel Bonates on 5/22/13.
//
//

#import "RevistaViewController.h"

@interface RevistaViewController () <PSPDFViewControllerDelegate>

@end

@implementation RevistaViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.delegate = self;
    }
    return self;
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - PSPDFViewControllerDelegate

-(void)pdfViewController:(PSPDFViewController *)pdfController didSelectAnnotation:(PSPDFAnnotation *)annotation onPageView:(PSPDFPageView *)pageView
{
    
}

- (BOOL)pdfViewController:(PSPDFViewController *)pdfController didTapOnAnnotation:(PSPDFAnnotation *)annotation annotationPoint:(CGPoint)annotationPoint annotationView:(UIView<PSPDFAnnotationViewProtocol> *)annotationView pageView:(PSPDFPageView *)pageView viewPoint:(CGPoint)viewPoint
{
    NSLog(@"taped numa anotação: %@", [annotation userInfo]);
    return YES;
}


- (NSArray *)pdfViewController:(PSPDFViewController *)pdfController shouldShowMenuItems:(NSArray *)menuItems atSuggestedTargetRect:(CGRect)rect forSelectedText:(NSString *)selectedText inRect:(CGRect)textRect onPageView:(PSPDFPageView *)pageView {
    
    
    // disable wikipedia
    // be sure to check for PSPDFMenuItem class; there might also be classic UIMenuItems in the array.
    // Note that for words that are in the iOS dictionary, instead of Wikipedia we show the "Define" menu item with the native dict.
    NSMutableArray *newMenuItems = [menuItems mutableCopy];
    for (PSPDFMenuItem *menuItem in menuItems) {
        if ([menuItem isKindOfClass:[PSPDFMenuItem class]] && [menuItem.identifier isEqualToString:@"Create Link..."]) {
            [newMenuItems removeObjectIdenticalTo:menuItem];
            break;
        }
    }
    
    // add option to google for it.
    PSPDFMenuItem *googleItem = [[PSPDFMenuItem alloc] initWithTitle:NSLocalizedString(@"Google", nil) block:^{
        
        // trim removes stuff like \n or 's.
        NSString *trimmedSearchText = PSPDFTrimString(selectedText);
        NSString *URLString = [NSString stringWithFormat:@"http://www.google.com/search?q=%@", [trimmedSearchText stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        
        // create browser
        PSPDFWebViewController *browser = [[PSPDFWebViewController alloc] initWithURL:[NSURL URLWithString:URLString]];
        browser.delegate = pdfController;
        browser.contentSizeForViewInPopover = CGSizeMake(600, 500);
        
        [pdfController presentViewControllerModalOrPopover:browser embeddedInNavigationController:YES withCloseButton:YES animated:YES sender:nil options:@{PSPDFPresentOptionRect : BOXED(rect)}];
        
    } identifier:@"Google"];
    [newMenuItems addObject:googleItem];
    
    PSPDFMenuItem *twitterItem = [[PSPDFMenuItem alloc] initWithTitle:@"Twitter" image:[UIImage imageNamed:@"twitter-white"] block:^{
        NSString *tweetTrimmedSearchText = PSPDFTrimString(selectedText);
        NSLog(@"Twittar texto: \"%@\'", tweetTrimmedSearchText);
        
    } identifier:@"Twitter"];
    [newMenuItems addObject:twitterItem];
    
    
    PSPDFMenuItem *facebookItem = [[PSPDFMenuItem alloc] initWithTitle:@"Facebook" image:[UIImage imageNamed:@"facebook-white"] block:^{
        NSString *facebookTrimmedSearchText = PSPDFTrimString(selectedText);
        NSLog(@"postar no facebook o texto: \"%@\'", facebookTrimmedSearchText);
        
    } identifier:@"Facebook"];
    [newMenuItems addObject:facebookItem];
    
    return newMenuItems;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
