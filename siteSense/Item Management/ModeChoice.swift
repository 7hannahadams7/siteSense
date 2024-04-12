//
//  DarkModeChoice.swift
//  siteSense
//
//  Created by Hannah Adams on 4/5/24.
//

import Foundation
import SwiftUI

// Mode Choice for system, light, or dark mode of app
enum ModeChoice: String, CaseIterable, Identifiable {
    case system = "System"
    case light = "Light"
    case dark = "Dark"
    
    var id: String { self.rawValue }
    var scheme: ColorScheme? {
        switch self{
        case .light: return .light
        case .dark: return .dark
        case .system: return nil
        }
    }
}
