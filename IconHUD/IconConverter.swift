//
//  IconConverter.swift
//  Summaricon
//
//  Created by tueno on 2017/04/24.
//  Copyright © 2017年 tueno Ueno. All rights reserved.
//

import Foundation

final class IconConverter {
    
    static let Version = "1.1"
    
    private struct Constant {
        static let releaseBuildConfigName: String = "Release"
        static let debugBuildConfigName: String   = "Debug"
        static let tempRootRelativePath: String   = "iconhud/temp"
    }
    
    func staticMode() {        
        if ConsoleIO.optionsInCommandLineArguments().contains(.help) {
            ConsoleIO.printUsage()
        } else if ConsoleIO.optionsInCommandLineArguments().contains(.version) {
            ConsoleIO.printVersion()
        } else {
            let ignoreDebugBuild = ConsoleIO.optionsInCommandLineArguments().contains(.ignoreDebugBuild)
            modifyIcon(ignoreDebugBuild: ignoreDebugBuild)
        }
    }
    
    private func modifyIcon(ignoreDebugBuild: Bool) {        
        ConsoleIO.printNotice()
        let buildConfig = ConsoleIO.environmentVariable(key: .buildConfig)
        guard buildConfig != Constant.releaseBuildConfigName && !(buildConfig == Constant.debugBuildConfigName && ignoreDebugBuild) else {
            print("\(ConsoleIO.executableName) stopped because it is running for \(buildConfig) build.")
            return
        }

        // Copy Asset dir to temp dir
        let asestsPath = assetsPath()
        guard let assetsDirName = asestsPath.components(separatedBy: "/").last else {
            print("Error: Failed to get assets dir name.")
            return
        }
        bash(command: "mkdir", currentDirPath: ConsoleIO.environmentVariable(key: .projectRoot),
             arguments: ["-p", Constant.tempRootRelativePath])
        let tempRootPath = String(format: "%@/%@", ConsoleIO.environmentVariable(key: .projectRoot), Constant.tempRootRelativePath)
        bash(command: "cp", currentDirPath: nil, arguments: ["-R", "-f", asestsPath, tempRootPath])
        let appIconName = ConsoleIO.environmentVariable(key: .appIconName)
        let appIconSetContentsJsonPaths = String(format: "%@/%@/%@.appiconset/Contents.json", tempRootPath, assetsDirName, appIconName)
        guard appIconSetContentsJsonPaths.count > 0 else {
            print("Error: Contents.json not found.")
            return
        }
        let iconImagePaths = imagePaths(contentJsonPaths: [appIconSetContentsJsonPaths])

        // Modify icon image in temp dir
        let imagePathsInTempAssets = iconImagePaths.map { imagePaths in imagePaths.pathInAsset }
        processAppIconImages(imagePaths: imagePathsInTempAssets)

        // Generate and place files in build intermediate dir
        let tempAssetsPath = String(format: "%@/%@", tempRootPath, assetsDirName)
        generateCarFileFrom(assetsPath: tempAssetsPath)

        // Remove temp asset dir
        bash(command: "rm", currentDirPath: nil, arguments: ["-rf", tempAssetsPath])
    }

    /// Modify app icon with using imagemagick
    private func processAppIconImages(imagePaths: [String]) {
        let buildConfig           = ConsoleIO.environmentVariable(key: .buildConfig)
        let branchName: String    = AppInfo.branchName
        let commitId: String      = AppInfo.commitId
        let buildNumber: String   = AppInfo.buildNumber
        let versionNumber: String = AppInfo.versionNumber
        let dateStr: String       = Date().hourMinuteMonthDayYearString()
        
        imagePaths
            .forEach { (path) in
                let imageWidthStr = bash(command: "identify",
                                         currentDirPath: nil,
                                         arguments: ["-format", "%w", path])
                let hudWidth        = Int(imageWidthStr) ?? 0
                let topHUDHeight    = 20
                let bottomHUDHeight = 48
                bash(command: "convert",
                     currentDirPath: nil,
                     arguments: ["-background", "#0008",
                                 "-fill", "white",
                                 "-gravity", "center",
                                 "-size", String(format: "%dx%d", hudWidth, topHUDHeight),
                                 "caption:\(dateStr)",
                        path,
                        "+swap",
                        "-gravity", "north" ,
                        "-composite", path])
                bash(command: "convert",
                     currentDirPath: nil,
                     arguments: ["-background", "#0008",
                                 "-fill", "white",
                                 "-gravity", "center",
                                 "-size", String(format: "%dx%d", hudWidth, bottomHUDHeight),
                                 "caption:\(versionNumber)(\(buildNumber)) \(buildConfig) \n\(branchName) \n\(commitId)",
                        path,
                        "+swap",
                        "-gravity", "south" ,
                        "-composite", path])
        }
    }

