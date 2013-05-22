//
//  RevistaViewController.m
//  
//
//  Created by Daniel Bonates on 5/22/13.
//
//

#import "RevistaViewController.h"
#import <Accounts/Accounts.h>
#import <Social/Social.h>
#import "Issue.h"
#import "Asset.h"
#import "UIImage+UIImage_DBImageBlender.h"

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

//-(void)pdfViewController:(PSPDFViewController *)pdfController didSelectAnnotation:(PSPDFAnnotation *)annotation onPageView:(PSPDFPageView *)pageView
//{
//    PSPDFTextParser *parser = pageView.textParser;
//    
//    //NSArray *rects = annotation;
//    
//    //NSDictionary *dic = [pageView objectsAtRect:(CGRect)[rects objectAtIndex:0] options:nil];
//    
//                      
//                       
//    
////    [parser textWithGlyphs:nil    ];
//    NSLog(@"taped numa anotação: %@", annotation);
//    
//}


- (NSArray *)pdfViewController:(PSPDFViewController *)pdfController shouldShowMenuItems:(NSArray *)menuItems atSuggestedTargetRect:(CGRect)rect forAnnotation:(PSPDFAnnotation *)annotation inRect:(CGRect)textRect onPageView:(PSPDFPageView *)pageView {
    
    //NSLog(@"showing menu %@ for %@", menuItems, annotation);
    NSMutableArray *newMenuItems = [menuItems mutableCopy];
    for (PSPDFMenuItem *menuItem in menuItems) {
        //iLOG(@"%@",menuItem.identifier);
        if ([menuItem isKindOfClass:[PSPDFMenuItem class]] &&
            ([menuItem.identifier isEqualToString:@"Line"] ||
             [menuItem.identifier isEqualToString:@"Color..."] ||
             [menuItem.identifier isEqualToString:@"Type..."] ||
             [menuItem.identifier isEqualToString:@"Opacity..."])
            ) {
            [newMenuItems removeObjectIdenticalTo:menuItem];
            
        }
    }

    PSPDFMenuItem *twitterItem = [[PSPDFMenuItem alloc] initWithTitle:@"Twitter" image:[UIImage imageNamed:@"twitter-white"] block:^{
        if ([annotation isKindOfClass:PSPDFHighlightAnnotation.class]) {
            NSString *highlightedString = [(PSPDFHighlightAnnotation *)annotation highlightedString];
            [self shareText:highlightedString onSocialNet:@"twitter"];
        }
        
        
    } identifier:@"Twitter"];
    [newMenuItems addObject:twitterItem];
    
    
    PSPDFMenuItem *facebookItem = [[PSPDFMenuItem alloc] initWithTitle:@"Facebook" image:[UIImage imageNamed:@"facebook-white"] block:^{
        if ([annotation isKindOfClass:PSPDFHighlightAnnotation.class]) {
            NSString *highlightedString = [(PSPDFHighlightAnnotation *)annotation highlightedString];
            [self shareText:highlightedString onSocialNet:@"facebook"];
        }
        
    } identifier:@"Facebook"];
    [newMenuItems addObject:facebookItem];
    
    // Print highlight contents
    //if ([annotation isKindOfClass:PSPDFHighlightAnnotation.class]) {
    //    NSString *highlightedString = [(PSPDFHighlightAnnotation *)annotation highlightedString];
    //   NSLog(@"Highlighted value: %@", highlightedString);
    //}
    
    return newMenuItems;
}


