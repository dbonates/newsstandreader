//
//  PSPDFPageView.h
//  PSPDFKit
//
//  Copyright 2011-2013 Peter Steinberger. All rights reserved.
//

#import "PSPDFKitGlobal.h"
#import "PSPDFRenderQueue.h"
#import "PSPDFResizableView.h"
#import "PSPDFHUDView.h"
#import "PSPDFLongPressGestureRecognizer.h"
#import "PSPDFSignatureViewController.h"
#import "PSPDFStampViewController.h"
#import "PSPDFNoteAnnotationController.h"
#import "PSPDFFontSelectorViewController.h"
#import "PSPDFFontStyleViewController.h"
#import "PSPDFAnnotation.h"
#import "PSPDFCache.h"

@protocol PSPDFAnnotationViewProtocol;
@class PSPDFLinkAnnotation, PSPDFPageInfo, PSPDFScrollView, PSPDFDocument, PSPDFViewController, PSPDFTextParser, PSPDFTextSelectionView, PSPDFAnnotation, PSPDFRenderStatusView, PSPDFNoteAnnotation, PSPDFOrderedDictionary, PSPDFMenuItem, PSPDFFreeTextAnnotation;

@interface PSPDFAnnotationContainerView : PSPDFHUDView @end

/// Send this event to hide any selections, menus or other interactive page elements.
extern NSString *const kPSPDFHidePageHUDElements;

/// Compound view for a single pdf page. Will be re-used during lifetime.
/// You can add your own views on top of the UIView (e.g. custom annotations)
/// Events from a attached UIScrollView will be relayed to all visible PSPDFPageView classes.
@interface PSPDFPageView : UIView <UIScrollViewDelegate, PSPDFRenderDelegate, PSPDFCacheDelegate, PSPDFResizableViewDelegate, PSPDFLongPressGestureRecognizerDelegate, PSPDFSignatureViewControllerDelegate, PSPDFSignatureSelectorViewControllerDelegate, PSPDFStampViewControllerDelegate, UIImagePickerControllerDelegate, PSPDFColorSelectionViewControllerDelegate, PSPDFNoteAnnotationControllerDelegate, PSPDFFontSelectorViewControllerDelegate, PSPDFFontStyleViewControllerDelegate, UITextFieldDelegate>

/// Designated initializer.
/// 'overrideClassNames' can be nil to simply use the stock classes.
- (id)initWithFrame:(CGRect)frame overrideClassNames:(NSDictionary *)overrideClassNames;


/// @name Show / Destroy a document

/// configure page container with data.
- (void)displayDocument:(PSPDFDocument *)document page:(NSUInteger)page pageRect:(CGRect)pageRect scale:(CGFloat)scale delayPageAnnotations:(BOOL)delayPageAnnotations pdfController:(PSPDFViewController *)pdfController;

/// Prepares the PSPDFPageView for reuse. Removes all unknown internal UIViews.
- (void)prepareForReuse;


/// @name Internal views and rendering

/// Redraw the renderView (dynamically rendered PDF for maximum sharpness, updated on every zoom level)
- (void)updateRenderView;

/// Redraw renderView and contentView.
- (void)updateView;

/// If annotations are already loaded, and the annotation is a view, access it here.
/// (Most PDF annotations are actually rendered into the page; except annotations that return YES for isOverlay, like links or notes.
- (UIView<PSPDFAnnotationViewProtocol> *)cachedAnnotationViewForAnnotation:(PSPDFAnnotation *)annotation;

/// UIImageView displaying the whole document. Readonly.
@property (nonatomic, strong, readonly) UIImageView *contentView;

/// UIImageView for the zoomed in state. Readonly.
@property (nonatomic, strong, readonly) UIImageView *renderView;

/**
 Container view for all overlay annotations.

 This is just a named subclass of UIView that will always track the frame of the PSPDFPageView.
 It's useful to coordinate this with your own subviews to get the zIndex right.

 @warning Most annotations will not be rendered as overlays or only when they are currently being selected.
 Rendering annotations within the pageView has several advantages including performance or view color multiplication (in case of highlight annotations)
 Do not manually add/remove views into the container view. Contents is managed. Views should respond to the <PSPDFAnnotationViewProtocol> protocol, especially the annotation method.
 */
@property (nonatomic, strong, readonly) PSPDFAnnotationContainerView *annotationContainerView;

