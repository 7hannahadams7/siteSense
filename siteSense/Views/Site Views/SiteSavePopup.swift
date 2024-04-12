//
//  SiteSavePopup.swift
//  siteSense
//
//  Created by Hannah Adams on 4/11/24.
//

import SwiftUI

// View to save current tapped site
struct SiteSavePopup: View {
    @Binding var showSiteSavePopover: Bool
    @Binding var saveTappedSite: Bool
    
    var body: some View {
        Circle()
            .fill(Color.red.opacity(showSiteSavePopover ? 0.5 : 0.0))
            .popover(isPresented: $showSiteSavePopover,
              attachmentAnchor: .point(.center),
         arrowEdge: .top) {
             ZStack {
                 VStack{
                     Text("Save Site")
                     HStack {
                         Button{
                             showSiteSavePopover = false
                         }label:{
                             Image(systemName: "xmark.square.fill").resizable()
                                 .frame(width:30,height:30)
                                 .foregroundStyle(Color.red)
                         }
                         Button{
                             showSiteSavePopover = false
                             saveTappedSite = true
                         }label:{
                             Image(systemName: "checkmark.square.fill").resizable()
                                 .frame(width:30,height:30)
                                 .foregroundStyle(Color.green)
                         }
                     }
                 }
                 .padding()
                 .cornerRadius(10)
             }.presentationCompactAdaptation(.popover)
            }
    }
}
