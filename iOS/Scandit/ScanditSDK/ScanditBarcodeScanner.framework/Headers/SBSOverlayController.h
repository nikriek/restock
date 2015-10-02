//
//  SBSOverlayController.h
//  ScanditBarcodeScanner
//
//  Created by Marco Biasini on 09/06/15.
//  Copyright (c) 2015 Scandit AG. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * \brief controls the scan screen user interface.
 *
 *
 * The overlay controller can be used to configure various scan screen UI elements such as
 * toolbar, torch, camera switch icon, scandit logo and the viewfinder.
 *
 * Developers can inherit from the SBSOverlayController to implement their own
 * scan screen user interfaces.
 *
 * \since 1.0.0
 *
 * Copyright 2010 Mirasense AG. All rights reserved.
 */

#import <UIKit/UIKit.h>
#import "AudioToolbox/AudioServices.h"

#import "SBSCommon.h"

@class SBSOverlayController;
@class SBSBarcodePicker;

/**
 * \brief Protocol cancel events
 * \ingroup scanditsdk-ios-api
 * \since 4.7.0
 */
@protocol SBSOverlayControllerDidCancelDelegate

/**
 * \brief Is called when the user clicks the cancel button in the scan user interface
 *
 * \since 4.7.0
 *
 * \param overlayController SBSOverlayController that is delegating
 * \param status dictionary (currently empty)
 *
 */
- (void)overlayController:(SBSOverlayController *)overlayController
                didCancelWithStatus:(NSDictionary *)status;

@end

/**
 * Enumeration of different camera switch options.
 *
 * \since 3.0.0
 */
typedef enum {
    SBSCameraSwitchVisibilityNever,
    SBSCameraSwitchVisibilityOnTablet,
    SBSCameraSwitchVisibilityAlways,
    CAMERA_SWITCH_NEVER SBS_DEPRECATED = SBSCameraSwitchVisibilityNever,
    CAMERA_SWITCH_ON_TABLET SBS_DEPRECATED = SBSCameraSwitchVisibilityOnTablet,
    CAMERA_SWITCH_ALWAYS SBS_DEPRECATED = SBSCameraSwitchVisibilityAlways
} SBSCameraSwitchVisibility;

typedef SBSCameraSwitchVisibility CameraSwitchVisibility SBS_DEPRECATED;


/**
 * \brief  controls the scan screen user interface.
 *
 * The overlay controller can be used to configure various scan screen UI elements such as
 * toolbar, torch, camera switch icon, scandit logo and the viewfinder.
 *
 * Developers can inherit from the ScanditSDKOverlayController to implement their own
 * scan screen user interfaces.
 *
 * \ingroup scanditsdk-ios-api
 *
 * \since 4.7.0
 *
 * \nosubgrouping
 *
 *  Copyright 2010 Mirasense AG. All rights reserved.
 */
@interface SBSOverlayController : UIViewController


/**
 * \brief The tool bar that can be shown at the bottom of the scan screen.
 *
 * \since 1.0.0
 */
@property (nonatomic, strong, readonly) UIToolbar *toolBar;

/**
 * \brief The overlay controller delegate that handles the didCancelWithStatus callback.
 *
 * \since 4.7.0
 */
@property (nonatomic, weak) id<SBSOverlayControllerDidCancelDelegate> cancelDelegate;

/**
 * \brief The GUI style drawn to display the indicator where the code should be scanned and the
 * visualization of recognized codes.
 *
 * By default this is SBSGuiStyleDefault.
 *
 * \since 4.8.0
 */
@property (nonatomic, assign) SBSGuiStyle guiStyle;

/** \name Sound Configuration
 *  Customize the scan sound.
 */
///\{

/**
 * \brief Enables (or disables) the sound when a barcode is recognized. If the phone's ring mode
 * is set to muted or vibrate, no beep will be played regardless of the value.
 *
 * Enabled by default.
 *
 * \since 1.0.0
 *
 * \param enabled Whether the beep is enabled.
 */
