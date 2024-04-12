//
//  SiteCollapsedListView.swift
//  siteSense
//
//  Created by Hannah Adams on 4/11/24.
//

import SwiftUI

// View with list items with displayed info from SiteDetailView and NavLink to EditSiteView
struct ListItemView: View{
    @ObservedObject var siteViewModel: InsertionSiteViewModel
    @ObservedObject var settingsViewModel: UserSettingsViewModel
    var sitesArray: [InsertionSite]
    @Binding var selectedSite: InsertionSite?
    var body: some View{

            VStack{
                Spacer()
                List {
                    Section("Sites") {
                        ForEach(Array(sitesArray.enumerated().reversed()), id: \.element.timestamp) { index, site in
                            let i = sitesArray.count -  index
                            let opacity = opacityOutput(array: sitesArray, index: i)
                            NavigationLink(
                                destination: ListItemEditView(siteViewModel:siteViewModel,site: site, index: i)
                                    .onAppear {
                                        selectedSite = site
                                    }
                                    .onDisappear {
                                        selectedSite = nil
                                    }
                                ,
                                label: {
                                    ListItemDetailView(settingsViewModel: settingsViewModel, insertionSite: site, index: i, opacity: opacity)
                                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                            Button(role: .destructive) {
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
            }
        
    }
}
