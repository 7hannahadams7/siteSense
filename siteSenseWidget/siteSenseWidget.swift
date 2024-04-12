//
//  siteSenseWidget.swift
//  siteSenseWidget
//
//  Created by Hannah Adams on 3/27/24.
//

import WidgetKit
import SwiftUI
import CoreData
import Combine

struct Provider: AppIntentTimelineProvider {
    
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), lastPumpSite: nil, lastCGMSite: nil, pumpType: "None", cgmType: "None", pumpSiteChangeTimeline: 2, cgmSiteChangeTimeline: 10, pumpMarkerColor: .blue, cgmMarkerColor: .green)
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        SimpleEntry(date: Date(), lastPumpSite: nil, lastCGMSite: nil, pumpType: "None", cgmType: "None", pumpSiteChangeTimeline: 2, cgmSiteChangeTimeline: 10, pumpMarkerColor: .blue, cgmMarkerColor: .green)
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        var entry = SimpleEntry(date: Date(), lastPumpSite: nil, lastCGMSite: nil, pumpType: "None", cgmType: "None", pumpSiteChangeTimeline: 2, cgmSiteChangeTimeline: 10, pumpMarkerColor: .blue, cgmMarkerColor: .green)
        do {
            let (pumpSite, cgmSite, pumpType, cgmType, pumpSiteChangeTimeline, cgmSiteChangeTimeline, pumpMarkerColor, cgmMarkerColor) = try getData()
            entry = SimpleEntry(date: Date(), lastPumpSite: pumpSite, lastCGMSite: cgmSite, pumpType: pumpType, cgmType: cgmType, pumpSiteChangeTimeline: pumpSiteChangeTimeline, cgmSiteChangeTimeline: cgmSiteChangeTimeline, pumpMarkerColor: pumpMarkerColor, cgmMarkerColor: cgmMarkerColor)
        }catch{
            print(error)
        }
        let timeline = Timeline(entries: [entry], policy: .atEnd)
        return timeline
    }
    
    private func getData() throws -> (InsertionSite?, InsertionSite?, String, String, Int, Int, ColorChoice, ColorChoice) {
        var pumpSites: [InsertionSite] = []
        var cgmSites: [InsertionSite] = []
        let context = PersistenceController.shared.container.viewContext
        let fetchRequest: NSFetchRequest<InsertionSite> = InsertionSite.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: true)]
        do {
            let allSites = try context.fetch(fetchRequest)
            for site in allSites {
                if site.type == "Pump" {
                    pumpSites.append(site)
                } else {
                    cgmSites.append(site)
                }
            }
        } catch {
            print("Failed to fetch insertion sites: \(error.localizedDescription)")
        }
        
        let defaults = UserDefaults(suiteName: "group.hannah.siteSense")
        let pumpType = defaults?.string(forKey: "pumpType") ?? "None"
        let cgmType = defaults?.string(forKey: "cgmType") ?? "None"
        let pumpSiteChangeTimeline = defaults?.integer(forKey: "pumpSiteChangeTimeline") ?? 0
        let cgmSiteChangeTimeline = defaults?.integer(forKey: "cgmSiteChangeTimeline") ?? 0
        let pumpMarkerColor = ColorChoice(rawValue: defaults?.string(forKey: "pumpMarkerColor") ?? "") ?? .blue
        let cgmMarkerColor = ColorChoice(rawValue: defaults?.string(forKey: "cgmMarkerColor") ?? "") ?? .green
        
        return (pumpSites.last, cgmSites.last, pumpType, cgmType, pumpSiteChangeTimeline, cgmSiteChangeTimeline, pumpMarkerColor, cgmMarkerColor)
    }


}

struct SimpleEntry: TimelineEntry {
    var date: Date
    let lastPumpSite: InsertionSite?
    let lastCGMSite: InsertionSite?
    let pumpType: String
    let cgmType: String
    let pumpSiteChangeTimeline: Int
    let cgmSiteChangeTimeline: Int
    let pumpMarkerColor: ColorChoice
    let cgmMarkerColor: ColorChoice
}

