//
//  BaseService.swift
//  DnsCrypt-mac
//
//  Created by Ariesta Agung on 09/03/25.
//

import Foundation
import Combine

// MARK: - Uncomment if want to use auto download for latest DNSCrypt release - UNTESTED -
class BaseService: ObservableObject {
    static let shared = BaseService()
    
    
//
//    
//    struct GitHubRelease: Codable {
//        let tag_name: String
//        let assets: [GitHubAsset]
//    }
//    
//    struct GitHubAsset: Codable {
//        let browser_download_url: String
//    }
//    
//    @Published var latestVersion: String = ""
//    @Published var isDownloading = false
//    @Published var downloadStatus: String = "Idle"
//    private var cancellables = Set<AnyCancellable>()
//    private let helper = Helper.shared
//    
//    func fetchLatestRelease(repo: String) {
//        guard let url = URL(string: "https://api.github.com/repos/\(repo)/releases/latest") else { return }
//        
//        URLSession.shared.dataTaskPublisher(for: url)
//            .map { $0.data }
//            .decode(type: GitHubRelease.self, decoder: JSONDecoder())
//            .receive(on: DispatchQueue.main)
//            .sink(receiveCompletion: { _ in }, receiveValue: { release in
//                self.latestVersion = release.tag_name
//                self.downloadStatus = "Found release \(release.tag_name)"
//                if let asset = release.assets.first {
//                    self.downloadAsset(from: asset.browser_download_url)
//                }
//            })
//            .store(in: &cancellables)
//    }
//
//    func downloadAsset(from urlString: String) {
//        guard let url = URL(string: urlString) else { return }
//        isDownloading = true
//        DispatchQueue.main.async {
//            self.downloadStatus = "Downloading..."
//        }
//        
//        let destinationURL = FileManager.default.temporaryDirectory.appendingPathComponent(url.lastPathComponent)
//        
//        URLSession.shared.downloadTask(with: url) { [weak self] tempURL, response, error in
//            guard let self = self else { return }
//            
//            if let error = error {
//                DispatchQueue.main.async {
//                    self.downloadStatus = "Download error: \(error.localizedDescription)"
//                    self.isDownloading = false
//                }
//                return
//            }
//            
//            guard let tempURL = tempURL else {
//                DispatchQueue.main.async {
//                    self.downloadStatus = "Download failed"
//                    self.isDownloading = false
//                }
//                return
//            }
//            
//            do {
//                try FileManager.default.moveItem(at: tempURL, to: destinationURL)
//                DispatchQueue.main.async {
//                    self.downloadStatus = "Download complete. Unzipping..."
//                }
//                
//                self.helper.unzipFile(at: destinationURL) { [weak self] result in
//                    guard let self = self else { return }
//                    
//                        switch result {
//                        case .success(let destinationURL):
//                            self.downloadStatus = "Unzip successful"
//                            self.helper.accessFile(in: destinationURL, fileName: "dnscrypt-proxy") { fileResult in
//                                DispatchQueue.main.async {
//                                    switch fileResult {
//                                    case .success(let content):
//                                        self.downloadStatus = "File content: \(content)"
//                                    case .failure(let error):
//                                        self.downloadStatus = "Failed to read file: \(error.localizedDescription)"
//                                    }
//                                }
//                            }
//                        case .failure(let error):
//                            self.downloadStatus = "Unzip error: \(error.localizedDescription)"
//                        }
//                    
//                }
//            } catch {
//                DispatchQueue.main.async {
//                    self.downloadStatus = "Download error: \(error.localizedDescription)"
//                }
//            }
//            
//            DispatchQueue.main.async {
//                self.isDownloading = false
//            }
//        }.resume()
//    }
//
}


