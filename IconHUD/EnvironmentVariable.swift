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
}
