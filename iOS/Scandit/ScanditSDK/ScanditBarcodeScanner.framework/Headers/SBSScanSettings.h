//
//  SBSScanSettings.h
//  BarcodeScanner
//
//  Created by Moritz Hartmeier on 20/05/15.
//  Copyright (c) 2015 Scandit AG. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SBSSymbologySettings.h"
#import "SBSCommon.h"

/**
 * Holds settings that affect the recognition of barcodes, such as enabled
 * barcode symbologies, scanning hot spot etc.
 *
 * The SBSScanSettings class was introduced in ScanditSDK 4.7 to hold all
 * scan-specific settings. The settings are passed to the SBSBarcodePicker
 * when it is constructed.
 *
 * Scan settings are not directly allocated, instead you should use one of the factory settings
 * (#defaultSettings or #pre47DefaultSettings) to receive a settings instance.
 *
 * @since 4.7.0
 */

@interface SBSScanSettings : NSObject<NSCopying>

/**
 * \brief Settings object with default values
 *
 * \return new settings object
 */
+ (instancetype)defaultSettings;

/**
 * \brief Convenience method to retrieve default settings as they were before ScanditSDK 4.7
 *
 * This method will return a settings object with symbologies on that were
 * on by default for ScanditSDK 4.6 and older. These symbologies include
 * EAN13, UPC12, EAN8, UPCE, CODE39, ITF, CODE128,QR, DATAMATRIX.
 *
 * The use of this method is discouraged. Use #defaultSettings instead and explicitly enable the 
 * symbologies that are required by your app.
 *
 * \return new settings object
 */
+ (instancetype)pre47DefaultSettings;

@property (nonatomic, assign) SBSWorkingRange workingRange;

/**
 * \brief Enable decoding of the given symbologies.
 *
 * This function provides a convenient shortcut to enabling/disabling decoding of a
 * particular symbology without having to go through SBSSymbologySettings.
 *
 * By default, all symbologies are turned off and symbologies need to be
 * explicitly enabled.
 *
 * \param symbologies The symbologies that should be enabled.
 *
 * \since 4.7.0
 */
 - (void)enableSymbologies:(NSSet *)symbologies;

/**
 * \brief Enable/disable decoding of a certain symbology.
 *
 * This function provides a convenient shortcut to enabling/disabling decoding of a
 * particular symbology without having to go through SBSSymbologySettings.
 *
 * \code
 * SBSBarcodeScannerSettings* settings = ... ;
 * [settings setSymbology:SymbologyQR enabled:YES];
 *
 * // the following line has the same effect:
 * [settings settingsForSymbology:SymbologyQR].enabled = YES;
 *
 * \endcode
 *
 * \param symbology The symbology to be enabled.
 * \param enabled YES when decoding of the symbology should be enabled, NO if not.
 *
 * \since 4.7.0
 */
- (void)setSymbology:(SBSSymbology)symbology enabled:(BOOL)enabled;

/**
 * \brief Returns the set of enabled symbologies
 */
- (NSSet *)enabledSymbologies;

/**
 * \brief Retrieve symbology-specific settings.
 *
 * \param symbology The symbology for which to retrieve the settings.
 * \return The symbology-specific settings object.
 *
 * \since 4.7.0
 */
- (SBSSymbologySettings *)settingsForSymbology:(SBSSymbology)symbology;

/**
 * \brief Forces the barcode scanner to always run the 2D decoders (QR, Datamatrix, etc.), even when
 *        the 2D detector did not detect the presence of a 2D code.
 *
 * This slows down the overall scanning speed, but can be useful when your application only tries to
 * read 2D codes. Force 2d recognition is set to on when micro data matrix mode is enabled.
 *
 * By default forced 2d recognition is disabled.
 */
@property (nonatomic, assign) BOOL force2dRecognition;

/**
 * \brief The maximum number of barcodes to be decoded every frame.
 *
 * Clamped to the range [1,6].
 *
 * \since 4.7.0
 */
@property (nonatomic, assign) NSInteger maxNumberOfCodesPerFrame;

/**
 * \brief Specifies the duplicate filter to use for the session.
 *
 * Duplicate filtering affects the handling of codes with the same data and symbology.
 * When the filter is set to -1, each unique code is only added once to the session,
 * when set to 0, duplicate filtering is disabled. Otherwise the duplicate filter
 * specifies an interval in milliseconds. When the same code (data/symbology) is scanned
 * withing the specified interval is it filtered out as a duplicate.
 *
 * The default value is 500ms.
 *
 * \since 4.7.0
 */
