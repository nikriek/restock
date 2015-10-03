//
//  SBSBarcodePicker.h
//  ScanditBarcodeScanner
//
//  Created by Marco Biasini on 12/06/15.
//  Copyright (c) 2015 Scandit AG. All rights reserved.
//

#import "SBSBarcodePickerBase.h"

@class SBSScanSession;
@class SBSScanSettings;
@class SBSBarcodePicker;

/**
 * \brief Protocol for accessing the processed sample buffers
 *
 * \ingroup scanditsdk-ios-api
 * \since 4.7.0
 */
@protocol SBSProcessFrameDelegate

/**
 * \brief Method invoked whenever a frame has been processed by the barcode scanner
 *
 * This method is called on the SBSBarcodePicker#processFrameDelegate whenever the barcode
 * scanner has finished processing a frame.
 *
 * \param barcodePicker the barcode picker instance that processed the frame
 * \param frame the sample buffer containing the actual frame data.
 * \param session The current scan session containing the state of the recognition process,
 *     e.g. list of codes recognized in the last processed frame. The scan session
 *     can only be accessed from within this method. It is however possible to use codes returned
 *     by SBSScanSession#newlyRecognizedCodes outside this method.
 *
 * This method is invoked from a picker-internal dispatch queue. To perform UI work, you must
 * dispatch to the main queue first. When new codes have been recognized, this method is invoked
 * after SBSScanDelegate#barcodePicker:didScan is called on the SBSBarcodePicker#scanDelegate.
 *
 */
- (void)barcodePicker:(SBSBarcodePicker*)barcodePicker
      didProcessFrame:(CMSampleBufferRef)frame
              session:(SBSScanSession*)session;
@end

/**
 * \brief Protocol for a scan event delegate
 *
 * Class implementing the SBSScanDelegate protocol receive barcode/2D code scan events whenever
 * a new code has been scanned.
 *
 * \ingroup scanditsdk-ios-api
 * \since 4.7.0
 */
@protocol SBSScanDelegate

/**
 * \brief Method invoked whenever a new code is scanned.
 *
 * This method is called on the SBSBarcodePicker#scanDelegate whenever the barcode scanner has
 * recognized new barcodes/2D codes. The newly recognized codes can be retrieved from the scan
 * session's SBSScanSession#newlyRecognizedCodes property.
 *
 * \param picker The barcode picker on which codes were scanned.
 * \param session The current scan session containing the state of the recognition
 *     process, e.g. the list of codes recognized in the last processed frame. The scan session
 *     can only be accessed from within this method. It is however possible to use codes returned
 *     by SBSScanSession#newlyRecognizedCodes outside this method.
 *
 * This method is invoked from a picker-internal dispatch queue. To perform UI work, you must
 * dispatch to the main queue first.
 */
- (void)barcodePicker:(SBSBarcodePicker*)picker didScan:(SBSScanSession*)session;

@end


@interface SBSBarcodePicker : SBSBarcodePickerBase

/**
 * \brief Orientations that the barcode picker is allowed to rotate to.
 *
 * The orientations returned by this view controller's supportedInterfaceOrientations function.
 * Be aware that this orientation mask will not be taken into consideration if the view controller
 * is part of a UITableViewController for example (in that case the UITableViewController's 
 * supportedInterfaceOrientations matter). This orientation will also not be taken into 
 * consideration if this view controller's view is directly added to a view hierarchy.
 *
 * By default all orientations are allowed (UIInterfaceOrientationMaskAll).
 *
 * \since 4.7.0
 */
@property (nonatomic, assign) UIInterfaceOrientationMask allowedInterfaceOrientations;


/**
 * \brief Initializes the barcode picker with the desired scan settings.
 *
 * Note that the initial invocation of this method will activate the Scandit Barcode Scanner SDK, 
 * after which the device will count towards your device limit.
 *
 * Make sure to set the app key available from your Scandit account through SBSLicense#setAppKey 
 * before you call this initializer.
 *
 * \since 4.7.0
 *
 * \param settings The scan settings to use. You may pass nil, which is identical to passing a 
 *     settings instance constructed through SBSScanSettings#defaultSettings.
 *
 * \return The newly constructed barcode picker instance.
 */