- (void)setBeepEnabled:(BOOL)enabled;

/**
 * \brief Enables or disables the vibration when a code was recognized. If the phone's ring mode
 * is set to muted, no beep will be played regardless of the value.
 *
 * Enabled by default.
 *
 * \since 1.0.0
 *
 * \param enabled Whether vibrate is enabled.
 */
- (void)setVibrateEnabled:(BOOL)enabled;

/**
 * \brief Sets the audio sound played when a code has been successfully recognized.
 *
 * File needs to be placed in Resources folder.
 *
 * Note: This feature is only available with the
 * Scandit SDK Enterprise Packages.
 *
 * The default is: "beep.wav"
 *
 * \since 2.0.0
 *
 * \param path The file name of the sound file (without suffix).
 * \param extension The file type.
 * \return Whether the change was successful.
 */
- (BOOL)setScanSoundResource:(NSString *)path ofType:(NSString *)extension;
///\}


/** \name Torch Configuration
 *  Enable and customize appearance of the torch icon.
 */
///\{

/**
 * \brief Enables or disables the torch toggle button for all devices/cameras that support a torch.
 *
 * By default it is enabled. The torch icon is never shown when the camera does not have a
 * torch (most tablets, front cameras, etc).
 *
 * \since 2.0.0
 *
 * \param enabled Whether the torch button should be shown.
 */
- (void)setTorchEnabled:(BOOL)enabled;

/**
 * \brief Sets the images which are being drawn when the torch is on.
 *
 * By default these are "flashlight-turn-off-icon.png" and "flashlight-turn-off-icon-pressed.png"
 * which come with the framework's resource bundle.
 *
 * \since 4.7.0
 *
 * \param torchOnImage The image for when the torch is on.
 * \param torchOnPressedImage The image for when the torch is on and it is pressed.
 * \return Whether the change was successful.
 */
- (BOOL)setTorchOnImage:(UIImage *)torchOnImage pressed:(UIImage *)torchOnPressedImage;

/**
 * \brief Sets the images which are being drawn when the torch is on.
 *
 * If you want this to be displayed in proper resolution on high resolution screens, you need to
 * also provide a resource with the same name but \2x appended and in higher resolution (like
 * flashlight-turn-on-icon\2x.png).
 *
 * File needs to be placed in Resources folder.
 *
 * By default this is: "flashlight-turn-off-icon.png" and "flashlight-turn-off-icon-pressed.png"
 *
 * \since 2.0.0
 *
 * \param fileName The file name for when the torch is on (without suffix).
 * \param pressedFileName The file name for when the torch is on and it is pressed (without suffix).
 * \param extension The file type.
 * \return Whether the change was successful.
 */
- (BOOL)setTorchOnImageResource:(NSString *)fileName
                pressedResource:(NSString *)pressedFileName
                         ofType:(NSString *)extension;

/**
 * \brief Sets the images which are being drawn when the torch is off.
 *
 * By default this is: "flashlight-turn-on-icon.png" and "flashlight-turn-on-icon-pressed.png"
 * which come with the framework's resource bundle.
 *
 * \since 4.7.0
 *
 * \param torchOffImage The image for when the torch is off.
 * \param torchOffPressedImage The image for when the torch is off and it is pressed.
 * \return Whether the change was successful.
 */
- (BOOL)setTorchOffImage:(UIImage *)torchOffImage pressed:(UIImage *)torchOffPressedImage;

/**
 * \brief Sets the images which are being drawn when the torch is off.
 *
 * If you want this to be displayed in proper resolution on high resolution screens, you need to
 * also provide a resource with the same name but \2x appended and in higher resolution (like
 * flashlight-turn-on-icon\2x.png).
 *
 * By default this is: "flashlight-turn-on-icon.png" and "flashlight-turn-on-icon-pressed.png"
 *
 * \since 2.0.0
 *
 * \param fileName The file name for when the torch is off (without suffix).
 * \param pressedFileName The file name for when the torch is off and it is pressed (without suffix).
 * \param extension The file type.
 * \return Whether the change was successful.
 */
