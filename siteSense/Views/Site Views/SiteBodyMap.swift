//
//  BodyMap.swift
//  siteSense
//
//  Created by Hannah Adams on 3/17/24.
//

import SwiftUI

let screenWidth = UIScreen.main.bounds.size.width
let screenHeight = UIScreen.main.bounds.size.height

struct SiteBodyMap: View{
    // View Models
    @ObservedObject var siteViewModel: InsertionSiteViewModel
    @ObservedObject var settingsViewModel: UserSettingsViewModel

    // Passed from Parent View
    @Binding var zoomedIn: Bool
    @Binding var imageOffset: Double
    @Binding var selectedSideIndex: Int
    @Binding var selectedSite: InsertionSite?
    @Binding var selectedSiteType: String
    
    // Local scaling and positioning
    @State private var tapLocation: CGPoint = .zero
    @State private var scaleFactor = 1.0
    @State private var xOffset = 0.0
    @State private var yOffset = 0.0
    
    // Bools for popups and point locations
    @State private var showSiteSavePopover: Bool = false
    @State private var saveTappedSite: Bool = false
        
    var body: some View{
        // Display the image of the human body outline
        var image: String {
            switch selectedSideIndex {
            case 0: return "frontOutline"
            case 1: return "rightOutline"
            case 2: return "backOutline"
            default: return "leftOutline"
            }
        }
        
        var color: Color{
            if selectedSiteType == "Pump"{
                return settingsViewModel.pumpMarkerColor.color
            }else{
                return settingsViewModel.cgmMarkerColor.color
            }
        }
        
        var sitesArray: [InsertionSite]{
            if selectedSiteType == "Pump"{
                return siteViewModel.pumpSites
            }else{
                return siteViewModel.cgmSites
            }
        }

        GeometryReader{ geometry in
            ZStack{
                
                RoundedRectangle(cornerRadius: 15.0).fill(Color.white.opacity(zoomedIn ? 0.1 : 0.0))
                ZStack {
                    Image(image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                }.clipped()
                    .onTapGesture { location in
                        tapLocation = location // Store tap location
                        print(tapLocation)
                        if zoomedIn{
                            showSiteSavePopover = true
                        }
                    }
                
                // Display all selected sites
                if zoomedIn{
                    ForEach(Array(sitesArray.enumerated()), id: \.element.timestamp) { index, site in
                        let i = sitesArray.count -  index
                        let opacity = opacityOutput(array: sitesArray, index: i)
                        if site.side == image{
                                Button {
                                    //                                showSiteDetailsPopover.toggle()
                                } label: {
                                    ZStack {
                                        Circle()
                                            .fill((site == selectedSite) ? Color.orange : color.opacity(opacity))
                                            .frame(width: 20, height: 20)
                                        Text("\(i)")
                                            .font(.caption)
                                    }
                                }.onAppear{
                                    print(index)
                                }
                                .position(x: site.x * scaleFactor, y: site.y * scaleFactor)
                                .onChange(of: zoomedIn) { _, _ in
                                    let newPoint = CGPoint(x: site.x * scaleFactor, y: site.y * scaleFactor)
                                    let origPoint = CGPoint(x: site.x, y: site.y)
                                    print("Saved Position: \(origPoint), Scaled Position: \(newPoint)")
                                }
//                            }
                        }
                        Circle().fill(Color.clear).onAppear{
                            print(index)
                        }
                    }
                }
                
                // Show last site for both with turning interaction and icons
                GeometryReader{ geometry2 in
                    if !zoomedIn{
                        if settingsViewModel.pumpType != "None"{
                            if let lastPumpSite = siteViewModel.pumpSites.last{
                                let (position, marker) = siteToPosition(site: lastPumpSite, currentSide: image, geometry: geometry2)
                                Button{
                                    selectedSideIndex = rotateToSite(currentSide: selectedSideIndex, marker: marker)
                                }label:{
                                    ZStack{
                                        Image(systemName:marker).resizable().frame(width:20, height: 20)
                                    }
                                }.foregroundStyle(settingsViewModel.pumpMarkerColor.color).frame(width: 40, height: 40).position(x: position.x, y: position.y)
                            }
                        }
                        if settingsViewModel.cgmType != "None"{
                            if let lastCGMSite = siteViewModel.cgmSites.last{
                                let (position, marker) = siteToPosition(site: lastCGMSite, currentSide: image, geometry: geometry2)
                                Button{
                                    selectedSideIndex = rotateToSite(currentSide: selectedSideIndex, marker: marker)
                                }label:{
                                    ZStack{
                                        Image(systemName:marker).resizable().frame(width:20, height: 20)
                                    }
                                }.foregroundStyle(settingsViewModel.cgmMarkerColor.color).frame(width: 20, height: 20).position(x: position.x, y: position.y)
                            }
                        }
                        
                    }
                }
                
                // For saving tapped site location popup
                ZStack{
                    SiteSavePopup(showSiteSavePopover: $showSiteSavePopover, saveTappedSite: $saveTappedSite)
                }.frame(width: 15, height: 15)
                    .position(x: tapLocation.x, y: tapLocation.y)

            }
            .frame(width: geometry.size.width * scaleFactor, height: geometry.size.height * scaleFactor)
                .offset(x: xOffset, y: yOffset + imageOffset)
                .animation(.easeInOut, value: zoomedIn)
                .animation(.easeInOut, value: imageOffset)
                .onAppear{
                    // Show last site front facing
                    if let lastSite = siteViewModel.pumpSites.last{
                        if lastSite.side != image{
                            if lastSite.side == "frontOutline"{
                                selectedSideIndex = 0
                            }else if lastSite.side == "rightOutline"{
                                selectedSideIndex = 1
                            }else if lastSite.side == "backOutline"{
                                selectedSideIndex = 2
                            }else{
                                selectedSideIndex = 3
                            }
                        }
                    }else{
                        selectedSideIndex = 0
                    }
                    saveImageSize(size: geometry.size)
                }
                .onChange(of: zoomedIn) { _, newValue in
                    // Change zooming and scaling factors
                    withAnimation {
                        if zoomedIn {
                            scaleFactor = 2.0
                            xOffset = (geometry.size.width * (scaleFactor - 1))*(-0.5)
                            yOffset = geometry.size.height * (-0.5)
                            imageOffset = 50.0
                        } else {
                            scaleFactor = 1.0
                            xOffset = 0.0
                            yOffset = 0.0
                            imageOffset = 0.0
                            showSiteSavePopover = false
                        }
                    }
                }
                .onChange(of: saveTappedSite) { _, _ in
                    // Save current tapped site when popup confirmed
                    if saveTappedSite{
                        let point = CGPoint(x: (tapLocation.x) / scaleFactor, y: (tapLocation.y) / scaleFactor)
                        print("SAVING POINT: ", tapLocation, point)
                        siteViewModel.addInsertionSite(position: point, side: image, type: selectedSiteType)
                        saveTappedSite = false
                        showSiteSavePopover = false
                    }
                }
                .onChange(of: selectedSite){_,_ in
                    // Automatically switch to display that selected Site
                    if selectedSite != nil{
                        // Switch side shown to display selected point
                        if selectedSite!.side != image{
                            if selectedSite!.side == "frontOutline"{
                                selectedSideIndex = 0
                            }else if selectedSite!.side == "rightOutline"{
                                selectedSideIndex = 1
                            }else if selectedSite!.side == "backOutline"{
                                selectedSideIndex = 2
                            }else{
                                selectedSideIndex = 3
                            }
                        }
                        // Shift image to show point if outside bounds of view (+padding)
                            let centeredOffset = (geometry.size.height*scaleFactor*0.5) - (selectedSite!.y*scaleFactor)
                            if abs(imageOffset-centeredOffset)>(geometry.size.width/3){
                                imageOffset = centeredOffset
                            }
                    }
                }
        }
    }
    
    // Function to save the size to UserDefaults
    private func saveImageSize(size: CGSize) {
        let defaults = UserDefaults(suiteName: "group.hannah.siteSense")
        defaults?.set("\(size.width),\(size.height)", forKey: "ImageSize") // Save width and height as a string
    }
    
    // Switch to next image based on left/right arrow
    func rotateToSite(currentSide: Int, marker: String) -> Int{
        if marker == "arrow.left.circle"{
            return (currentSide + 1) % 4
        }else if marker == "arrow.right.circle"{
            return (currentSide + 3) % 4
        }else if marker == "arrow.down.left.circle" || marker == "arrow.down.right.circle"{
            return (currentSide + 2) % 4
        }
        return currentSide
    }
    
    // Convert most recent sites to icons around body depending on displayed side
    func siteToPosition(site: InsertionSite, currentSide: String, geometry: GeometryProxy) -> (CGPoint, String){
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
        
        let sitePosition = CGPoint(x: site.x, y: site.y)
        
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
