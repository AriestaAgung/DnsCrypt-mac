//
//  CommandExecutor.swift
//  DnsCrypt-mac
//
//  Created by Ariesta Agung on 15/03/25.
//

import Foundation

class CommandExecutor {
    private var processes: [UUID: Process] = [:]  // Store processes with unique IDs
    static let shared = CommandExecutor()
    
    func execute(_ command: String, isSudo: Bool = false, completion: @escaping (Result<String, Error>) -> Void) -> UUID {
        let processID = UUID()  // Generate a unique ID for the process
        let escapedCommand = command.replacingOccurrences(of: "\"", with: "\\\"")
        var output: String = ""
        let process = Process()
        let pipe = Pipe()
        
        if isSudo {
            let script = "do shell script \"\(escapedCommand)\" with administrator privileges"
            process.launchPath = "/usr/bin/osascript"
            process.arguments = ["-e", script]
        } else {
            process.launchPath = "/bin/sh"
            process.arguments = ["-c", command]
        }

        process.standardOutput = pipe
        process.standardError = pipe
        
        process.terminationHandler = { [weak self] process in
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            print("[Commands]: \(command)")
            print(String(data: data, encoding: .utf8) ?? "EMPTY OUTPUT")
            output = String(data: data, encoding: .utf8) ?? "EMPTY OUTPUT"

            self?.processes.removeValue(forKey: processID)
            
            if process.terminationStatus == 0 {
                completion(.success(output))
            } else {
                completion(.failure(CommandError.commandFailed(output)))
                
            }
        }

        do {
            try process.run()
            processes[processID] = process
            completion(.success(output))
        } catch {
            completion(.failure(CommandError.commandFailed(error.localizedDescription + " - " + output)))
        }
        
        return processID
    }
    
    func terminate(_ processID: UUID) {
        if let process = processes[processID] {
            process.terminate()
            processes.removeValue(forKey: processID)  // Remove after termination
            print("Process \(processID) terminated.")
        } else {
            print("No process found with ID: \(processID)")
        }
    }
    
    func terminateAll() {
        for (id, process) in processes {
            process.terminate()
            print("Process \(id) terminated.")
        }
        processes.removeAll()
    }
}
