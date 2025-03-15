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
        //TODO: CREATE CHECKBOX IF IT CHECKED, DNSCRYPT MUST BE AUTO ACTIVATED. STATE CAN BE STORED ON USERDEFAULTS.STANDARD
        installDNSCrypt()
        logsString.append("DNS Active...")
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
        UserDefaults.standard.synchronize()
        print(UserDefaults.standard.bool(forKey: "isAutoStart"))
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
