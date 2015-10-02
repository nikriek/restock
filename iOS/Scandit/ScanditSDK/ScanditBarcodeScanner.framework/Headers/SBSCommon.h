//
//  ScanditSDKCommon.h
//  ScanditBarcodeScanner
//
//  Created by Marco Biasini on 29/05/15.
//  Copyright (c) 2015 Scandit AG. All rights reserved.
//


#define SBS_DEPRECATED __attribute__((deprecated))

/**
 * Enumeration of different camera orientations.
 *
 * \since 2.1.7
 */
typedef enum {
    SBSCameraFacingDirectionBack, /**< Default camera orientation - facing away from user */
    SBSCameraFacingDirectionFront, /**< Facetime camera orientation - facing the user */
    CAMERA_FACING_BACK SBS_DEPRECATED = SBSCameraFacingDirectionBack,
    CAMERA_FACING_FRONT SBS_DEPRECATED = SBSCameraFacingDirectionFront,
} SBSCameraFacingDirection;

typedef SBSCameraFacingDirection CameraFacingDirection SBS_DEPRECATED;


typedef enum {
    SBSOrientationPortrait,
    SBSOrientationLandscape,
    ORIENTATION_PORTRAIT SBS_DEPRECATED = SBSOrientationPortrait,
    ORIENTATION_LANDSCAPE SBS_DEPRECATED = SBSOrientationLandscape
} SBSOrientation;

typedef SBSOrientation Orientation SBS_DEPRECATED;


/**
 * Enumerates the possible working ranges for the barcode picker
 *
 * \since 4.1.0
 */
typedef enum {
    /**
     * The camera tries to focus on barcodes which are close to the camera. To scan far-
     * away codes (30-40cm+), user must tap the screen. This is the default working range
     * and works best for most use-cases. Only change the default value if you expect the
     * users to often scan codes which are far away.
     */
    SBSWorkingRangeStandard,
    /**
     * The camera tries to focus on barcodes which are far from the camera. This will make
     * it easier to scan codes that are far away but degrade performance for very close
     * codes.
     */
    SBSWorkingRangeLong,
    STANDARD_RANGE SBS_DEPRECATED = SBSWorkingRangeStandard,
    LONG_RANGE SBS_DEPRECATED = SBSWorkingRangeLong,
    /**
     * \deprecated This value has been deprecated in Scandit SDK 4.2+. Setting it has no effect.
     */
    HIGH_DENSITY SBS_DEPRECATED
} SBSWorkingRange;

typedef SBSWorkingRange WorkingRange;

/**
 * \brief Enumeration of different MSI Checksums
 *
 * \since 3.0.0
 */
typedef enum {
    SBSMsiPlesseyChecksumTypeNone,
    SBSMsiPlesseyChecksumTypeMod10, /**< Default MSI Plessey Checksum */
    SBSMsiPlesseyChecksumTypeMod1010,
    SBSMsiPlesseyChecksumTypeMod11,
    SBSMsiPlesseyChecksumTypeMod1110,
    NONE SBS_DEPRECATED = SBSMsiPlesseyChecksumTypeNone,
    CHECKSUM_MOD_10 SBS_DEPRECATED = SBSMsiPlesseyChecksumTypeMod10,
    CHECKSUM_MOD_1010 SBS_DEPRECATED = SBSMsiPlesseyChecksumTypeMod1010,
    CHECKSUM_MOD_11 SBS_DEPRECATED = SBSMsiPlesseyChecksumTypeMod11,
    CHECKSUM_MOD_1110 SBS_DEPRECATED = SBSMsiPlesseyChecksumTypeMod1110
} SBSMsiPlesseyChecksumType;

typedef SBSMsiPlesseyChecksumType MsiPlesseyChecksumType SBS_DEPRECATED;

/**
 * \brief Enumeration of different GUI styles.
 *
 * \since 4.8.0
 */
typedef enum {
    /**
     * A rectangular viewfinder with rounded corners is shown in the specified size. Recognized 
     * codes are marked with four corners.
     */
    SBSGuiStyleDefault,
    /**
     * A laser line is shown with the specified width while the height is not changeable. This mode
     * should generally not be used if the recognition is running on the whole screen as it 
     * indicates that the code should be placed at the location of the laser line.
     */
    SBSGuiStyleLaser
} SBSGuiStyle;
