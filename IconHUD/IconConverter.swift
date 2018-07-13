//
//  IconConverter.swift
//  Summaricon
//
//  Created by tueno on 2017/04/24.
//  Copyright © 2017年 tueno Ueno. All rights reserved.
//

import Foundation

final class IconConverter {
    
    static let Version = "1.0"
    
    private struct Constant {
        static let releaseBuildConfigName: String = "Release"
        static let debugBuildConfigName: String   = "Debug"
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
        let appIconSetContentsJsonPaths = contentsJsonPath()
        guard appIconSetContentsJsonPaths.count > 0 else {
            print("Error: Contents.json not found.")
            return
        }
        let iconImagePaths = imagePaths(contentJsonPaths: appIconSetContentsJsonPaths)
        iconImagePaths
            .forEach { (pathInAsset: String, pathInBuildDir: String) in
                print("Copy \(pathInAsset) to \(pathInBuildDir).")
                self.copyAssetImageToBuildDirectory(pathInAsset: pathInAsset,
                                                    pathInBuildDir: pathInBuildDir)
            }
        processImages(imagePaths: iconImagePaths)
    }
    
    private func contentsJsonPath() -> [String] {
        let targetDir: String
        if let dir = ConsoleIO.optionArgument(option: .sourceDirName) {
            targetDir = dir
        } else {
            targetDir = ConsoleIO.environmentVariable(key: .projectName)
        }
        let path       = String(format: "%@/%@", ConsoleIO.environmentVariable(key: .projectRoot), targetDir)
        let manager    = FileManager.default
        let enumerator = manager.enumerator(atPath: path)
        let appIconSetContentsJsonPaths = enumerator?
            .map({ (element) -> String? in
                guard let relativePath = element as? String else {
                    return nil
                }
                return String(format: "%@/%@", path, relativePath)
            })
            .compactMap() { $0 }
            .filter({ (path) -> Bool in
                return path.hasSuffix("appiconset")
            })
            .map({ (path) -> String in
                return String(format: "%@/Contents.json", path)
            })
            ?? []
        return appIconSetContentsJsonPaths
    }
    
    private func imagePaths(contentJsonPaths: [String]) -> [(pathInAsset: String, pathInBuildDir: String)] {
        return contentJsonPaths
            .map { (contentJsonPath) -> [(pathInAsset: String, pathInBuildDir: String)] in
                print("Contents.json path -> \(contentJsonPath)")
                if let jsonData = try? Data(contentsOf: URL(fileURLWithPath: contentJsonPath)),
                    let jsonObject = try? JSONSerialization.jsonObject(with: jsonData, options: []),
                    let jsonDict = jsonObject as? [String : AnyObject] {
                    let imageNamesArray = analyzeJsonAndGetImageNames(jsonDict: jsonDict)
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
                } else {
                    print("Error: Contents.json parsing failed.")
                    return []
                }
            }
            .flatMap() { path in path }
    }
    
    private func processImages(imagePaths: [(pathInAsset: String, pathInBuildDir: String)]) {
        let buildConfig           = ConsoleIO.environmentVariable(key: .buildConfig)
        let branchName: String    = AppInfo.branchName
        let commitId: String      = AppInfo.commitId
        let buildNumber: String   = AppInfo.buildNumber
        let versionNumber: String = AppInfo.versionNumber
        let dateStr: String       = currentDate()
        
        imagePaths
            .map({ (pathInAsset: String, pathInBuildDir: String) -> String in
                return pathInBuildDir
            })
            .forEach { (path) in
                let imageWidthStr = bash(command: "identify",
                                         currentDirPath: nil,
                                         arguments: ["-format", "%w", path])
                let hudWidth        = Int(imageWidthStr) ?? 0
                let topHUDHeight    = 20
                let bottomHUDHeight = 48
                _ = bash(command: "convert",
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
                _ = bash(command: "convert",
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
    
    private func currentDate() -> String {
        let cal = Calendar(identifier: .gregorian)
        let dateComp = cal.dateComponents([.year, .month, .day, .minute, .hour],
                                          from: Date())
        return String(format: "%02d:%02d %02d/%02d %04d", dateComp.hour!,
                      dateComp.minute!,
                      dateComp.month!,
                      dateComp.day!,
                      dateComp.year!)
    }
    
    private func analyzeJsonAndGetImageNames(jsonDict: [String : AnyObject]) -> [(imageNameInAsset: String, imageNameInBuildDir: String)] {
        guard let images = jsonDict["images"] as? [[String : String]] else {
            return []
        }
        return images
            .map({ (dict) -> (imageNameInAsset: String, imageNameInBuildDir: String)? in
                guard let size = dict["size"],
                    let scale    = dict["scale"],
                    let idiom    = dict["idiom"],
                    let filename = dict ["filename"] else {
                        return nil
                }
                return (imageNameInAsset: filename,
                        imageNameInBuildDir: convertImageName(size: size, scale: scale, idiom: idiom))
            })
            .compactMap() { $0 }
    }
    
    private func convertImageName(size: String, scale: String, idiom: String) -> String {
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
        return String(format: "AppIcon%@%@%@.png", size, scaleForFilename, idiomForFilename)
    }
    
    /// Copy icon image manually. Otherwise, it modifies already modified icon file when build with cache.
    private func copyAssetImageToBuildDirectory(pathInAsset: String, pathInBuildDir: String) {
        let manager = FileManager.default
        _ = try? manager.removeItem(atPath: pathInBuildDir)
        _ = try? manager.copyItem(atPath: pathInAsset, toPath: pathInBuildDir)
    }
    
}
