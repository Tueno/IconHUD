//
//  OptionType.swift
//  Summaricon
//
//  Created by tueno on 2017/04/25.
//  Copyright © 2017年 tueno Ueno. All rights reserved.
//

enum OptionType {
    case ignoreDebugBuild
    case help
    case sourceDirName
    case version
    static var allValues: [OptionType] = [.ignoreDebugBuild, .help, sourceDirName, .version]

    var values: [String] {
        get {
            switch self {
            case .ignoreDebugBuild:
                return ["--ignore-debug-build"]
            case .help:
                return ["-h", "--help"]
            case .sourceDirName:
                return ["--source-dir-name"]
            case .version:
                return ["-v", "--version"]
            }
        }
    }
    var valuesToPrint: String {
        return values.joined(separator: ", ") + exampleOptionArgument
    }
    var usage: String {
        get {
            switch self {
            case .ignoreDebugBuild:
                return spaceBeforeUsage + "do nothing when BuildConfig is Debug."
            case .help:
                return spaceBeforeUsage + "show this usage."
            case .sourceDirName:
                return spaceBeforeUsage + "if you renamed source dir, you must specify it. (It sames as the ProjectName by default.)"
            case .version:
                return spaceBeforeUsage + "print version."
            }
        }
    }
    private var exampleOptionArgument: String {
        get {
            switch self {
            case .ignoreDebugBuild, .help, .version:
                return ""
            case .sourceDirName:
                return " dirname"
            }
        }
    }
    private var spaceBeforeUsage: String {
        get {
            let MaxLength = OptionType.allValues
                .map({ (option) -> Int in
                    return option.valuesToPrint.count
                })
                .max()! + 10
            return (0..<MaxLength-valuesToPrint.count)
                .reduce("") { (combined, _) -> String in
                    return combined + " "
                }
        }
    }
}
