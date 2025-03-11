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
    
    var body: some View {
        VStack {
            Toggle("Service Status", isOn: $isOnStatus)
                .toggleStyle(.switch)
                .disabled(isDisabledStatus == true)
                .tint(.cyan)
        }
        .padding()
        .onAppear {
            BaseViewModel().checkDNSCryptExistance()
        }
    }
}

#Preview {
    ContentView()
        .frame(width: 300, height: 400)
}
