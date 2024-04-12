//
//  ContentView.swift
//  siteSense
//
//  Created by Hannah Adams on 3/14/24.
//

import SwiftUI
import CoreData

struct ContentView: View{
    @StateObject var siteViewModel = InsertionSiteViewModel()
    @StateObject var settingsViewModel = UserSettingsViewModel()
    
    @Environment(\.colorScheme) var colorScheme

    var body: some View{
        // Based on app setting of light/dark mode
        var selectedTheme: ColorScheme? {
            let appMode: ModeChoice = ModeChoice(rawValue: UserDefaults(suiteName: "group.hannah.siteSense")?.string(forKey: "mainMode") ?? "") ?? .system
            return appMode.scheme
        }
        TabView {
            SitePlacementView(siteViewModel:siteViewModel, settingsViewModel:     settingsViewModel).tabItem {
                Image(systemName: "dot.circle.and.hand.point.up.left.fill")
                Text("Sites").bold()
            }.tag(0).background(Color(UIColor.systemGray6))
            ListView(siteViewModel:siteViewModel,settingsViewModel:     settingsViewModel).tabItem {
                Image(systemName: "list.bullet")
                Text("History").bold()
            }.tag(1).background(Color(UIColor.systemGray6))
            SettingsView(settingsViewModel:     settingsViewModel).tabItem {
                Image(systemName: "gearshape.2")
                Text("Settings").bold()
            }.tag(1).background(Color(UIColor.systemGray6))            
        }
        .background(Color(UIColor.systemGray6))
        .accentColor((colorScheme == .dark) ? .white : .black)
        .preferredColorScheme(selectedTheme)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
         ContentView()
    }
}
