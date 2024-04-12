//
//  EditSiteView.swift
//  siteSense
//
//  Created by Hannah Adams on 3/17/24.
//

import SwiftUI
import CoreData

// View to edit timestamp of current site, from list view
struct ListItemEditView: View {
    @ObservedObject var siteViewModel: InsertionSiteViewModel
    @ObservedObject var site: InsertionSite // Passed from the list item
    var index: Int
    @State var timestamp: Date = Date.now
    
    var body: some View {
        var daysAgoString: String {
            let calendar = Calendar.current
            let currentDate = Date()
            
            if let days = calendar.dateComponents([.day], from: timestamp, to: currentDate).day {
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
        
        VStack {
            VStack{
                Text("Site \(index)").bold()
                HStack{
                    Spacer()
                    Text(sideToLabel(sideString:site.side ?? "N/A") + " : " + daysAgoString).italic()
                    Spacer()
                }
            }.padding(5)

            VStack {
                DatePicker("", selection: $timestamp, displayedComponents: [.date,.hourAndMinute]).labelsHidden()
            }
            .padding(5)
            
            Button("Update Timestamp") {
                siteViewModel.updateTimestamp(timestamp, for: site)
            }.disabled(timestamp == site.timestamp)
            .padding(10)
            .foregroundColor(.white)
            .background((timestamp == site.timestamp) ? Color.gray : Color.blue)
            .cornerRadius(8)
        }
        .padding()
        .onAppear{
            timestamp = site.timestamp ?? Date.now
        }
    }
    
    // Create string from image site is placed on
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
