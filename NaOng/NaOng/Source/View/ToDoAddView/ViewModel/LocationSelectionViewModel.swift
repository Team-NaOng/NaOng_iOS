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
    @Published var isShowingErrorAlert: Bool = false
    var errorTitle: String = ""
    var errorMessage: String = ""
    
    private let fetchedResultsController: NSFetchedResultsController<Location>
    private let viewContext: NSManagedObjectContext
    
    init(viewContext: NSManagedObjectContext) {
        self.viewContext = viewContext
        
        let fetchRequest = Location.fetchRequest()
        fetchRequest.sortDescriptors = []

        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
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
            errorTitle = "위치 목록 불러오기 실패🥲"
            errorMessage = error.localizedDescription
            isShowingErrorAlert.toggle()
        }
    }
    
    func deleteItems(offsets: IndexSet) {
        offsets.map { locations[$0] }.forEach { location in
            do {
                try location.delete(viewContext: viewContext)
            } catch {
                errorTitle = "위치 목록 삭제 실패🥲"
                errorMessage = error.localizedDescription
                isShowingErrorAlert.toggle()
            }
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
