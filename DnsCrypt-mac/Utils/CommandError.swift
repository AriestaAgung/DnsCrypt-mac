//
//  CommandError.swift
//  DnsCrypt-mac
//
//  Created by Ariesta Agung on 13/03/25.
//

import Foundation
enum CommandError: Error {
    case invalidData
    case commandFailed(String)
    case emptyOutput
}
