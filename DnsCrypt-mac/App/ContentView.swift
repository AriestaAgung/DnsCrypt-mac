//
//  ContentView.swift
//  DnsCrypt-mac
//
//  Created by Ariesta Agung on 09/03/25.
//

import SwiftUI

struct ContentView: View {
    @State private var isOnStatus: Bool = false
    @State private  var isDisabledStatus: Bool = false
    @ObservedObject private var viewModel = BaseViewModel.shared
    init() {
        viewModel.checkDNSCryptExistance()
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
            
            Text(viewModel.currentStatus)
        }
        .padding()
        
        
    }
}

#Preview {
    ContentView()
        .frame(width: 300, height: 400)
}
