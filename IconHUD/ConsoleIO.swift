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
        print("     Add the line below to RunScript phase of your Xcode project.")
        print("")
        print("     \(executableName)")
        print("")
        print("Options:")
        print("")
        OptionType.allValues
            .forEach { (option) in
                let argumentsStr = option.valuesToPrint
                print("     [\(argumentsStr)]\(option.usage)")
            }
    }
    
    class func printNotice() {
        print("")
        print("*** IMPORTANT ***")
        print("\(executableName) currently uses BuildConfig name to detect Relase build.")
        print("So if you change Release BuildConfig name, \(executableName) will process icon even if you want to build for release.")
        print("")
    }
    
}