- (instancetype)initWithSettings:(SBSScanSettings *)settings;


/** \name Barcode Decoder Configuration
 */
///\{

/**
 * \brief Change the scan settings of an existing picker instance.
 *
 * The scan settings are applied asynchronously after this call returns. You may use the completion
 * handler to get notified when the settings have been applied to the picker. All frames processed
 * after the settings have been applied will use the new scan settings.
 *
 * \param settings The new scan settings to apply.
 *
 * \param handler An optional block that will be invoked when the settings have been
 *    applied to the picker. The block will be invoked on an internal picker dispatch queue.
 *
 * \since 4.7.0
 */
- (void)applyScanSettings:(SBSScanSettings*)settings completionHandler:(void (^)())handler;

///\}

@property (nonatomic, weak) id<SBSProcessFrameDelegate> processFrameDelegate;

/**
 * \brief The scan delegate for this barcode picker
 *
 * SBSScanDelegate#barcodePicker:didScan: is invoked on the registered scanDelegate whenever a new
 * barcode/2d code has been recognized. To react to barcode scanned events, you must provide a scan 
 * delegate that contains your application logic.
 *
 * \since 4.7.0
 */
@property (nonatomic, weak) id<SBSScanDelegate> scanDelegate;


/**
 * \brief The overlay controller controls the scan user interface.
 *
 * The Scandit BarcodeScanner contains a default implementation that developers can inherit from to 
 * define their own scan UI (enterprise licensees only).
 *
 * \since 4.7.0
 */
@property (nonatomic, strong) SBSOverlayController *overlayController;


/** \name Barcode Recognition Operation
 */
///\{

/**
 * \brief Starts/restarts the camera and the scanning process.
 *
 * Start or continue scanning barcodes after the creation of the barcode picker or a previous call
 * to #pauseScanning, SBSScanSession#pauseScanning, #stopScanning or
 * SBSScanSession#stopScanning.
 *
 * This method is identical to calling \c [SBSBarcodePicker startScanningInPausedState:NO];
 *
 * \since 4.7.0
 */

- (void)startScanning;

/**
 * \brief Starts/restarts the camera and potentially the scanning process.
 *
 * Start or continue scanning barcodes after the creation of the barcode picker or a previous call
 * to #pauseScanning, SBSScanSession#pauseScanning, #stopScanning or
 * SBSScanSession#stopScanning.
 *
 * In contrast to resumeScanning, startScanning clears the current barcode scanner session.
 *
 * \param paused If YES the barcode/2D recognition is paused but the streaming of preview images is
 *        started. If NO both the barcode/2D recognition and the streaming of preview images are
 *        started.
 *
 * \since 4.7.0
 */

- (void)startScanningInPausedState:(BOOL)paused;

/**
 * \brief Stop scanning and the video preview.
 *
 * \since 4.7.0
 */
- (void)stopScanningWithCompletionHandler:(void (^)())handler;

/**
 * \brief Stop scanning and the video preview.
 *
 * \since 4.7.0
 */
- (void)stopScanning;

/**
 * \brief Resume scanning codes
 *
 * Continue (resume) scanning barcodes after a previous call to #pauseScanning, or
 * SBSScanSession#pauseScanning. Calling #resumeScanning on a picker that was stopped with
 * #stopScanning, will not resume the scanning process.
 *
 * In contrast to startScanning, resumeScanning does not clear the current barcode scanner session.
 * Thus if you want accumulate the codes, use #pauseScanning/#resumeScanning, if you want to start
 * from an empty session, use #pauseScanning/#startScanning.
 *
 * \since 4.7.0
 */
- (void)resumeScanning;

/**
 * \brief Pause scanning but keep preview on
 *
 * This method pauses barcode/2D recognition but continues streaming preview images. Use this method
 * if you are interrupting barcode recognition for a short time and  want to continue scanning
 * barcodes/2D codes afterwards.
 *
 * Use #resumeScanning to continue scanning barcodes.
 *
 * \since 4.7.0
 */
- (void)pauseScanning;



///\}



@end
