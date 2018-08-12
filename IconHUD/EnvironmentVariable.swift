//
//  EnvironmentVariable.swift
//  Summaricon
//
//  Created by tueno on 2017/04/25.
//  Copyright © 2017年 tueno Ueno. All rights reserved.
//

enum EnvironmentVariable: String {
    case buildConfig                    = "CONFIGURATION"
    case branchNameOnTravisCI           = "TRAVIS_BRANCH"
    case projectRoot                    = "SOURCE_ROOT"
    case projectName                    = "PROJECT_NAME"
    case infoPlist                      = "INFOPLIST_FILE"
    case configurationBuildDir          = "CONFIGURATION_BUILD_DIR"
    case unlocalizedResourcesFolderPath = "UNLOCALIZED_RESOURCES_FOLDER_PATH"
    case tempRoot                       = "TEMP_ROOT"
    case effectivePlatformName          = "EFFECTIVE_PLATFORM_NAME" // Example: -iphoneos
    case appIconName                    = "ASSETCATALOG_COMPILER_APPICON_NAME" // Example: AppIcon
    case stickerPackIdentifierPrefix    = "ASSETCATALOG_COMPILER_STICKER_PACK_IDENTIFIER_PREFIX"
    case deploymentTarget               = "IPHONEOS_DEPLOYMENT_TARGET"
    case platformName                   = "PLATFORM_NAME"
    case productType                    = "PRODUCT_TYPE"
    case buildDir                       = "BUILD_DIR"
    case buildRoot                      = "BUILD_ROOT"
    case codesigningFolderPath          = "CODESIGNING_FOLDER_PATH"
    
}