@property (nonatomic, assign) NSInteger codeDuplicateFilter;

/**
 * \brief Determines how long codes are kept in the session.
 *
 * When set to -1, codes are kept for the duration of the session. When set to 0, codes 
 * are kept until the next frame processing call finishes. For all other values, 
 * codeCachingDuration specifies a duration in milliseconds for how long the codes are
 * kept.
 *
 * The default value is -1.
 *
 * \since 4.7.0
 */
@property (nonatomic, assign) NSInteger codeCachingDuration;

/**
 * The zoom as a percentage of the max zoom possible (between 0 and 1).
 */
 @property (nonatomic, assign) float relativeZoom;

/**
 * \brief The preferred camera direction.
 *
 * The picker first gives preference to cameras of the given direction. When
 * the device has no such camera, cameras of the opposite face are tried as
 * well.
 *
 * By default, the back-facing camera is preferred.
 *
 * \since 4.7.0
 */
@property (nonatomic, assign) SBSCameraFacingDirection cameraFacingPreference;

/**
 * The device name to identify the current device when looking at analytics tools. Sends 
 * a request to the server to set this as soon as a connection is available.
 *
 *
 * \since 4.7.0
 */
@property (nonatomic, strong) NSString *deviceName;

/**
 * High density mode enables phones to work at higher camera resolution,
 * provided they support it. When enabled, phones that are able to run the
 * video preview at 1080p (1920x1080) will use 1080p and not just 720p
 * (1280x720). High density mode gives better decode ranges at the
 * expense of processing speed and allows to decode smaller code in the near
 * range, or codes that further away.
 * 
 * By default, high density mode is disabled.
 *
 * \since 4.7.0
 */
@property (nonatomic, assign) BOOL highDensityModeEnabled;

/**
 * \brief The active scanning area when the picker is in landscape orientation
 *
 * The active scanning area defines the rectangle in which barcodes and 2D codes are 
 * searched and decoded when the picker is in landscape orientation. By default, this area
 * is set to the full image. 
 *
 * The rectangle is defined in relative view coordinates, where the top-left corner 
 * is (0,0) and the bottom right corner of the view is (1,1).
 *
 * \since 4.7.0
 */

@property (nonatomic, assign) CGRect activeScanningAreaLandscape;

/**
 * \brief The active scanning area when the picker is in portrait orientation
 *
 * The active scanning area defines the rectangle in which barcodes and 2D codes are
 * searched and decoded when the picker is in portrait orientation. By default, this area
 * is set to the full image.
 *
 * When setting this property, restricted area scanning (#restrictedAreaScanningEnabled) is
 * automatically set to true.
 *
 * The rectangle is defined in relative view coordinates, where the top-left corner
 * is (0,0) and the bottom right corner of the view is (1,1).
 *
 * \since 4.7.0
 */
@property (nonatomic, assign) CGRect activeScanningAreaPortrait;

/**
 * \since 4.7.0
 *
 * When set to true, barcode recognition is restricted to the rectangles defined by
 * #activeScanningAreaPortrait and #activeScanningAreaLandscape, depending on the orientation of the
 * phone. When false, the whole image is searched for barcodes.
 */
@property (nonatomic, assign) BOOL restrictedAreaScanningEnabled;

/**
 * \brief Defines the point at which barcodes and 2D codes are expected.
 *
 * The hot spot is defined in relative view coordinates, where the top-left corner
 * is (0,0) and the bottom right corner of the view is (1,1).
 *
 * The default values is (0.5, 0.5).
 *
 * \since 4.7.0
 */
@property (nonatomic, assign) CGPoint scanningHotSpot;

/**
 * \brief Convenience function to set the landscape and portrait active scanning area.
 *
 * Use this method to set \ref activeScanningAreaLandscape and \ref activeScanningAreaPortrait
 * to the same value.
 *
 * \since 4.7.0
 */
- (void)setActiveScanningArea:(CGRect)area;


/**
 * \brief Enable/disable motion compensation.
 *
 * When motion compensation is enabled, special algorithms are run to improve the image quality when
 * the phone or the barcode to be scanned are moving. Motion compensation requires an OpenGLES 3.0
 * compatible device. For devices that do not support OpenGLES 3.0, setting the motion compensation
 * flag has no effect.
 *
 * Motion compensation is enabled by default.
 *
 * \since 4.7.0
 */
@property (nonatomic, assign) BOOL motionCompensationEnabled;

@end