- (BOOL)setTorchOffImageResource:(NSString *)fileName
                 pressedResource:(NSString *)pressedFileName
                          ofType:(NSString *)extension;

/**
 * \brief Sets the position at which the button to enable the torch is drawn.
 *
 * By default the margins are 15 and width and height are 40.
 *
 * \since 4.7.0
 *
 * \param leftMargin Left margin in points.
 * \param topMargin Top margin in points.
 * \param width Width in points.
 * \param height Height in points.
 */
- (void)setTorchButtonLeftMargin:(float)leftMargin
                       topMargin:(float)topMargin
                           width:(float)width
                          height:(float)height;
///\}


/** \name Camera Switch Configuration
 *  Enable camera switch and set icons
 */
///\{

/**
 * \brief Sets when the camera switch button is visible for devices that have more than one camera.
 *
 * By default it is CameraSwitchVisibility#CAMERA_SWITCH_NEVER.
 *
 * \since 3.0.0
 *
 * \param visibility The visibility of the camera switch button
 *                   (\ref SBSCameraSwitchVisibilityNever, \ref SBSCameraSwitchVisibilityOnTablet,
 *                   \ref SBSCameraSwitchVisibilityAlways
 */
- (void)setCameraSwitchVisibility:(SBSCameraSwitchVisibility)visibility;

/**
 * \brief Sets the images which are being drawn when the camera switch button is visible.
 *
 * By default this is "camera-swap-icon.png" and "camera-swap-icon-pressed.png"
 * which come with the framework's resource bundle.
 *
 * \since 4.7.0
 *
 * \param cameraSwitchImage The image for the camera swap button.
 * \param cameraSwitchPressedImage The image for the camera swap button when pressed.
 * \return Whether the change was successful.
 */
- (BOOL)setCameraSwitchImage:(UIImage *)cameraSwitchImage
                     pressed:(UIImage *)cameraSwitchPressedImage;

/**
 * \brief Sets the images which are being drawn when the camera switch button is visible.
 *
 * If you want this to be displayed in proper resolution on high resolution screens, you need to
 * also provide a resource with the same name but \2x appended and in higher resolution (like
 * flashlight-turn-on-icon\2x.png).
 *
 * File needs to be placed in Resources folder.
 *
 * By default this is: "camera-swap-icon.png" and "camera-swap-icon-pressed.png"
 *
 * \since 3.0.0
 *
 * \param fileName The file name of the camera swap button's image (without suffix).
 * \param pressedFileName The file name of the camera swap button's image when pressed (without suffix).
 * \param extension The file type.
 * \return Whether the change was successful.
 */
- (BOOL)setCameraSwitchImageResource:(NSString *)fileName
                     pressedResource:(NSString *)pressedFileName
                              ofType:(NSString *)extension;

/**
 * \brief Sets the position at which the button to switch the camera is drawn.
 *
 * The X and Y coordinates are relative to the screen size, which means they have to be between
 * 0 and 1. Be aware that the x coordinate is calculated from the right side of the screen and not
 * the left like with the torch button.
 *
 * By default this is set to x = 0.04, y = 0.02, width = 40 and height = 40.
 *
 * \since 3.0.0
 *
 * \param rightMargin Right margin in points.
 * \param topMargin Top margin in points
 * \param width Width in points.
 * \param height Height in points.
 */
- (void)setCameraSwitchButtonRightMargin:(float)rightMargin
                               topMargin:(float)topMargin
                                   width:(float)width
                                  height:(float)height;
///\}

/** \name Viewfinder Configuration
 *  Customize the viewfinder where the barcode location is highlighted.
 */
///\{

