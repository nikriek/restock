//
//   ______     _   _                 _          _____ _____  _  __
//  |  ____|   | | (_)               | |        / ____|  __ \| |/ /
//  | |__   ___| |_ _ _ __ ___   ___ | |_ ___  | (___ | |  | | ' /
//  |  __| / __| __| | '_ ` _ \ / _ \| __/ _ \  \___ \| |  | |  <
//  | |____\__ \ |_| | | | | | | (_) | ||  __/  ____) | |__| | . \
//  |______|___/\__|_|_| |_| |_|\___/ \__\___| |_____/|_____/|_|\_\
//
//
//  Copyright (c) 2015 Estimote. All rights reserved.

#import <Foundation/Foundation.h>

typedef NS_ENUM(int, ESTColor)
{
    ESTColorUnknown,
    ESTColorMintCocktail,
    ESTColorIcyMarshmallow,
    ESTColorBlueberryPie,
    ESTColorSweetBeetroot,
    ESTColorCandyFloss,
    ESTColorLemonTart,
    ESTColorVanillaJello,
    ESTColorLiquoriceSwirl,
    ESTColorWhite,
    ESTColorTransparent
};

typedef NS_ENUM(int, ESTConnectionStatus)
{
    ESTConnectionStatusDisconnected,
    ESTConnectionStatusConnecting,
    ESTConnectionStatusConnected,
    ESTConnectionStatusUpdating
};

typedef NS_ENUM(char, ESTBroadcastingScheme)
{
    ESTBroadcastingSchemeUnknown,
    ESTBroadcastingSchemeEstimote,
    ESTBroadcastingSchemeIBeacon,
    ESTBroadcastingSchemeEddystoneURL,
    ESTBroadcastingSchemeEddystoneUID
};

typedef void(^ESTCompletionBlock)(NSError* error);
typedef void(^ESTObjectCompletionBlock)(id result, NSError* error);
typedef void(^ESTDataCompletionBlock)(NSData* result, NSError* error);
typedef void(^ESTNumberCompletionBlock)(NSNumber* value, NSError* error);
typedef void(^ESTUnsignedShortCompletionBlock)(unsigned short value, NSError* error);
typedef void(^ESTBoolCompletionBlock)(BOOL value, NSError* error);
typedef void(^ESTStringCompletionBlock)(NSString* value, NSError* error);
typedef void(^ESTProgressBlock)(NSInteger value, NSString* description, NSError* error);
typedef void(^ESTArrayCompletionBlock)(NSArray* value, NSError* error);
typedef void(^ESTDictionaryCompletionBlock)(NSDictionary *value, NSError *error);
typedef void(^ESTCsRegisterCompletonBlock)(NSError* error);

@interface ESTDefinitions : NSObject

+ (NSString *)nameForEstimoteColor:(ESTColor)color;

@end
