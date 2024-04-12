//
//  SiteInteractionView.swift
//  siteSense
//
//  Created by Hannah Adams on 3/17/24.
//

import SwiftUI
import CoreData

// View with Body Map and tab buttons (for moving image) + List view of current sites
struct SiteInteractionView: View {
    // View Models
    @ObservedObject var siteViewModel: InsertionSiteViewModel
    @ObservedObject var settingsViewModel: UserSettingsViewModel
    
    // Passed from Parent View
    @Binding var zoomedIn: Bool
    @Binding var selectedSiteType: String
    
    // Passed to BodyMap
    @State private var selectedSideIndex: Int =  0
    @State private var imageOffset: Double = 0.0
    
    @State private var selectedSite: InsertionSite? = nil
    
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        return formatter
    }
    
    var body: some View {
        
        // Variables to shift BodyMap frame on zoom
        let rightButtonSpacing: CGFloat = zoomedIn ? 25.0 : 0.0
        let bottomButtonSpacing: CGFloat = zoomedIn ? 25.0 : 0.0
        
        // Based on menu selection in SitePlacementView
        var sitesArray: [InsertionSite]{
            if selectedSiteType == "Pump"{
                return siteViewModel.pumpSites
            }else{
                return siteViewModel.cgmSites
            }
        }
        
        var color: Color{
            if selectedSiteType == "Pump"{
                return Color.blue
            }else{
                return Color.green
            }
        }

        
        GeometryReader { geometry in
            VStack {
                
                HStack{
                    // Body Map
                    ZStack{
                        
                        SiteBodyMap(siteViewModel: siteViewModel, settingsViewModel: settingsViewModel,zoomedIn: $zoomedIn, imageOffset: $imageOffset, selectedSideIndex: $selectedSideIndex, selectedSite: $selectedSite, selectedSiteType: $selectedSiteType)
                            .frame(width: geometry.size.width, height:  geometry.size.height)
                            .contentShape(Rectangle())
                        
                        
                    }
                    .frame(width: geometry.size.width - rightButtonSpacing, height: zoomedIn ? geometry.size.width - bottomButtonSpacing : geometry.size.height - bottomButtonSpacing)
                    .mask {
                        RoundedRectangle(cornerRadius: 15.0)
                            .frame(width: geometry.size.width - rightButtonSpacing, height: zoomedIn ? geometry.size.width - bottomButtonSpacing : geometry.size.height - bottomButtonSpacing)
                            .shadow(radius:15.0)
                    }
                    .contentShape(Rectangle())
                    
                    // Image Shift (up/down) buttons
                    if zoomedIn{
                        VStack{
                            Button{
                                if imageOffset+50 <= geometry.size.width*0.80{
                                    imageOffset += 50
                                }
                            }label:{
                                Image(systemName: "chevron.up")
                            }
                            Spacer()
                            Button{
                                if imageOffset-50 >= -geometry.size.width*0.25{
                                    imageOffset -= 50
                                }
                            }label:{
                                Image(systemName: "chevron.down")
                            }
                        }.padding().frame(width:rightButtonSpacing)
                    }
                }
                
                
                // Body Turn (left/right) buttons
                HStack{
                    Button{
                        selectedSideIndex = (selectedSideIndex + 3) % 4
                        print(selectedSideIndex)
                    }label:{
                        Image(systemName: "chevron.left")
                    }
                    Spacer()
                    if zoomedIn{
                        Toggle("Show Shutoff Areas", isOn: .constant(true)).tint(Color.gray)
                    }
                    Spacer()
                    Button{
                        selectedSideIndex = (selectedSideIndex + 1) % 4
                        print(selectedSideIndex)
                    }label:{
                        Image(systemName: "chevron.right")
                    }
                }.padding().padding(.trailing, rightButtonSpacing).frame(height:bottomButtonSpacing)
                
                // Site List
                if zoomedIn{
                    NavigationView{
                        ListItemView(siteViewModel: siteViewModel, settingsViewModel: settingsViewModel, sitesArray: sitesArray, selectedSite: $selectedSite)
                    }
                            .clipShape(RoundedRectangle(cornerRadius: 15.0))
                            .shadow(color: (selectedSiteType == "Pump") ? settingsViewModel.pumpMarkerColor.color : settingsViewModel.cgmMarkerColor.color, radius: 5)
                            .padding()
                }
                
            }.animation(.easeInOut, value: zoomedIn)
        }
        .onAppear{
            siteViewModel.fetchInsertionSites()
        }
    }
    
}

