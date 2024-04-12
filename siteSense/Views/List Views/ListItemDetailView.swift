//
//  SiteDetailView.swift
//  siteSense
//
//  Created by Hannah Adams on 3/16/24.
//

import SwiftUI

// View with information about specific insertion site for list view
struct ListItemDetailView: View {
    @ObservedObject var settingsViewModel: UserSettingsViewModel
    var insertionSite: InsertionSite
    var index: Int
    var opacity: Double
    
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        return formatter
    }
    
    var color: Color{
        if insertionSite.type == "Pump"{
            return settingsViewModel.pumpMarkerColor.color
        }else{
            return settingsViewModel.cgmMarkerColor.color
        }
    }
    
    var daysAgoString: String {
        let calendar = Calendar.current
        let currentDate = calendar.startOfDay(for: Date())
        let lastSiteDate = calendar.startOfDay(for: insertionSite.timestamp ?? Date.now)
        let components = calendar.dateComponents([.day], from: lastSiteDate, to: currentDate)
        
        if let days = components.day {
            if days == 0 {
                return "Today"
            } else if days == 1 {
                return "1 day ago"
            } else {
                return "\(days) days ago"
            }
        } else {
            return ""
        }
    }
    
    var body: some View {
        HStack {
            ZStack {
                Circle().fill(color.opacity(opacity))
                Text("\(index)")
            }.frame(width: 40, height: 40)
            
            VStack(alignment: .leading) {
                Text("Site \(index)")
                let dateString = dateFormatter.string(from: insertionSite.timestamp ?? Date.now)
                Text(dateString).italic()
                HStack{
                    Text(sideToLabel(sideString:insertionSite.side ?? "N/A"))
                    Spacer()
                    Text(daysAgoString).italic().font(.subheadline)
                }
            }
            
            Spacer()
        }
    }
    
    func sideToLabel(sideString: String) -> String{
        if sideString == "frontOutline"{
            return "Front"
        }else if sideString == "leftOutline"{
            return "Left Side"
        }else if sideString == "rightOutline"{
            return "Right Side"
        }else if sideString == "backOutline"{
            return "Back"
        }else{
            return "N/A"
        }
    }
}
