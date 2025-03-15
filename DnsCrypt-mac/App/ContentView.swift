//
//  ContentView.swift
//  DnsCrypt-mac
//
//  Created by Ariesta Agung on 09/03/25.
//

import SwiftUI

struct ContentView: View {
    @State private var isOnStatus: Bool = false
    @AppStorage("isAutoStart") private var isAutoStart: Bool = false
    @State private var isDisabledStatus: Bool = false
    @ObservedObject private var viewModel = BaseViewModel.shared
    @State private var logText: String = ""
    init() {
        viewModel.checkDNSCryptExistance()
        _isOnStatus = State(initialValue: viewModel.getIsAutoStart())
    }
    var body: some View {
        VStack {
            Toggle("Service Status", isOn: $isOnStatus)
                .onChange(of: isOnStatus) { status in
                    viewModel.didToggleChange(isOn: status)
                }
                .toggleStyle(.switch)
                .disabled(isDisabledStatus == true)
                .tint(.cyan)
            Toggle(isOn: $isAutoStart) {
                Text("Auto Start Service")
            }
            .onChange(of: isAutoStart) { status in
                viewModel.setAutoStart(isAutoStart: status)
            }
            TextEditor(text: .constant(viewModel.logsString.joined(separator: "\n")))
                .scrollIndicators(.hidden)
                .padding(5)
                .background(Color.clear)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray, lineWidth: 1)
                )
                .cornerRadius(12)
            Button("Quit") {
                viewModel.deactivateDNSCrypt()
                NSApplication.shared.terminate(nil) // Quit app
            }
            .keyboardShortcut("q", modifiers: .command)
            
        }
        .padding()
        
        
    }
}

#Preview {
    ContentView()
    //        .frame(width: 300, height: 400)
}
