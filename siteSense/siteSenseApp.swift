//
//  siteSenseApp.swift
//  siteSense
//
//  Created by Hannah Adams on 3/14/24.
//

import SwiftUI

@main
struct siteSenseApp: App {
    let persistenceController = PersistenceController.shared
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .defaultAppStorage(UserDefaults(suiteName: "group.hannah.siteSense")!)
        }
    }
}
