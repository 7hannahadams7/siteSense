//
//  PlacementView.swift
//  siteSense
//
//  Created by Hannah Adams on 3/16/24.
//

import SwiftUI

// View for full interaction of adding and placing sites
struct SitePlacementView: View {
    @ObservedObject var siteViewModel: InsertionSiteViewModel
    @ObservedObject var settingsViewModel: UserSettingsViewModel
    @State private var zoomedIn = false
    @State private var selectedSiteType = "Pump"
    @State private var selectedRegion = "Stomach"
    
    @Environment(\.colorScheme) var colorScheme
    
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        return formatter
    }
    
    var color: Color{
        if zoomedIn{
            if selectedSiteType == "Pump"{
                return settingsViewModel.pumpMarkerColor.color
            }else{
                return settingsViewModel.cgmMarkerColor.color
            }
        }else{
            if colorScheme == .dark {
                return Color.white
            }else{
                return Color.black
            }
        }
    }
    
    var body: some View{
        GeometryReader{ geometry in
            ZStack {
                
                // Interaction View
                VStack{
                    SiteInteractionView(siteViewModel:siteViewModel,settingsViewModel: settingsViewModel,zoomedIn: $zoomedIn, selectedSiteType: $selectedSiteType)
                }.padding(25).padding(.vertical, 40)
                
                // Buttons to add new sites + Current sites when zoomed out
                VStack{
                    HStack{
                            VStack(alignment:.leading){
                                Text(zoomedIn ? (selectedSiteType == "Pump") ? "\(settingsViewModel.pumpType) Sites" : "\(settingsViewModel.cgmType) Sites" : "Next Site Changes:").bold()
                                if !zoomedIn{
                                    if settingsViewModel.pumpType != "None"{
                                        if let lastPumpSite = siteViewModel.pumpSites.last {
                                            let pumpDaysRemaining = calculateDaysRemaining(lastSiteTimestamp: lastPumpSite.timestamp, siteChangeTimeline: settingsViewModel.pumpSiteChangeTimeline)
                                            HStack{
                                                Text("\(pumpDaysRemaining)").foregroundColor(.primary)
                                                Image(systemName:"circle.fill").foregroundColor(settingsViewModel.pumpMarkerColor.color)
                                                Spacer()
                                            }
                                        }
                                    }
                                    if settingsViewModel.cgmType != "None"{
                                        if let lastCGMSite = siteViewModel.cgmSites.last{
                                            let cgmDaysRemaining = calculateDaysRemaining(lastSiteTimestamp: lastCGMSite.timestamp, siteChangeTimeline: settingsViewModel.cgmSiteChangeTimeline)
                                            HStack{
                                                Text("\(cgmDaysRemaining)").foregroundColor(.primary)
                                                Image(systemName:"circle.fill").foregroundColor(settingsViewModel.cgmMarkerColor.color)
                                                Spacer()
                                            }
                                        }
                                    }
                                }
                            }
                        Spacer()
                        ZStack{
                            if zoomedIn{
                                Button{
                                    zoomedIn.toggle()
                                }label:{
                                    Image(systemName: "plus").resizable().rotationEffect(Angle(degrees: 45.0)).aspectRatio(contentMode: .fit).padding(5).frame(width:35,height:35)
                                }
                            }else{
                                if settingsViewModel.pumpType == "None" && settingsViewModel.cgmType != "None"{
                                    Button{
                                        selectedSiteType = "CGM"
                                        zoomedIn.toggle()
                                    }label:{
                                        Image(systemName: "plus").resizable().rotationEffect(Angle(degrees: 45.0)).aspectRatio(contentMode: .fit).padding(5).frame(width:35,height:35)
                                    }
                                }else if settingsViewModel.cgmType == "None" && settingsViewModel.pumpType != "None"{
                                    Button{
                                        selectedSiteType = "Pump"
                                        zoomedIn.toggle()
                                    }label:{
                                        Image(systemName: "plus").resizable().rotationEffect(Angle(degrees: 45.0)).aspectRatio(contentMode: .fit).padding(5).frame(width:35,height:35)
                                    }
                                }else{
                                    Menu{
                                        Button{
                                            zoomedIn.toggle()
                                            selectedSiteType = "Pump"
                                        }label:{
                                            Text("\(settingsViewModel.pumpType) Site")
                                        }
                                        Button{
                                            zoomedIn.toggle()
                                            selectedSiteType = "CGM"
                                        }label:{
                                            Text("\(settingsViewModel.cgmType) Site")
                                        }
                                    }label:{
                                        Image(systemName:  "plus").resizable().aspectRatio(contentMode: .fit)
                                    }
                                }
                            }
                        }.padding(5).frame(width:35,height:35)

                    }.padding()
                    Spacer()
                }.padding(10)
                    
            }.animation(.easeInOut,value: zoomedIn)
        }
    }
    
    // Convert date to days remaining string based on site change timeline
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


struct PlacementView_Previews: PreviewProvider {
    static var previews: some View {
        SitePlacementView(siteViewModel:InsertionSiteViewModel(), settingsViewModel: UserSettingsViewModel())
    }
}

