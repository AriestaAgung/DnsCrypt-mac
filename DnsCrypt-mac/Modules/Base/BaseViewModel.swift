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
    
}


class BaseViewModel: ObservableObject, BaseViewModelProtocol {
    static let shared = BaseViewModel()
    @Published var isDNSCExist: Bool = false
    @Published var currentStatus: String = "Curent Status: "
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
            self.currentStatus = .currentState + "DNSCrypt Exist!"
        } catch {
            print(error.localizedDescription)
            currentStatus = .currentState + error.localizedDescription
        }
        setAppPath()
    }
    
    private func checkAppDirectoryExists(url: URL) {
        let fileManager = FileManager.default
        let applicationSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let bundleID = Bundle.main.bundleIdentifier ?? "Company Name"
        let appSupportSubDirectory = applicationSupport.appendingPathComponent(bundleID, isDirectory: true)
        do {
            try FileManager.default.createDirectory(at: appSupportSubDirectory, withIntermediateDirectories: true, attributes: [.posixPermissions: 0o755])
        } catch {
            print("Error Create Directory: \(error.localizedDescription)")
            currentStatus = .currentState + error.localizedDescription
        }
        let destinationURL = appSupportSubDirectory.appendingPathComponent(url.lastPathComponent)
        
        do {
            let destinationURL = appSupportSubDirectory.appendingPathComponent(url.lastPathComponent)
            
            try fileManager.copyItem(at: url, to: destinationURL)
            print("File copied successfully to: \(destinationURL.path)")
        } catch {
            print("Error Move Item: \(error.localizedDescription)")
            currentStatus = .currentState + error.localizedDescription
        }
        helper.unzipFile(at: destinationURL) { result in
            switch result {
            case .success(let success):
                print(success.relativePath)
                self.currentStatus = .currentState + "Unzipped"
            case .failure(let failure):
                print(failure.localizedDescription)
                self.currentStatus = .currentState + failure.localizedDescription
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
//        self.currentStatus = .currentState + "DNS Active..."
    }
    
    func deactivateDNSCrypt() {
        self.currentStatus = .currentState + "DNS Inactive..."
    }
    
    func didToggleChange(isOn: Bool) {
        if isOn {
            activateDNSCrypt()
        } else {
            deactivateDNSCrypt()
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
        print("File Path: \(fileURL.path)")
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
                    self.currentStatus = .currentState + logs
                    UserDefaults.standard.set(true, forKey: "IsFirstInstall")
                } else {
                    self.deactivateDNSCrypt()
                }
            } catch {
                self.deactivateDNSCrypt()
                print("Error: \(error.localizedDescription)")
            }
        }
    }
}