/// Size used for the zoomed-in part. Should always be bigger than the screen.
/// This is set to a good default already. You shouldn't need to touch this.
@property (nonatomic, assign) CGSize renderSize;

/// Calculated scale. Readonly.
@property (nonatomic, assign, readonly) CGFloat PDFScale;

/// Is view currently rendering (either contentView or renderView)
@property (nonatomic, assign, getter=isRendering, readonly) BOOL rendering;

/// Current CGRect of the part of the page that's visible. Screen coordinate space.
/// @note If the scroll view is currently decelerating, this will show the TARGET rect, not the one that's currently animating.
@property (nonatomic, assign, readonly) CGRect visibleRect;

/// Access the selectionView. (handles text selection)
@property (nonatomic, strong, readonly) PSPDFTextSelectionView *selectionView;

/// Access the render status view that is displayed on top of a page while we are rendering.
@property (nonatomic, strong) PSPDFRenderStatusView *renderStatusView;

/// Top right offset. Defaults to 30.
@property (nonatomic, assign) CGFloat renderStatusViewOffset;

/// Should center render status view. Defaults to NO.
@property (nonatomic, assign) BOOL centerRenderStatusView;

/// Shortcut to access the textParser corresponding to the current page.
@property (nonatomic, strong, readonly) PSPDFTextParser *textParser;


/// @name Coordinate calculations and object fetching

/// Convert a view point to the corresponding PDF point.
/// pageBounds usually is PSPDFPageView bounds.
- (CGPoint)convertViewPointToPDFPoint:(CGPoint)viewPoint;

/// Convert a PDF point to the corresponding view point.
/// pageBounds usually is PSPDFPageView bounds.
- (CGPoint)convertPDFPointToViewPoint:(CGPoint)pdfPoint;

/// Convert a view rect to the corresponding pdf rect.
- (CGRect)convertViewRectToPDFRect:(CGRect)viewRect;

/// Convert a PDF rect to the corresponding view rect
- (CGRect)convertPDFRectToViewRect:(CGRect)pdfRect;

/// Convert a PDF glyph rect to the corresponding view rect.
/// (Glyphs are not rotated on parsing to preserve reading direction, thus need to be converted differently than e.g. annotations)
- (CGRect)convertGlyphRectToViewRect:(CGRect)glyphRect;

/// Convert a view rect to PDF glyph rect.
/// This is equivalent to [self convertPDFRectToViewRect:CGRectApplyAffineTransform(glyphRect, pageInfo.pageRotationTransform)]
- (CGRect)convertViewRectToGlyphRect:(CGRect)viewRect;

/// Get the glyphs/words on a specific page.
- (NSDictionary *)objectsAtPoint:(CGPoint)viewPoint options:(NSDictionary *)options;

/// Get the glyphs/words on a specific rect.
/// Usage e.g. NSDictionary *objects = [pageView objectsAtRect:rect options:@{kPSPDFObjectsFullWords : @YES}];
- (NSDictionary *)objectsAtRect:(CGRect)viewRect options:(NSDictionary *)options;

/// @name Accessors

/// Access parent PSPDFScrollView if available. (zoom controller)
/// @note this only lets you access the scrollView if it's in the view hierarchy.
/// If we use pageCurl mode, we have a global scrollView which can be accessed with pdfController.pagingScrollView
- (PSPDFScrollView *)scrollView;

/// Returns an array of UIView <PSPDFAnnotationViewProtocol> objects currently in the view hierarchy.
- (NSArray *)visibleAnnotationViews;

/// Access the attached pdfController.
@property (atomic, weak, readonly) PSPDFViewController *pdfController;

/// Page that is displayed. Readonly.
@property (atomic, assign, readonly) NSUInteger page;

/// Document that is displayed. Readonly.
@property (atomic, strong, readonly) PSPDFDocument *document;

/// Shortcut to access the current boxRect of the set page.
@property (nonatomic, strong, readonly) PSPDFPageInfo *pageInfo;

/// Return YES if the pdfPage is displayed in a double page mode setup on the right side.
@property (nonatomic, assign, readonly, getter=isRightPage) BOOL rightPage;


/// @name Shadow settings

/// Enables shadow for a single page. Only useful in combination with pageCurl.
@property (nonatomic, assign, getter=isShadowEnabled) BOOL shadowEnabled;

/// Set default shadowOpacity. Defaults to 0.7.
@property (nonatomic, assign) float shadowOpacity;

