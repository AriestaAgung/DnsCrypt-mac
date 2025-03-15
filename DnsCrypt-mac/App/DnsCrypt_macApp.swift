//
//  DnsCrypt_macApp.swift
//  DnsCrypt-mac
//
//  Created by Ariesta Agung on 09/03/25.
//

import SwiftUI

@main
struct DnsCrypt_macApp: App {
    var body: some Scene {
        MenuBarExtra {
            ContentView()
                .frame(width: 350, height: 300, alignment: .center)
                .background(Color.cyan.opacity(0.2))
        } label: {
            Label("DNSCrypt Desktop", systemImage: "globe")
        }
        .menuBarExtraStyle(.window)
        
    }
}