    private func generateCarFileFrom(assetsPath: String) {
        let projectName = ConsoleIO.environmentVariable(key: .projectName)
        let intermediateBuildDir = ConsoleIO.environmentVariable(key: .tempRoot) + "/"
            + projectName + ".build/"
            + ConsoleIO.environmentVariable(key: .buildConfig) + ConsoleIO.environmentVariable(key: .effectivePlatformName) + "/"
            + projectName + ".build"
        let exportDependencyInfo   = intermediateBuildDir + "/assetcatalog_dependencies"
        let outputPartialInfoPlist = intermediateBuildDir + "/assetcatalog_generated_info.plist"
        let appPath =  ConsoleIO.environmentVariable(key: .codesigningFolderPath)
        let compileOutputDir = appPath
        let compileInputDir  = assetsPath
        print("Input path for actool: ", compileInputDir)
        let result = bash(command: "actool",
             currentDirPath: nil,
             arguments: ["--output-format", "human-readable-text",
                         "--notices", "--warnings",
                         "--export-dependency-info", exportDependencyInfo,
                         "--output-partial-info-plist", outputPartialInfoPlist,
                         "--app-icon", ConsoleIO.environmentVariable(key: .appIconName),
                         "--compress-pngs",
                         "--enable-on-demand-resources", "YES",
                         "--sticker-pack-identifier-prefix", ConsoleIO.environmentVariable(key: .stickerPackIdentifierPrefix),
                         "--target-device", "iphone", "--target-device", "ipad", //, "--target-device", "watch", "--target-device", "tv",
                         "--minimum-deployment-target", ConsoleIO.environmentVariable(key: .deploymentTarget),
                         "--platform", ConsoleIO.environmentVariable(key: .platformName),
                         "--product-type", ConsoleIO.environmentVariable(key: .productType),
                         "--compile", compileOutputDir, compileInputDir])
        print(result)
    }
    
}

// MARK: - Getting file path functions

private extension IconConverter {

    // I believe there is a more smart way to get .xcassets path...
    func assetsPath() -> String {
        let targetDir: String
        if let dir = ConsoleIO.optionArgument(option: .sourceDirName) {
            targetDir = dir
        } else {
            targetDir = ConsoleIO.environmentVariable(key: .projectName)
        }
        let path       = String(format: "%@/%@", ConsoleIO.environmentVariable(key: .projectRoot), targetDir)
        let manager    = FileManager.default
        let enumerator = manager.enumerator(atPath: path)
        let assetsPath = enumerator?
            .compactMap({ (element) -> String? in
                guard let relativePath = element as? String else {
                    return nil
                }
                return String(format: "%@/%@", path, relativePath)
            })
            .filter({ (path) -> Bool in
                return path.hasSuffix("xcassets")
            })
            .first
            ?? ""
        return assetsPath
    }

    func imagePaths(contentJsonPaths: [String]) -> [(pathInAsset: String, pathInBuildDir: String)] {
        return contentJsonPaths
            .map { (contentJsonPath) -> [(pathInAsset: String, pathInBuildDir: String)] in
                print("Contents.json path: \(contentJsonPath)")
                let imageNamesArray = extractImageNamesFromContentsJson(contentJsonPath: contentJsonPath)
                let imagePathsArray = imageNamesArray
                    .map({ (imageNames) -> (pathInAsset: String, pathInBuildDir: String) in
                        let imagePathInBuildDir = String(format: "%@/%@/%@", ConsoleIO.environmentVariable(key: .configurationBuildDir),
                                                         ConsoleIO.environmentVariable(key: .unlocalizedResourcesFolderPath),
                                                         imageNames.imageNameInBuildDir)
                        let pathToAssetDir   = NSString(string: contentJsonPath).deletingLastPathComponent
                        let imagePathInAsset = String(format: "%@/%@", pathToAssetDir, imageNames.imageNameInAsset)
                        return (pathInAsset: imagePathInAsset, pathInBuildDir: imagePathInBuildDir)
                    })
                return imagePathsArray
            }
            .flatMap() { path in path }
    }

    /// Get image names from Contents.json
    func extractImageNamesFromContentsJson(contentJsonPath: String) -> [(imageNameInAsset: String, imageNameInBuildDir: String)] {
        guard let jsonData = try? Data(contentsOf: URL(fileURLWithPath: contentJsonPath)),
            let jsonObject = try? JSONSerialization.jsonObject(with: jsonData, options: []),
            let jsonDict = jsonObject as? [String : AnyObject],
            let images = jsonDict["images"] as? [[String : String]] else {
                print("Error: Contents.json parsing failed.")
                return []
        }
        return images
            .compactMap({ (dict) -> (imageNameInAsset: String, imageNameInBuildDir: String)? in
                guard let size = dict["size"],
                    let scale    = dict["scale"],
                    let idiom    = dict["idiom"],
                    let filename = dict ["filename"] else {
                        return nil
                }
                return (imageNameInAsset: filename,
                        imageNameInBuildDir: generateAppIconImageNameFrom(size: size, scale: scale, idiom: idiom))
            })
    }

    private func generateAppIconImageNameFrom(size: String, scale: String, idiom: String) -> String {
        let scaleForFilename: String
        if scale == "1x" {
            scaleForFilename = ""
        } else {
            scaleForFilename = String(format: "@%@", scale)
        }
        let idiomForFilename: String
        if idiom == "ipad" {
            idiomForFilename = String(format: "~%@", idiom)
        } else {
            idiomForFilename = ""
        }
        let appIconName = ConsoleIO.environmentVariable(key: .appIconName)
        return String(format: "%@%@%@%@.png", appIconName, size, scaleForFilename, idiomForFilename)
    }

}