/// Subclass to change shadow behavior.
- (void)updateShadowAnimated:(BOOL)animated;

/// Set block that is executed within updateShadow when isShadowEnabled = YES.
@property (nonatomic, copy) void(^updateShadowBlock)(PSPDFPageView *pageView);

@end


// Extensions to handle annotations.
@interface PSPDFPageView (AnnotationViews)

// Associate an annotation with an annotation view
- (void)setAnnotation:(PSPDFAnnotation *)annotation forAnnotationView:(UIView <PSPDFAnnotationViewProtocol> *)annotationView;

// Recall the annotation associated with an annotation view
- (PSPDFAnnotation *)getAnnotationForAnnotationView:(UIView <PSPDFAnnotationViewProtocol> *)annotationView;

/// Currently selected annotation (selected by a tap; showing a menu)
@property (nonatomic, strong) PSPDFAnnotation *selectedAnnotation;

/**
 Hit-testing for a single PSPDFPage. This is usually a relayed event from the parent PSPDFScrollView.
 Returns YES if the tap has been handled, else NO.

 All annotations for the current page are loaded and hit-tested (except PSPDFAnnotationTypeLink; which has already been handled by now)

 If an annotation has been hit (via [annotation hitTest:tapPoint]; convert the tapPoint in PDF coordinate space via convertViewPointToPDFPoint) then we call showMenuForAnnotation.

 If the tap didn't hit an annotation but we are showing a UIMenuController menu; we hide that and set the touch as processed.
 */
- (BOOL)singleTapped:(UITapGestureRecognizer *)recognizer;

/// Handle long press, potentially relay to subviews.
- (BOOL)longPress:(UILongPressGestureRecognizer *)recognizer;

/**
 In PSPDFKit, annotations are managed in two ways:

 1) Annotations that are fixed and rendered with the page image.
 Those annotations are PSPDFHighlightAnnotation, PSPDFShapeAnnotation, PSPDFInkAnnotation and more.
 Pretty much all more or less "static" annotations are handled this way.

 2) Then, there are the more dynamic annotations like PSPDFLinkAnnotation and PSPDFNoteAnnotation.
 Those annotations are not part of the rendered image but are actual subviews in PSPDFPageView.
 Those annotations return YES on the isOverlay property.

 Especially with PSPDFLinkAnnotation, the resulting views are - depending on the subtype - PSPDFVideoAnnotationView, PSPDFWebAnnotationView and much more. The classic PDF link is a PSPDFLinkAnnotationView.

 This method is called recursively with all annotation types except if they return isOverlay = NO. In case of isOverlay = NO, it will call updateView to re-render the page.
 */
- (void)addAnnotation:(PSPDFAnnotation *)annotation animated:(BOOL)animated;

/// Remove an annotation from the view.
- (BOOL)removeAnnotation:(PSPDFAnnotation *)annotation animated:(BOOL)animated;

@end

@interface PSPDFPageView (AnnotationMenu)

/// Returns available PSPDFMenuItem's for the current annotation.
/// The better way to extend this is to use the shouldShowMenuItems:* delegates.
- (NSArray *)menuItemsForAnnotation:(PSPDFAnnotation *)annotation;

/// Menu for new annotations (can be disabled in PSPDFViewController)
- (NSArray *)menuItemsForNewAnnotationAtPoint:(CGPoint)point;

/// Returns available PSPDFMenuItem's to change the color.
/// The better way to extend this is to use the shouldShowMenuItems:* delegates.
- (NSArray *)colorMenuItemsForAnnotation:(PSPDFAnnotation *)annotation;

/// Returns available PSPDFMenuItem's to change the fill color (only applies to certain annotations)
- (NSArray *)fillColorMenuItemsForAnnotation:(PSPDFAnnotation *)annotation;

/// Returns the opacity menu item (used inside colorMenuItemsForAnnotation:)
- (PSPDFMenuItem *)opacityMenuItemForAnnotation:(PSPDFAnnotation *)annotation withColor:(UIColor *)color;

/// Called when a annotation was found ad the tapped location.
/// This will usually call menuItemsForAnnotation to show a UIMenuController, except for PSPDFAnnotationTypeNote which is handled differently on iPad. (showNoteControllerForAnnotation)
/// @note The better way to extend this is to use the shouldShowMenuItems:* delegates.
- (void)showMenuForAnnotation:(PSPDFAnnotation *)annotation animated:(BOOL)animated;