struct siteSenseWidgetEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var widgetFamily
    @Environment(\.colorScheme) var colorScheme


    var body: some View {
        switch widgetFamily {
        case .systemSmall:
            SmallWidgetContentView(entry: entry)
        case .systemMedium:
            MediumWidgetContentView(entry: entry)
//        case .systemLarge:
//            LargeWidgetContentView(entry: entry)
        @unknown default:
            Text("Unknown widget size")
        }
    }
}

struct LargeWidgetContentView: View{
    var entry: Provider.Entry
    
    @State var proportionalFrameWidth: Double = 0.0
    
    var body: some View{
        HStack{
            VStack{
                NextSideChangesView(entry: entry)
                NextSideChangesView(entry: entry)
            }
            GeometryReader{geometry in
                HStack(alignment:.center){
                    ZStack{
                        GeometryReader{geometry2 in
                            VStack(alignment:.center){
                                MiniBodyMap(entry: entry)
                                    .frame(width: proportionalFrameWidth, height: geometry2.size.height)
                                    .onAppear{
                                        proportionalFrameWidth = getProportionalWidth(newHeight: geometry2.size.height)
                                    }
                            }.frame(width:geometry2.size.width, height:geometry2.size.height)
                        }
                    }.frame(width:geometry.size.width, height:geometry.size.height*0.75)
                }.frame(width:geometry.size.width, height:geometry.size.height)
            }
        }
    }
}

struct MediumWidgetContentView: View{
    var entry: Provider.Entry
    
    @State var proportionalFrameWidth: Double = 0.0
    
    var body: some View{
        HStack{
            NextSideChangesView(entry: entry)
            GeometryReader{geometry in
                VStack(alignment:.center){
                    MiniBodyMap(entry: entry)
                        .frame(width: proportionalFrameWidth, height: geometry.size.height)
                        .onAppear{
                            proportionalFrameWidth = getProportionalWidth(newHeight: geometry.size.height)
                        }
                }.frame(width:geometry.size.width,height:geometry.size.height)
            }
        }
    }
    
}

func getProportionalWidth(newHeight: CGFloat) -> Double{
    var proportionalWidth: Double = newHeight
    let defaults = UserDefaults(suiteName: "group.hannah.siteSense")
    if let imageSizeString = defaults?.string(forKey: "ImageSize") {
        // Parse the retrieved string to get the width and height values
        let imageSizeComponents = imageSizeString.split(separator: ",")
        if imageSizeComponents.count == 2,
           let widthString = imageSizeComponents.first,
           let heightString = imageSizeComponents.last,
           let width = Double(widthString),
           let height = Double(heightString) {

            let origProportion = Double(width/height)

            proportionalWidth = newHeight * origProportion
            
        }
    }

    return proportionalWidth
}

struct SmallWidgetContentView : View {
    var entry: Provider.Entry

    var body: some View {
        NextSideChangesView(entry: entry)
    }

}

struct MiniBodyMap: View{
    var entry: Provider.Entry
    
    @State var proportionalFrameWidth: Double = 0.0
    
    var body: some View{
        GeometryReader{geometry in
            ZStack{
                Image("frontOutline")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                GeometryReader{geometry2 in
                    if entry.pumpType != "None"{
                        if let lastPumpSite = entry.lastPumpSite{
                            let (position, marker) = siteToConvertedPosition(site: lastPumpSite, currentSide: "frontOutline", geometry: geometry2)
                            Image(systemName:marker)
                                .resizable()
                                .frame(width:geometry.size.height/20,height:geometry.size.height/20)
                                .foregroundColor(entry.pumpMarkerColor.color)
                                .position(x: position.x, y: position.y)
                        }
                    }
                    if entry.cgmType != "None"{
                        if let lastCGMSite = entry.lastCGMSite{
                            let (position, marker) = siteToConvertedPosition(site: lastCGMSite, currentSide: "frontOutline", geometry: geometry2)
                            Image(systemName:marker)
                                .resizable()
                                .frame(width:geometry.size.height/20,height:geometry.size.height/20)
                                .foregroundColor(entry.cgmMarkerColor.color)
                                .position(x: position.x, y: position.y)
                        }
                    }
                }
            }.onAppear{
                proportionalFrameWidth = getProportionalWidth(newHeight: geometry.size.height)
            }.frame(width: proportionalFrameWidth, height: geometry.size.height)
        }
    }
                                
