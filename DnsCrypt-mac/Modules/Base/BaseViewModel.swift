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
    
    @Published var isDNSCExist: Bool = false
    private let service = BaseService.shared
    private let arch: CPUArchType = Helper.shared.getCPUArchitecture()
//    @Published var currentStatus: String = "Curent Status: "
    
    
    func checkDNSCryptExistance() {
//        currentStatus.append(" \(service.$downloadStatus)")
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
        } catch {
            print(error.localizedDescription)
        }
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
        }
        let destinationURL = appSupportSubDirectory.appendingPathComponent(url.lastPathComponent)
        
        do {
            let destinationURL = appSupportSubDirectory.appendingPathComponent(url.lastPathComponent)
            
            try fileManager.copyItem(at: url, to: destinationURL)
            print("File copied successfully to: \(destinationURL.path)")
        } catch {
            print("Error Move Item: \(error.localizedDescription)")
        }
        Helper.shared.unzipFile(at: destinationURL) { result in
            switch result {
            case .success(let success):
                print(success.relativePath)
            case .failure(let failure):
                print(failure.localizedDescription)
            }
        }
    }
    
    func checkLatestDNSCryptRelease() {
        
    }
    
    func downloadLatestDNSCrypt() {
    
    }
    
    func activateDNSCrypt() {
        
    }
    
    func deactivateDNSCrypt() {
        
    }
    
    func didToggleChange(isOn: Bool) {
        if isOn {
            activateDNSCrypt()
        } else {
            deactivateDNSCrypt()
        }
    }
    
}