/// Shows a popover/modal controller to edit a PSPDFAnnotation.
- (PSPDFNoteAnnotationController *)showNoteControllerForAnnotation:(PSPDFAnnotation *)annotation showKeyboard:(BOOL)showKeyboard animated:(BOOL)animated;

/// Shows the font picker.
- (void)showFontPickerForAnnotation:(PSPDFFreeTextAnnotation *)annotation animated:(BOOL)animated;

/// Shows the color picker.
- (void)showColorPickerForAnnotation:(PSPDFAnnotation *)annotation animated:(BOOL)animated;

/// Font sizes for the freetext annotation menu. Defaults to @[@(10), @(12), @(14), @(18), @(22), @(26), @(30), @(36), @(48), @(64)]
- (NSArray *)availableFontSizes;

/// Line thickness options (ink, border). Defaults to @[@(1), @(3), @(6), @(9), @(12), @(16), @(25), @(40)];
- (NSArray *)availableLineWidths;

/// Returns the passthrough views for the popover controllers (e.g. color picker).
/// By default this is fairly aggressive and returns the pdfController/navController. If you dislike this behavior return nil to enforce the rule first touch after popover = no reaction. However the passthroughViews allow a faster editing of annotations.
- (NSArray *)passthroughViewsForPopoverController;

@end


// Extends the UIScrollViewDelegate.
@interface PSPDFPageView (ScrollViewDelegateExtensions)

- (void)pspdf_scrollView:(UIScrollView *)scrollView willZoomToScale:(float)scale animated:(BOOL)animated;

@end

@interface PSPDFPageView (SubclassingHooks)

/// Will be called automatically after kPSPDFInitialAnnotationLoadDelay.
/// Call manually to speed up rendering. Has no effect if called multiple times.
- (void)loadPageAnnotationsAnimated:(BOOL)animated blockWhileParsing:(BOOL)blockWhileParsing;

/// Returns annotations that we could tap on. (checks against editableAnnotationTypes)
/// The point will have a variance of a few pixels to improve touch recognition.
- (NSArray *)tappableAnnotationsAtPoint:(CGPoint)viewPoint;

/// Can be used for manual tap forwarding.
- (BOOL)singleTappedAtViewPoint:(CGPoint)viewPoint;

/// Show menu if annotation/text is selected.
- (void)showMenuIfSelectedAnimated:(BOOL)animated;

/// Show signature menu.
- (void)showNewSignatureMenuAtPoint:(CGPoint)point;

// Show image menu.
- (void)showNewImageMenuAtPoint:(CGPoint)point;

// Get annotation rect (PDF coordinate space)
- (CGRect)rectForAnnotation:(PSPDFAnnotation *)annotation;

/// Returns the default color options for the specified annotation type.
- (PSPDFOrderedDictionary *)defaultColorOptionsForAnnotationType:(PSPDFAnnotationType)annotationType;

/// Render options that are used for the live-page rendering. (not for the cache)
/// One way to use this would be to customize what annotations types will be rendered with the pdf.
/// See PSPDFPageRenderer for a list of options.
- (NSDictionary *)renderOptionsDictWithZoomScale:(CGFloat)zoomScale;

/// Temporarily suspend rendering updates to the renderView.
@property (nonatomic, assign) BOOL suspendUpdate;

/// Remove a page annotation/view as soon as the page has been refreshed. Will also refresh page.
- (BOOL)removeAnnotationOnNextPageUpdate:(PSPDFAnnotation *)annotation;
- (void)removeViewOnNextPageUpdate:(UIView *)view;

/// View for the selected annotation.
@property (nonatomic, strong, readonly) PSPDFResizableView *annotationSelectionView;

/// Will create and show the action sheet on long-press above a PSPDFLinkAnnotation.
/// Return nil if you don't show the actionSheet, or return the object you're showing. (UIView or UIViewController subclass)
- (id)showLinkPreviewActionSheetForAnnotation:(PSPDFLinkAnnotation *)annotation fromRect:(CGRect)viewRect animated:(BOOL)animated;

/// Will parse the text glyphs async to allow text selection. Override to disable.
- (void)preloadTextParser;

// Computes a scale value suitable for computation of the line width to use during drawing and selection.
- (CGFloat)scaleForPageView;

@end
