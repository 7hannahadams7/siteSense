//
//  SettingsView.swift
//  siteSense
//
//  Created by Hannah Adams on 3/18/24.
//

import SwiftUI
import Combine
import WidgetKit

struct SettingsView: View {
    @ObservedObject var settingsViewModel: UserSettingsViewModel
    
    var pumpOptions: [String] = [
        "None",
        "Tandem",
        "Medtronic",
        "Other"
    ]
    var cgmOptions: [String] = [
        "None",
        "Dexcom",
        "Libre",
        "Other"
    ]

    var body: some View {
        List {
            Section("Devices"){
                Picker("Select Pump Type", selection: $settingsViewModel.pumpType) {
                    ForEach(pumpOptions, id: \.self) {
                        Text($0)
                    }
                }
                .pickerStyle(DefaultPickerStyle())
                Picker("Select CGM Type", selection: $settingsViewModel.cgmType) {
                    ForEach(cgmOptions, id: \.self) {
                        Text($0)
                    }
                }
                .pickerStyle(DefaultPickerStyle())
            }
            
            if settingsViewModel.pumpType != "None"{
                Section("\(settingsViewModel.pumpType) Settings") {
                    Picker("Site Change Timeline", selection: $settingsViewModel.pumpSiteChangeTimeline) {
                        ForEach(1..<5, id: \.self) { day in // Assuming timeline can range from 1 to 10 days
                            Text((day==1) ? "\(day) day" : "\(day) days")
                        }
                    }
                    Toggle("Enable Shutoff Sites", isOn: $settingsViewModel.pumpShutoffRegionsEnabled)
                        .tint(settingsViewModel.pumpMarkerColor.color)
                    Picker("Preferred Marker Color", selection: $settingsViewModel.pumpMarkerColor) {
                        ForEach(ColorChoice.allCases) { colorChoice in
                            Text(colorChoice.rawValue).tag(colorChoice)
                        }
                    }
                }
            }
            
            if settingsViewModel.cgmType != "None"{
                Section("\(settingsViewModel.cgmType) Settings") {
                    Picker("Site Change Timeline", selection: $settingsViewModel.cgmSiteChangeTimeline) {
                        ForEach(1..<21, id: \.self) { day in // Assuming timeline can range from 1 to 10 days
                            Text((day==1) ? "\(day) day" : "\(day) days")
                        }
                    }
                    Toggle("Enable Shutoff Sites", isOn: $settingsViewModel.cgmShutoffRegionsEnabled).tint(settingsViewModel.cgmMarkerColor.color)
                    Picker("Preferred Marker Color", selection: $settingsViewModel.cgmMarkerColor) {
                        ForEach(ColorChoice.allCases) { colorChoice in
                            Text(colorChoice.rawValue).tag(colorChoice)
                        }
                    }
                }
            }
            Section("System Settings") {
                Picker("App Dark Mode", selection: $settingsViewModel.mainMode) {
                    ForEach(ModeChoice.allCases) { modeChoice in
                        Text(modeChoice.rawValue).tag(modeChoice)
                    }
                }
                Picker("Widget Dark Mode", selection: $settingsViewModel.widgetMode) {
                    ForEach(ModeChoice.allCases) { modeChoice in
                        Text(modeChoice.rawValue).tag(modeChoice)
                    }
                }
            }
        }
        .navigationTitle("Settings")
    }
}


#Preview {
    SettingsView(settingsViewModel: UserSettingsViewModel())
}
