//
//  ColorChoice.swift
//  siteSense
//
//  Created by Hannah Adams on 4/3/24.
//

import Foundation
import SwiftUI

// Color Choice item for settings pump/cgm marker selection
enum ColorChoice: String, CaseIterable, Identifiable {
    case red = "Red"
    case orange = "Orange"
    case yellow = "Yellow"
    case green = "Green"
    case blue = "Blue"
    case purple = "Purple"
    
    var id: String { self.rawValue }
    
    var color: Color {
        switch self {
        case .red: return Color.red
        case .orange: return Color.orange
        case .yellow: return Color.yellow
        case .green: return Color.green
        case .blue: return Color.blue
        case .purple: return Color.purple
        }
    }
}
