//
//  AppDelegate.h
//  Reader
//
//  Created by  Basispress on 12/18/12.
//  Copyright (c) 2012 Basispress. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CredentialStore;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (nonatomic, strong) CredentialStore *credentialStore;

@property (strong, nonatomic) UIWindow *window;

/*
- setCoverImage sets the newsstand icon for the app to the latest issue and updates the application icon to show the new badge
 if there are any unread issues.
 
 BR:
 ===
 - setCoverImage define o icone newsstand para a app com a imagem da última edição, além de exibir o badge de "novo" para o caso de have alguma edição não lida
 */
- (void)setCoverImage;

@end
