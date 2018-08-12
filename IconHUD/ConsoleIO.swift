//
//  ConsoleIO.swift
//  Summaricon
//
//  Created by tueno on 2017/04/24.
//  Copyright © 2017年 tueno Ueno. All rights reserved.
//

import Foundation

final class ConsoleIO {
    
    // MARK: Input
    
    class func optionsInCommandLineArguments() -> [OptionType] {
        let arguments = CommandLine.arguments
        let containingOptions = OptionType.allValues
            .filter { (option) -> Bool in
                return option.values
                    .filter({ (value) -> Bool in
                        return arguments.contains(value)
                    })
                    .count > 0
            }
        return containingOptions
    }
    
    class func optionArgument(option: OptionType) -> String? {
        let arguments = CommandLine.arguments
        let index = arguments
            .enumerated()
            .filter { (index: Int, argument: String) -> Bool in
                return option.values.contains(argument)
            }
            .first?
            .offset
        guard let i = index, i+1 < arguments.count, !arguments[i+1].hasPrefix("-") else {
            return nil
        }
        return arguments[i+1]
    }
    
    class func environmentVariable(key: EnvironmentVariable) -> String {
        return ProcessInfo().environment[key.rawValue] ?? ""
    }
    
    class var executableName: String {
        get {
            return CommandLine.arguments.first!
                .components(separatedBy: "/")
                .last!
        }
    }
    
    // MARK: Output
    
    class func printVersion() {
        print(IconConverter.Version)
    }
    
    class func printUsage() {
        print("Usage:")
        print("")
        print("     Add the 'Run Scripts' phase to after 'Copy Bundle Resources' phase and then add the line below to 'Run Scripts' phase.")
        print("")
        print("     ----------")
        print("     \(executableName)")
        print("     ----------")
        print("")
        print("Options:")
        print("")
        OptionType.allValues
            .forEach { (option) in
                let argumentsStr = option.valuesToPrint
                print("     [\(argumentsStr)]\(option.usage)")
            }
        printNotice()
    }
    
    class func printNotice() {
        print("")
        print("*** IMPORTANT ***")
        print("")
        print("1. \(executableName) uses 'Build Configurations' name of Xcode project to detect relase build. (There are 'Debug' and 'Release' values as default.)")
        print("   So if you change Release BuildConfig name, \(executableName) will process icon even if you want to build for release.")
        print("")
        print("2. Don't forget to place 'Run Scripts' phase that contains 'iconhud' on after 'Copy Bundle Resources' phase.")
        print("")
        print("*****************")
    }
    
}
