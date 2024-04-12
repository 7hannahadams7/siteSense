//
//  InsertionSiteViewModel.swift
//  siteSense
//
//  Created by Hannah Adams on 3/17/24.
//

import Foundation
import CoreData
import WidgetKit

class InsertionSiteViewModel: ObservableObject {
    @Published var pumpSites: [InsertionSite] = []
    @Published var cgmSites: [InsertionSite] = []
    
    // Maximum sites to store, will delete old site instances when new one added
    let maxSites: Int = 15

    // Function to pull sites from core data
    func fetchInsertionSites() {
        print("REFETCHING")
        let fetchRequest: NSFetchRequest<InsertionSite> = InsertionSite.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: true)]
        do {
            pumpSites = []
            cgmSites = []
            let allSites = try PersistenceController.shared.container.viewContext.fetch(fetchRequest)
            for site in allSites{
                if site.type == "Pump"{
                    pumpSites.append(site)
                }else{
                    cgmSites.append(site)
                }
            }

        } catch {
            print("Failed to fetch insertion sites: \(error.localizedDescription)")
        }
        WidgetCenter.shared.reloadAllTimelines()
        
    }

    func addInsertionSite(position: CGPoint, side: String, type: String) {
        PersistenceController.shared.container.viewContext.reset()
        
        // Create new insertion site instance
        let newInsertionSite = InsertionSite(context: PersistenceController.shared.container.viewContext)
        newInsertionSite.timestamp = Date()
        newInsertionSite.x = Double(position.x)
        newInsertionSite.y = Double(position.y)
        newInsertionSite.side = side
        newInsertionSite.type = type
        
        
        // Add to core data, delete old site instances if at max
        if type == "Pump"{
            do {
                // Check if the count exceeds the limit
                if pumpSites.count >= maxSites {
                    // Sort sites by timestamp in ascending order
                    let sortedSites = pumpSites.sorted { $0.timestamp ?? Date.now < $1.timestamp ?? Date.now}
                    
                    // Delete the oldest sites until the count is reduced to 15
                    let sitesToDelete = sortedSites.prefix(sortedSites.count - maxSites)
                    for siteToDelete in sitesToDelete {
                        PersistenceController.shared.container.viewContext.delete(siteToDelete)
                    }
                }
                try PersistenceController.shared.container.viewContext.save()
            } catch {
                print("Failed to save new insertion site: \(error.localizedDescription)")
            }
        }else{
            do {
                // Check if the count exceeds the limit
                if cgmSites.count >= maxSites {
                    // Sort sites by timestamp in ascending order
                    let sortedSites = cgmSites.sorted { $0.timestamp ?? Date.now < $1.timestamp ?? Date.now}
                    
                    // Delete the oldest sites until the count is reduced to 15
                    let sitesToDelete = sortedSites.prefix(sortedSites.count - maxSites)
                    for siteToDelete in sitesToDelete {
                        PersistenceController.shared.container.viewContext.delete(siteToDelete)
                    }
                }
                try PersistenceController.shared.container.viewContext.save()
            } catch {
                print("Failed to save new insertion site: \(error.localizedDescription)")
            }
        }
        
        // Update the insertion sites after adding a new one
        fetchInsertionSites()
    }
    
    // Delete instance (via list swipe function)
    func delete(site: InsertionSite) {
        PersistenceController.shared.container.viewContext.delete(site)
        do {
            try PersistenceController.shared.container.viewContext.save()
            fetchInsertionSites() // Update the insertion sites after deletion
        } catch {
            print("Failed to delete insertion site: \(error.localizedDescription)")
        }
        // Call any other necessary methods to handle deletion from the data source
    }

    // Change site timestamp, via list Nav view
    func updateTimestamp(_ timestamp: Date, for site: InsertionSite) {
        site.timestamp = timestamp
        // Save the context to persist the updated timestamp
        do {
            try PersistenceController.shared.container.viewContext.save()
            fetchInsertionSites()
        } catch {
            print("Failed to update timestamp: \(error.localizedDescription)")
        }
    }
    
}