/**
 * \brief Shows/hides viewfinder rectangle and highlighted barcode location in the scan screen UI.
 *
 * Note: This feature is only available with the Scandit SDK Enterprise Packages.
 *
 * By default this is enabled.
 *
 * \since 1.0.0
 *
 * \param draw Whether the viewfinder rectangle should be drawn.
 */
- (void)drawViewfinder:(BOOL)draw;

/**
 * \brief Sets the size of the viewfinder relative to the size of the screen size.
 *
 * Changing this value does not(!) affect the area in which barcodes are successfully recognized.
 * It only changes the size of the box drawn onto the scan screen. To restrict the active scanning area,
 * use the methods listed below.
 *
 * \see ScanditSDKBarcodePicker#restrictActiveScanningArea:
 * \see ScanditSDKBarcodePicker#setScanningHotSpotToX:andY:
 * \see ScanditSDKBarcodePicker#setScanningHotSpotHeight:
 *
 * By default the width is 0.8, height is 0.4, landscapeWidth is 0.6, landscapeHeight is 0.4
 *
 * \since 3.0.0
 *
 * \param h Height of the viewfinder rectangle in portrait orientation.
 * \param w Width of the viewfinder rectangle in portrait orientation.
 * \param lH Height of the viewfinder rectangle in landscape orientation.
 * \param lW Width of the viewfinder rectangle in landscape orientation.
 */
- (void)setViewfinderHeight:(float)h
                      width:(float)w
            landscapeHeight:(float)lH
             landscapeWidth:(float)lW;

/**
 * \brief Sets the color of the viewfinder before a bar code has been recognized
 *
 * Note: This feature is only available with the Scandit SDK Enterprise Packages.
 *
 * By default this is: white (1.0, 1.0, 1.0)
 *
 * \since 1.0.0
 *
 * \param r Red component (between 0.0 and 1.0).
 * \param g Green component (between 0.0 and 1.0).
 * \param b Blue component (between 0.0 and 1.0).
 */
- (void)setViewfinderColor:(float)r green:(float)g blue:(float)b;

/**
 * \brief Sets the color of the viewfinder once the bar code has been recognized.
 *
 * Note: This feature is only available with the Scandit SDK Enterprise Packages.
 *
 * By default this is: light blue (0.222, 0.753, 0.8)
 *
 * \since 1.0.0
 *
 * \param r Red component (between 0.0 and 1.0).
 * \param g Green component (between 0.0 and 1.0).
 * \param b Blue component (between 0.0 and 1.0).
 */
- (void)setViewfinderDecodedColor:(float)r green:(float)g blue:(float)b;


/**
 * \brief Resets the scan screen user interface to its initial state.
 *
 * This resets the animation showing the barcode
 * locations to its initial state.
 *
 * \since 1.0.0
 */
- (void)resetUI;
///\}


/** \name Toolbar Configuration
 *  Customize toolbar appearance
 */
///\{

/**
 * \brief Adds (or removes) a tool bar to/from the bottom of the scan screen.
 *
 * \since 1.0.0
 *
 * \param show boolean indicating whether toolbar should be shown.
 */
- (void)showToolBar:(BOOL)show;

/**
 * \brief Sets the caption of the toolbar button.
 *
 * By default this is: "Cancel"
 *
 * \since 1.0.0
 *
 * \param caption string used for cancel button caption
 */
- (void)setToolBarButtonCaption:(NSString *)caption;
///\}


/** \name Camera Permission Configuration
 *  Customize the text shown if the camera can not be aquired.
 */
///\{

/**
 * \brief Sets the text shown if the camera can not be aquired because the app does not have
 *        permission to access the camera.
 *
 * By default this is: "The Barcode Picker was unable to access the device's camera.\n\nGo to 
 * Settings -> Privacy -> Camera and check that this app has permission to use the camera."
 *
 * \since 4.7.0
 *
 * \param infoText string used for cancel button caption
 */
- (void)setMissingCameraPermissionInfoText:(NSString *)infoText;
///\}

@end

