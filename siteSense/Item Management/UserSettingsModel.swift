//
//  UserSettingsModel.swift
//  siteSense
//
//  Created by Hannah Adams on 3/18/24.
//

import SwiftUI
import Combine
import WidgetKit

class UserSettingsViewModel: ObservableObject {
    
    // Pump Settings
    @AppStorage("pumpType", store: UserDefaults(suiteName: "group.hannah.siteSense")!) var pumpType: String = "Tandem"
    @AppStorage("pumpEnabled", store: UserDefaults(suiteName: "group.hannah.siteSense")!) var pumpEnabled: Bool = true
    @AppStorage("pumpShutoffRegionsEnabled", store: UserDefaults(suiteName: "group.hannah.siteSense")!) var pumpShutoffRegionsEnabled: Bool = true
    @AppStorage("pumpMarkerColor", store: UserDefaults(suiteName: "group.hannah.siteSense")!) var pumpMarkerColor: ColorChoice = .blue
    @AppStorage("pumpSiteChangeTimeline", store: UserDefaults(suiteName: "group.hannah.siteSense")!) var pumpSiteChangeTimeline: Int = 2
    
    // CGM Settings
    @AppStorage("cgmType", store: UserDefaults(suiteName: "group.hannah.siteSense")!) var cgmType: String = "Dexcom"
    @AppStorage("cgmEnabled", store: UserDefaults(suiteName: "group.hannah.siteSense")!) var cgmEnabled: Bool = true
    @AppStorage("cgmShutoffRegionsEnabled", store: UserDefaults(suiteName: "group.hannah.siteSense")!) var cgmShutoffRegionsEnabled: Bool = true
    @AppStorage("cgmMarkerColor", store: UserDefaults(suiteName: "group.hannah.siteSense")!) var cgmMarkerColor: ColorChoice = .green
    @AppStorage("cgmSiteChangeTimeline", store: UserDefaults(suiteName: "group.hannah.siteSense")!) var cgmSiteChangeTimeline: Int = 10
    
    // App Settings
    @AppStorage("mainMode", store: UserDefaults(suiteName: "group.hannah.siteSense")!) var mainMode: ModeChoice = .system
    @AppStorage("widgetMode", store: UserDefaults(suiteName: "group.hannah.siteSense")!) var widgetMode: ModeChoice = .system
}

