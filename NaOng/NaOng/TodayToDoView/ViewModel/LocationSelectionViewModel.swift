//
//  LocationSelectionViewModel.swift
//  NaOng
//
//  Created by seohyeon park on 2023/08/04.
//

import Foundation

import Foundation
import CoreData

class LocationSelectionViewModel: NSObject, ObservableObject {
    @Published var locations: [Location] = [Location]()
    
    private let fetchedResultsController: NSFetchedResultsController<Location>
    private let viewContext: NSManagedObjectContext
    
    init(viewContext: NSManagedObjectContext) {
        self.viewContext = viewContext
        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: Location.all() ?? Location.fetchRequest(),
            managedObjectContext: viewContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        
        super.init()
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
            guard let locations = fetchedResultsController.fetchedObjects else {
                return
            }
            
            self.locations = locations
        } catch {
            print(error)
        }
    }
    
    func deleteItems(offsets: IndexSet) {
        offsets.map { locations[$0] }.forEach(viewContext.delete)
        do {
            try viewContext.save()
        } catch {
            print(error)
        }
    }
    
    func makeLocationInformation(with location: Location) -> LocationInformation {
        let coordinates = Coordinates(lat: location.latitude, lon: location.longitude)
        return LocationInformation(
            locationName: location.addressName ?? "",
            locationAddress: location.address ?? "",
            locationRoadAddress: location.roadAddress ?? "",
            locationCoordinates: coordinates)
    }
}

extension LocationSelectionViewModel: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard let locations = controller.fetchedObjects as? [Location] else {
            return
        }
        
        self.locations = locations
    }
}