    func getConvertedPositions(x: Double, y: Double, newHeight: CGFloat) -> (Double, Double) {
        // Given the insertion site position, convert the position to match (image is limited in height by .fit modifier)
        var newX: Double = x
        var newY: Double = y
        
        let defaults = UserDefaults(suiteName: "group.hannah.siteSense")
        if let imageSizeString = defaults?.string(forKey: "ImageSize") {
            // Parse the retrieved string to get the width and height values
            let imageSizeComponents = imageSizeString.split(separator: ",")
            if imageSizeComponents.count == 2,
//               let widthString = imageSizeComponents.first,
               let heightString = imageSizeComponents.last,
//               let width = Double(widthString),
               let height = Double(heightString) {
                
                // Calculate scaling factor
                let scaleY = Double(newHeight) / height
                
                // Convert coordinates and width using scaling factors
                newX = x * scaleY
                newY = y * scaleY
                
            }
        }
        return (newX, newY)
    }
    
    func siteToConvertedPosition(site: InsertionSite, currentSide: String, geometry: GeometryProxy) -> (CGPoint, String){
        let sideMapping: [String:Int] = [
            "frontOutline": 0,
            "rightOutline": 1,
            "backOutline": 2,
            "leftOutline": 3
        ]
        
        let siteSide = sideMapping[site.side!]!
        let shownSide = sideMapping[currentSide]!
        
        var diff = (shownSide - siteSide) % 4 // Handle wraparound
        
        if diff < 0 {
            diff += 4 // Ensure positive result
        }
        
        let (convertedX, convertedY) = getConvertedPositions(x: site.x, y: site.y, newHeight: geometry.size.height)
        let sitePosition = CGPoint(x: convertedX, y: convertedY)
        
        // Change shift for side views because smaller frame
        let shift: CGFloat = (shownSide == 1 || shownSide == 3) ? geometry.size.height/10 : geometry.size.height/6
        
        switch diff {
        case 0:
            // Point is on the current side
            return (sitePosition, "circle.fill")
        case 1:
            // Point is one frame left
            let offsetPoint = CGPoint(x: geometry.size.width/2 - shift, y: sitePosition.y)
            return (offsetPoint, "arrow.right.circle")
        case 3:
            // Point is one frame right
            let offsetPoint = CGPoint(x: geometry.size.width/2 + shift, y: sitePosition.y)
            return (offsetPoint, "arrow.left.circle")
        case 2:
            // Point is opposite (two frames away)
            let backSideOffset = (site.type == "Pump") ? 0.0 : -geometry.size.height/14
            if shownSide == 1{
                let offsetPoint = CGPoint(x: geometry.size.width/2 - geometry.size.height/14, y: geometry.size.height/10 + backSideOffset)
                return (offsetPoint, "arrow.down.right.circle")
            }else{
                let offsetPoint = CGPoint(x: geometry.size.width/2 +  geometry.size.height/14, y: geometry.size.height/10 + backSideOffset)
                return (offsetPoint, "arrow.down.left.circle")
            }
        default:
            return (.zero, "circle.fill")
        }
        
    }
    
}

struct NextSideChangesView: View{
    var entry: Provider.Entry
    
