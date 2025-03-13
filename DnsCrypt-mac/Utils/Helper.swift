//
//  Helper.swift
//  DnsCrypt-mac
//
//  Created by Ariesta Agung on 09/03/25.
//

import Foundation

class Helper {
    static let shared = Helper()
    
    func getCPUArchitecture() -> CPUArchType {
        var cpuType: Int32 = 0
        var size = MemoryLayout<Int32>.size
        
        sysctlbyname("hw.cputype", &cpuType, &size, nil, 0)
        
        let CPU_ARCH_ABI64: Int32 = 0x01000000
        let CPU_TYPE_ARM64: Int32 = 0x0100000c
        let CPU_TYPE_X86_64: Int32 = 0x01000007
        
        if (cpuType & CPU_ARCH_ABI64) != 0 {
            if cpuType == CPU_TYPE_ARM64 {
                return .ARM64
            } else if cpuType == CPU_TYPE_X86_64 {
                return .x86_64
            }
        }
        
        return .unrecognized
    }
    
    
    func unzipFile(at fileURL: URL, completion: @escaping (Result<URL, Error>) -> Void) {
        let destinationURL = fileURL.deletingPathExtension()
        
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            DispatchQueue.main.async {
                completion(.failure(NSError(domain: "File does not exist", code: 1, userInfo: nil)))
            }
            return
        }
        var isDirectory: ObjCBool = false
        print(fileURL.deletingPathExtension().path)
        if FileManager.default.fileExists(atPath: fileURL.deletingPathExtension().path, isDirectory: &isDirectory) {
            if isDirectory.boolValue {
                print("Extracted folder exists and is a directory.")
                do {
                    try FileManager.default.removeItem(at: fileURL)
                } catch {
                    print("Error remove Item: \(error.localizedDescription)")
                }
                return
            } else {
                print("A file exists at the path, but it's not a folder.")
                do {
                    try FileManager.default.removeItem(atPath: fileURL.path)
                } catch {
                    print("Error remove Item: \(error.localizedDescription)")
                }
            }
        } else {
            print("Extracted folder does not exist.")
        }
        
        do {
            try FileManager.default.createDirectory(at: destinationURL, withIntermediateDirectories: true)
            
            let process = Process()
            process.executableURL = URL(fileURLWithPath: "/usr/bin/unzip")
            process.arguments = [fileURL.path, "-d", destinationURL.path]
            
            try process.run()
            process.waitUntilExit()
            try FileManager.default.removeItem(at: fileURL)
            
            DispatchQueue.main.async {
                if process.terminationStatus == 0 {
                    completion(.success(destinationURL))
                } else {
                    completion(.failure(NSError(domain: "Unzip failed", code: 2, userInfo: nil)))
                }
            }
        } catch {
            DispatchQueue.main.async {
                completion(.failure(error))
            }
        }
    }
    
    func accessFile(in unzippedFolder: URL, fileName: String, completion: @escaping (Result<String, Error>) -> Void) {
        let fileURL = unzippedFolder.appendingPathComponent(fileName)
        
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            completion(.failure(NSError(domain: "File not found", code: 3, userInfo: nil)))
            return
        }
        
        do {
            let content = try String(contentsOf: fileURL, encoding: .utf8)
            completion(.success(content))
        } catch {
            completion(.failure(error))
        }
    }
    
    func execute(_ command: String, isSudo: Bool = false) throws -> String {
        let escapedCommand = command.replacingOccurrences(of: "\"", with: "\\\"")
        
        let process = Process()
        let pipe = Pipe()
        
        if isSudo {
            let script = "do shell script \"\(escapedCommand)\" with administrator privileges"
            print(script)
            process.launchPath = "/usr/bin/osascript"
            process.arguments = ["-e", script]
        } else {
            process.launchPath = "/bin/sh"
            process.arguments = ["-c", command]
        }

        process.standardOutput = pipe
        process.standardError = pipe
        
        try process.run()
        process.waitUntilExit()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        guard let output = String(data: data, encoding: .utf8) else {
            throw CommandError.invalidData
        }
        
        process.waitUntilExit()
        guard process.terminationStatus == 0 else {
            throw CommandError.commandFailed(output)
        }
        
        return output
    }
    
    func parseLog(_ output: String) throws -> [String] {
        let lines = output.components(separatedBy: .newlines)
        guard lines.count > 1 else {
            throw CommandError.emptyOutput
        }
        return lines
    }
    
}
