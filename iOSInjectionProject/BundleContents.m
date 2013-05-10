/*
    Generated for Injection of class implementations
*/

#define INJECTION_NOIMPL
#define INJECTION_BUNDLE InjectionBundle2

#import "/Users/danielbonates/Library/Application Support/Developer/Shared/Xcode/Plug-ins/InjectionPlugin.xcplugin/Contents/Resources/BundleInjection.h"

#undef _instatic
#define _instatic extern

#undef _inglobal
#define _inglobal extern

#undef _inval
#define _inval( _val... ) /* = _val */

#import "/Users/danielbonates/ios_apps/application_part/Reader/MagazineRack/MagazineRackLayout.m"


@interface InjectionBundle2 : NSObject
@end
@implementation InjectionBundle2

+ (void)load {
    extern Class OBJC_CLASS_$_MagazineRackLayout;
	[BundleInjection loadedClass:INJECTION_BRIDGE(Class)(void *)&OBJC_CLASS_$_MagazineRackLayout notify:4];
    [BundleInjection loadedNotify:4];
}

@end