- (void)shareText:(NSString *)text onSocialNet:(NSString *)socialNet
{
    // limite para incluir link: 116 caracteres
    //NSString *panoramaLink = @"http://goo.gl/0E7b5";
    NSString *panoramaLink = @"http://panoramadaaquicultura.com.br";
    NSString *textToshare;
    
    iLOG(@"compartilhando texto [%d]: %@", textToshare.length,textToshare);
    
    ACAccountStore *accountsStore = [[ACAccountStore alloc] init];
    
    if ([socialNet isEqualToString:@"twitter"]) {
        NSRange stringRange = {0, MIN([text length], 140-panoramaLink.length)};
        stringRange = [text rangeOfComposedCharacterSequencesForRange:stringRange];
        textToshare = [text substringWithRange:stringRange];

        
        ACAccountType *twitterAccountType = [accountsStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
        
        [accountsStore requestAccessToAccountsWithType:twitterAccountType
                                                   options:nil
                                                completion:^(BOOL granted, NSError *error) {
                                                    if (granted) {
                                                        //iLog(@"Acesseo liberado!");
                                                        //ACAccount *account = [[accountsStore accountsWithAccountType:twitterAccountType] lastObject];
                                                    } else {
                                                        //NSLog(@"Permissão negada :(  %@", error);
                                                    }
                                                }];
        
        
        SLComposeViewController *tweetSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        
        [tweetSheet setInitialText:textToshare];
        [tweetSheet addURL:[NSURL URLWithString:panoramaLink]];
        [self presentViewController:tweetSheet
                           animated:YES
                         completion:nil];
    }
    
    else if ([socialNet isEqualToString:@"facebook"])
    {
        ACAccountType *facebookAccountType = [accountsStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
        id options = @{
                       ACFacebookAppIdKey: @"459554034135122",
                       ACFacebookPermissionsKey: @[ @"email", @"read_friendlists"],
                       ACFacebookAudienceKey: ACFacebookAudienceFriends
                       };
        
        [accountsStore requestAccessToAccountsWithType:facebookAccountType
                                                   options:options
                                                completion:^(BOOL granted, NSError *error) {
                                                    if (granted) {
                                                        NSLog(@"Acesseo liberado!");
                                                    
                                                    } else {
                                                        NSLog(@"Permissão negada :( %@", error);
                                                    }
                                                }];
        
        SLComposeViewController *facebookSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        
        [facebookSheet setInitialText:text];
        
        [facebookSheet addURL:[NSURL URLWithString:panoramaLink]];
        Asset *coverImageAsset = _issue.coverImage[0];
        
        NSString *coverImagePath = coverImageAsset.filePath;
        UIImage *coverImage = [[UIImage alloc] initWithContentsOfFile:coverImagePath];
        UIImage *beatifullOne = [UIImage
                                 blendOverlay:coverImage
                                 withBaseImage:[UIImage imageNamed:@"magazine_mockup_base"]
                                 highlightImage:[UIImage imageNamed:@"magazine_mockup_reflexo"]
                                 highlightMode:kCGBlendModeLighten
                                 usehighlight:YES
                                 currentCoverXoffset:75
                                 currentCoverYoffset:2
                                 currentHighlightXoffset:75
                                 currentHighlightYoffset:2
                                 overlayCoverSize:CGSizeMake(300, 400)
                                 overlayHighlightSize:CGSizeMake(300, 400)
                                 ];
        UIImage *smallerOne = [UIImage smallerVersion:beatifullOne finalSize:CGSizeMake(150, 140)];
        
       [facebookSheet addImage:smallerOne];
        
        
        [self presentViewController:facebookSheet
                           animated:YES
                         completion:^{
                             iLOG(@"Postagem efetuada!");
                         }];
        
    }
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
        [self shareText:tweetTrimmedSearchText onSocialNet:@"twitter"];
        
    } identifier:@"Twitter"];
    [newMenuItems addObject:twitterItem];
    
    
    PSPDFMenuItem *facebookItem = [[PSPDFMenuItem alloc] initWithTitle:@"Facebook" image:[UIImage imageNamed:@"facebook-white"] block:^{
        NSString *facebookTrimmedSearchText = PSPDFTrimString(selectedText);
        [self shareText:facebookTrimmedSearchText onSocialNet:@"facebook"];
        
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
