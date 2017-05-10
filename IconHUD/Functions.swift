//
//  Functions.swift
//  Summaricon
//
//  Created by tueno on 2017/04/25.
//  Copyright © 2017年 Tomonori Ueno. All rights reserved.
//

import Foundation

func shell(launchPath: String, currentDirPath: String?, arguments: [String]) -> String {
    let task = Process()
    task.launchPath = launchPath
    if let currentDirPath = currentDirPath {
        task.currentDirectoryPath = currentDirPath
    }
    task.arguments      = arguments
    let pipe            = Pipe()
    task.standardOutput = pipe
    task.launch()
    let data   = pipe.fileHandleForReading.readDataToEndOfFile()
    let output = String(data: data, encoding: String.Encoding.utf8)!
    return output.replacingOccurrences(of: "\n", with: "")
}

func bash(command: String, currentDirPath: String?, arguments: [String]) -> String {
    let whichPathForCommand = shell(launchPath: "/bin/bash", currentDirPath: nil, arguments: [ "-l", "-c", "which \(command)" ])
    return shell(launchPath: whichPathForCommand,
                 currentDirPath: currentDirPath,
                 arguments: arguments)
}