    var body: some View{
        VStack(alignment:.leading){
            Text("Next Site Changes:")
                .font(.body)
                .bold()
                .lineLimit(1) // Ensure text doesn't wrap
                .minimumScaleFactor(0.5) // Adjust as needed
            if entry.pumpType != "None"{
                if let lastPumpSite = entry.lastPumpSite {
                    let pumpDaysRemaining = calculateDaysRemaining(lastSiteTimestamp: lastPumpSite.timestamp, siteChangeTimeline: entry.pumpSiteChangeTimeline)
                    VStack{
                        ZStack{
                            RoundedRectangle(cornerRadius: 5.0)
                                .fill(entry.pumpMarkerColor.color.opacity(0.5))
                            Text("\(entry.pumpType): \(pumpDaysRemaining)")
                                .font(.body)
                                .lineLimit(1)
                                .minimumScaleFactor(0.75) // Adjust as needed
                                .foregroundColor(.primary)
                                .padding(5)
                        }
                        DaysRemainingBar(entry: entry, site: lastPumpSite)
                    }
                }
            }
            if entry.cgmType != "None"{
                if let lastCGMSite = entry.lastCGMSite{
                    let cgmDaysRemaining = calculateDaysRemaining(lastSiteTimestamp: lastCGMSite.timestamp, siteChangeTimeline: entry.cgmSiteChangeTimeline)
                    VStack{
                        ZStack{
                            RoundedRectangle(cornerRadius: 5.0)
                                .fill(entry.cgmMarkerColor.color.opacity(0.5))
                            Text("\(entry.cgmType): \(cgmDaysRemaining)")
                                .font(.body)
                                .lineLimit(1)
                                .minimumScaleFactor(0.75) // Adjust as needed
                                .foregroundColor(.primary)
                                .padding(5)
                        }
                        DaysRemainingBar(entry: entry, site: lastCGMSite)
                    }
                }
            }
        }
    }
    
    func calculateDaysRemaining(lastSiteTimestamp: Date?, siteChangeTimeline: Int) -> String {
        guard let lastSiteTimestamp = lastSiteTimestamp else {
            return "Unknown"
        }
        
        let calendar = Calendar.current
        let currentDate = calendar.startOfDay(for: Date())
        let lastSiteDate = calendar.startOfDay(for: lastSiteTimestamp)
        let components = calendar.dateComponents([.day], from: lastSiteDate, to: currentDate)
        
        if let days = components.day {
            if days >= siteChangeTimeline {
                return "Today"
            } else if (siteChangeTimeline - days) == 1 {
                return "1 day"
            } else {
                return "\(siteChangeTimeline - days) days"
            }
        } else {
            return "Unknown"
        }
    }
    
}

struct DaysRemainingBar: View{
    var entry: Provider.Entry
    var site: InsertionSite
    var body: some View{
        var timeline: Int{
            if site.type == "Pump"{
                return entry.pumpSiteChangeTimeline
            }
            return entry.cgmSiteChangeTimeline
        }
        var markerColor: Color{
            if site.type == "Pump"{
                return entry.pumpMarkerColor.color
            }
            return entry.cgmMarkerColor.color
        }
        HStack{
            ForEach(0..<timeline, id:\.self){index in
                let color = getColorFromTimestamp(siteTimestamp: site.timestamp!, siteChangeTimeline: timeline, index: index, markerColor: markerColor)
                Circle().fill(color).frame(width:5, height:5)
            }
        }
    }
    
    func getColorFromTimestamp(siteTimestamp: Date, siteChangeTimeline: Int, index: Int, markerColor: Color) -> Color {
        let calendar = Calendar.current
        let currentDate = calendar.startOfDay(for: Date())
        let lastSiteDate = calendar.startOfDay(for: siteTimestamp)
        let components = calendar.dateComponents([.day], from: lastSiteDate, to: currentDate)
        
        if let days = components.day {
            let diff = siteChangeTimeline - days
            if siteChangeTimeline - 1 - index >= diff{
                return (diff <= 0 && index == siteChangeTimeline-1) ? Color.yellow : markerColor
            }else{
                return Color.gray
            }
        }
        return Color.gray
    }

}

struct siteSenseWidget: Widget {
    let kind: String = "siteSenseWidget"
    @Environment(\.colorScheme) var colorScheme

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            siteSenseWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Site Sense Widget")
        .description("Your next site changes.")
        .supportedFamilies([.systemSmall, .systemMedium/*, .systemLarge*/])
    }
}

extension ConfigurationAppIntent {
    fileprivate static var smiley: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        return intent
    }
    
    fileprivate static var starEyes: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        return intent
    }
}

