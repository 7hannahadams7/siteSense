//
//  SiteListView.swift
//  siteSense
//
//  Created by Hannah Adams on 3/17/24.
//

import SwiftUI

// View with SiteDetailView instances of each site shown
struct ListView: View {
    @ObservedObject var siteViewModel: InsertionSiteViewModel
    @ObservedObject var settingsViewModel: UserSettingsViewModel
    @State var tabSelectedValue: Int = 0

    var body: some View {
        var combinedSites: [InsertionSite] {
            return (siteViewModel.pumpSites + siteViewModel.cgmSites).sorted { $0.timestamp ?? Date.now < $1.timestamp ?? Date.now}
        }
        NavigationView{
            VStack{
                List {
                    // Logic to display labels depending on if using a Pump/CGM
                    if settingsViewModel.pumpType == "None" && settingsViewModel.cgmType != "None"{
                        Section("\(settingsViewModel.cgmType) Insertion Sites") {
                            ForEach(Array(siteViewModel.cgmSites.enumerated().reversed()), id: \.element.timestamp) { index, site in
                                let i = siteViewModel.cgmSites.count -  index
                                let opacity = opacityOutput(array: siteViewModel.cgmSites, index: i)
                                NavigationLink(
                                    destination: ListItemEditView(siteViewModel:siteViewModel,site: site, index: i),
                                    label: {
                                        ListItemDetailView(settingsViewModel: settingsViewModel, insertionSite: site, index: i, opacity: opacity)
                                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                                Button(role: .destructive) {
                                                    // Action to perform when the delete button is tapped
                                                    siteViewModel.delete(site: site)
                                                } label: {
                                                    Label("Delete", systemImage: "trash")
                                                }
                                            }
                                    }
                                )
                            }
                        }
                    }else if settingsViewModel.cgmType == "None" && settingsViewModel.pumpType != "None"{
                        Section("\(settingsViewModel.pumpType) Insertion Sites"){
                            ForEach(Array(siteViewModel.pumpSites.enumerated().reversed()), id: \.element.timestamp) { index, site in
                                let i = siteViewModel.pumpSites.count -  index
                                let opacity = opacityOutput(array: siteViewModel.pumpSites, index: i)
                                NavigationLink(
                                    destination: ListItemEditView(siteViewModel:siteViewModel,site: site, index: i),
                                    label: {
                                        ListItemDetailView(settingsViewModel: settingsViewModel, insertionSite: site, index: i, opacity: opacity)
                                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                                Button(role: .destructive) {
                                                    // Action to perform when the delete button is tapped
                                                    siteViewModel.delete(site: site)
                                                } label: {
                                                    Label("Delete", systemImage: "trash")
                                                }
                                            }
                                    }
                                )
                            }
                        }
                    }else if settingsViewModel.cgmType != "None" && settingsViewModel.pumpType != "None"{
                        Picker(selection: $tabSelectedValue, label: Text("")) {
                            Text("By Type").tag(0)
                            Text("By Date").tag(1)
                        }
                        .pickerStyle(SegmentedPickerStyle()).padding(.horizontal,50)
                        .onChange(of: tabSelectedValue) { oldValue, newValue in
                            print(tabSelectedValue)
                        }
                        if tabSelectedValue == 0{
                            Section("\(settingsViewModel.pumpType) Insertion Sites") {
                                ForEach(Array(siteViewModel.pumpSites.enumerated().reversed()), id: \.element.timestamp) { index, site in
                                    let i = siteViewModel.pumpSites.count -  index
                                    let opacity = opacityOutput(array: siteViewModel.pumpSites, index: i)
                                    NavigationLink(
                                        destination: ListItemEditView(siteViewModel:siteViewModel,site: site, index: i),
                                        label: {
                                            ListItemDetailView(settingsViewModel: settingsViewModel, insertionSite: site, index: i, opacity: opacity)
                                                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                                    Button(role: .destructive) {
                                                        // Action to perform when the delete button is tapped
                                                        siteViewModel.delete(site: site)
                                                    } label: {
                                                        Label("Delete", systemImage: "trash")
                                                    }
                                                }
                                        }
                                    )
                                }
                            }
                            Section("\(settingsViewModel.cgmType) Insertion Sites") {
                                ForEach(Array(siteViewModel.cgmSites.enumerated().reversed()), id: \.element.timestamp) { index, site in
                                    let i = siteViewModel.cgmSites.count -  index
                                    let opacity = opacityOutput(array: siteViewModel.cgmSites, index: i)
                                    NavigationLink(
                                        destination: ListItemEditView(siteViewModel:siteViewModel,site: site, index: i),
                                        label: {
                                            ListItemDetailView(settingsViewModel: settingsViewModel, insertionSite: site, index: i, opacity: opacity)
                                                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                                    Button(role: .destructive) {
                                                        // Action to perform when the delete button is tapped
                                                        siteViewModel.delete(site: site)
                                                    } label: {
                                                        Label("Delete", systemImage: "trash")
                                                    }
                                                }
                                        }
                                    )
                                }
                            }
                        }else{
                            Section("All Sites") {
                                ForEach(Array(combinedSites.enumerated().reversed()), id: \.element.timestamp) { index, site in
                                    var i: Int{
                                        if site.type == "Pump"{
                                            return siteViewModel.pumpSites.count -  siteViewModel.pumpSites.firstIndex(of: site)!
                                        }else{
                                            return siteViewModel.cgmSites.count -  siteViewModel.cgmSites.firstIndex(of: site)!
                                        }
                                    }
                                    let opacity = opacityOutput(array: (site.type == "Pump") ? siteViewModel.pumpSites : siteViewModel.cgmSites, index: i)
                                    NavigationLink(
                                        destination: ListItemEditView(siteViewModel:siteViewModel,site: site, index:i),
                                        label: {
                                            ListItemDetailView(settingsViewModel: settingsViewModel, insertionSite: site, index: i, opacity: opacity)
                                                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                                    Button(role: .destructive) {
                                                        // Action to perform when the delete button is tapped
                                                        siteViewModel.delete(site: site)
                                                    } label: {
                                                        Label("Delete", systemImage: "trash")
                                                    }
                                                }
                                        }
                                    )
                                }
                            }
                        }
                    }else{
                        Section("No Sites to Display"){
                        }
                    }
                }
            }
        }
    }
    
}

struct SiteListView_Previews: PreviewProvider {
    static var previews: some View {
        ListView(siteViewModel:InsertionSiteViewModel(), settingsViewModel: UserSettingsViewModel())
    }
}

// Convert site index to opacity
func opacityOutput(array: [InsertionSite], index: Int) -> Double{
    let maxOpacity = 1.0
    let minOpacity = 0.2
    
    let totalItems = Double(array.count)
    let adjustedOpacity = maxOpacity - (maxOpacity - minOpacity) * (Double(index-1) / min(3, totalItems))
    return max(minOpacity, min(maxOpacity, adjustedOpacity))
}
