//
//  BaseViewModel.swift
//  DnsCrypt-mac
//
//  Created by Ariesta Agung on 09/03/25.
//

import Foundation

protocol BaseViewModelProtocol {
    func checkDNSCryptExistance()
    func checkLatestDNSCryptRelease()
    func downloadLatestDNSCrypt()
    func activateDNSCrypt()
    func deactivateDNSCrypt()
    func didToggleChange(isOn: Bool)
    func setAutoStart(isAutoStart: Bool)
    func getIsAutoStart() -> Bool
    
}


class BaseViewModel: ObservableObject, BaseViewModelProtocol {
    static let shared = BaseViewModel()
    @Published var isDNSCExist: Bool = false
    @Published var logsString: [String] = []
    private let service = BaseService.shared
    private let arch: CPUArchType = Helper.shared.getCPUArchitecture()
    private let helper = Helper.shared
    private var appPath: URL?
    private var appDir: URL?
    private var existingDNS: [String] = []
    
    func checkDNSCryptExistance() {
        let assetFolderUrl = Bundle.main.resourceURL
        
        do {
            if let assetFolderUrl {
                let itemsInDirectory = try FileManager.default.contentsOfDirectory(at: assetFolderUrl, includingPropertiesForKeys: nil)
                
                for url in itemsInDirectory {
                    if url.relativePath.contains("arm64.zip") && arch == .ARM64 {
                        self.checkAppDirectoryExists(url: url)
                    } else if url.relativePath.contains("x86_64.zip") && arch == .x86_64 {
                        self.checkAppDirectoryExists(url: url)
                    }
                }
            }
            self.logsString.append("DNSCrypt Exist!")
        } catch {
            logsString.append("Error DNSCrypt service is not exist: \(error.localizedDescription)")
        }
        setAppPath()
        print(logsString.joined(separator: "\n"))
    }
    
    private func checkAppDirectoryExists(url: URL) {
        let fileManager = FileManager.default
        let applicationSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let bundleID = Bundle.main.bundleIdentifier ?? "Company Name"
        let appSupportSubDirectory = applicationSupport.appendingPathComponent(bundleID, isDirectory: true)
        do {
            try FileManager.default.createDirectory(at: appSupportSubDirectory, withIntermediateDirectories: true, attributes: [.posixPermissions: 0o755])
        } catch {
            logsString.append("Error Create Directory: \(error.localizedDescription)")
        }
        let destinationURL = appSupportSubDirectory.appendingPathComponent(url.lastPathComponent)
        
        do {
            let destinationURL = appSupportSubDirectory.appendingPathComponent(url.lastPathComponent)
            
            try fileManager.copyItem(at: url, to: destinationURL)
            
            self.logsString.append("File copied successfully to: \(destinationURL.path)")
        } catch {
            self.logsString.append("Error copying service: \(error.localizedDescription)")
        }
        helper.unzipFile(at: destinationURL) { result in
            switch result {
            case .success(let success):
                self.logsString.append("DNSCrypt unzipped to \(success.relativePath)")
            case .failure(let failure):
                self.logsString.append("Error unzipping service: \(failure.localizedDescription)")
            }
        }
    }
    
    func checkLatestDNSCryptRelease() {
        
    }
    
    func downloadLatestDNSCrypt() {
    
    }
    
    func activateDNSCrypt() {
        installDNSCrypt()
        if let appPath {
            let safePath = "\"\(appPath.path)\""
            let command = "networksetup -setdnsservers Wi-Fi 127.0.0.1;dscacheutil -flushcache; sudo killall -HUP mDNSResponder;\(safePath) -service stop;\(safePath)"
            do {
                let logs = try helper.execute(command, isSudo: true)
                self.logsString.append(logs)
            } catch {
                self.logsString.append("Error: \(error.localizedDescription)")
                self.deactivateDNSCrypt()
            }
            logsString.append("DNS Active...")
        } else {
            logsString.append("Failed to run the app...")
            logsString.append("Trying to reinstall the app...")
            UserDefaults.standard.removeObject(forKey: "IsFirstInstall")
            installDNSCrypt()
        }
    }
    
    func deactivateDNSCrypt() {
        logsString.append("DNS Inactive...")
    }
    
    func didToggleChange(isOn: Bool) {
        if isOn {
            activateDNSCrypt()
        } else {
            deactivateDNSCrypt()
        }
    }
    
    func setAutoStart(isAutoStart: Bool) {
        UserDefaults.standard.set(isAutoStart, forKey: "isAutoStart")
    }
    
    func getIsAutoStart() -> Bool {
        let isAutoStart = UserDefaults.standard.bool(forKey: "isAutoStart")
        if isAutoStart {
            DispatchQueue.main.async {
                self.activateDNSCrypt()
            }
        }
        return isAutoStart
    }
    func getExistingDNS() {
        // run "networksetup -getdnsservers Wi-Fi"
        // if return There aren't any DNS Servers set on Wi-Fi.
        // run "networksetup -getdnsservers Ethernet"
        // set existingDNS and separate the results by newLines
        
        do {
            var command = "networksetup -getdnsservers Wi-Fi"
            var logs = try helper.execute(command)
            if logs == "There aren't any DNS Servers set on Wi-Fi." {
                command = "networksetup -getdnsservers Ethernet"
                logs = try helper.execute(command)
            }
            existingDNS = logs.components(separatedBy: .newlines)
            logsString.append("Success get existing local DNS - \(existingDNS.joined(separator: ", "))")
        } catch {
            logsString.append("Failed to get existing local DNS...")
        }
    }
    private func setAppPath() {
        let applicationSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let bundleID = Bundle.main.bundleIdentifier ?? "com.example.default"
        let appSupportSubDirectory = applicationSupport.appendingPathComponent(bundleID, isDirectory: true)

        var archPath: String {
            if arch == .ARM64 {
                return "arm64"
            } else {
                return "x86_64"
            }
        }
        
        let fileURL = appSupportSubDirectory.appendingPathComponent("\(archPath)/dnscrypt-proxy")
        self.logsString.append("File Path: \(fileURL.path)")
        appPath = fileURL
        appDir = appSupportSubDirectory.appendingPathComponent("\(archPath)")
    }
    
    private func installDNSCrypt() {
        if UserDefaults.standard.string(forKey: "IsFirstInstall") == nil {
            do {
                if let appPath {
                    let safePath = "\"\(appPath.path)\"" // Quote the entire path
                    let command = "\(safePath) -service install"
                    let logs = try helper.execute(command, isSudo: true)
                    self.logsString.append(contentsOf: try helper.parseLog(logs))
                    
                    UserDefaults.standard.set(true, forKey: "IsFirstInstall")
                } else {
                    self.deactivateDNSCrypt()
                }
            } catch {
                self.deactivateDNSCrypt()
                self.logsString.append("Error: \(error.localizedDescription)")
            }
        } else {
            self.logsString.append("Service already installed.")
        }
    }
    
    // TODO: Case for reinstall & uninstall dnscrypt service
}
