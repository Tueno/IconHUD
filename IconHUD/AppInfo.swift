//
//  AppInfo.swift
//  Summaricon
//
//  Created by tueno on 2017/04/25.
//  Copyright © 2017年 Tomonori Ueno. All rights reserved.
//

final class AppInfo {
    
    class var branchName: String {
        get {
            let branchName = bash(command:"git",
                                  currentDirPath: ConsoleIO.environmentVariable(key: .projectRoot),
                                  arguments: ["rev-parse", "--abbrev-ref", "HEAD"])
            if branchName == "HEAD" {
                // On Travis CI
                return ConsoleIO.environmentVariable(key: .branchNameOnTravisCI)
            } else {
                return branchName
            }
        }
    }

    class var commitId: String {
        get {
            let commitId = bash(command: "git",
                                currentDirPath: ConsoleIO.environmentVariable(key: .projectRoot),
                                arguments: ["rev-parse", "--short", "HEAD"])
            return commitId
        }
    }
    
    class var buildNumber: String {
        get {
            let infoPlist   = ConsoleIO.environmentVariable(key: .infoPlist)
            let buildNumber = bash(command: "/usr/libexec/PlistBuddy",
                                   currentDirPath: ConsoleIO.environmentVariable(key: .projectRoot),
                                   arguments: ["-c", "Print CFBundleVersion", infoPlist])
            return buildNumber
        }
    }
    
    class var versionNumber: String {
        get {
            let infoPlist = ConsoleIO.environmentVariable(key: .infoPlist)
            let versionNumber = bash(command: "/usr/libexec/PlistBuddy",
                                     currentDirPath: ConsoleIO.environmentVariable(key: .projectRoot),
                                     arguments: ["-c", "Print CFBundleShortVersionString", infoPlist])
            return versionNumber
        }
    }
    
}
