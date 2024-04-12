//
//  AppIntent.swift
//  siteSenseWidget
//
//  Created by Hannah Adams on 3/27/24.
//

import WidgetKit
import AppIntents


struct ConfigurationAppIntent: WidgetConfigurationIntent{
    static var title: LocalizedStringResource = "Site Changes"
    static var description = IntentDescription("See your upcoming site changes and current sites.")
}
