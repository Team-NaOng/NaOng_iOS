//
//  ToDoItemAddViewModel.swift
//  NaOng
//
//  Created by seohyeon park on 2023/07/07.
//

import Foundation
import CoreData

class ToDoItemAddViewModel: ObservableObject {
    @Published var content: String = ""
    @Published var alarmTime: Date = Date()
    @Published var isRepeat: Bool = false
    @Published var locationInformation: LocationInformation = LocationInformation(locationName: "위치를 선택해 주세요", locationAddress: "", locationRoadAddress: "", locationCoordinates: Coordinates(lat: 0.0, lon: 0.0))
    @Published var path: [LocationViewStack] = [LocationViewStack]()
    @Published var showErrorAlert = false
    var errorTitle: String = ""
    var errorMessage: String = ""

    private let viewContext: NSManagedObjectContext
    private let localNotificationManager: LocalNotificationManager
    private let toDoItem: ToDo?
    private let alarmType: String
    
    init(viewContext: NSManagedObjectContext, localNotificationManager: LocalNotificationManager, toDoItem: ToDo? = nil, alarmType: String, alarmTime: Date = Date()) {
        self.viewContext = viewContext
        self.localNotificationManager = localNotificationManager
        self.toDoItem = toDoItem
        self.alarmType = alarmType
        self.alarmTime = alarmTime
        
        setUpToDoFormData()
    }
    
    func addPath(_ addedView: LocationViewStack) {
        path.append(addedView)
    }
    
    func addEditToDo() -> Bool {
        if checkValidLocation() == false { return false }
        
        if let toDoItem = toDoItem {
            saveToDo(toDoItem)
            localNotificationManager.editLocalNotification(toDoItem: toDoItem)
        } else {
            let toDoItem = ToDo(context: viewContext)
            toDoItem.id = UUID().uuidString
            
            saveToDo(toDoItem)
            localNotificationManager.scheduleNotification(for: toDoItem)
        }
        
        return true
    }

    func addLocation() {
        guard alarmType == "위치" else { return }

        if isLocationContained(locationInformation: locationInformation) == false {
            saveLocation()
        }
    }

    private func isLocationContained(locationInformation: LocationInformation) -> Bool {
        guard let fetchedLocations = fetchLocations() else { return false }

        return fetchedLocations.contains { ($0.addressName == locationInformation.locationName) || ($0.roadAddress == locationInformation.locationRoadAddress) || ($0.address == locationInformation.locationAddress) }
    }

    private func saveLocation() {
        let locationViewContext = Location.viewContext
        let location = Location(context: locationViewContext)
        location.id = UUID().uuidString
        location.address = locationInformation.locationAddress
        location.addressName = locationInformation.locationName
        location.roadAddress = locationInformation.locationRoadAddress
        location.latitude = locationInformation.locationCoordinates.lat
        location.longitude = locationInformation.locationCoordinates.lon

        do {
            try location.save(viewContext: locationViewContext)
        } catch {
            errorTitle = "위치 목록 저장 실패🥲"
            errorMessage = error.localizedDescription
            showErrorAlert.toggle()
        }
    }

    private func fetchLocations() -> [Location]? {
        let fetchRequest = Location.fetchRequest()
        fetchRequest.sortDescriptors = []

        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: Location.viewContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )

        do {
            try fetchedResultsController.performFetch()
            return fetchedResultsController.fetchedObjects
        } catch {
            errorTitle = "위치 목록 불러오기 실패🥲"
            errorMessage = error.localizedDescription
            showErrorAlert.toggle()
            return nil
        }
    }
    
    private func setUpToDoFormData() {
        guard let toDoItem = toDoItem else { return }
        
        self.content = toDoItem.content ?? ""
        self.alarmTime = toDoItem.alarmTime ?? Date()
        self.isRepeat = toDoItem.isRepeat

        let locationInformation = LocationInformation(
            locationName: toDoItem.alarmLocationName ?? "위치를 선택해 주세요",
            locationAddress: "",
            locationRoadAddress: "",
            locationCoordinates: Coordinates(
                lat: toDoItem.alarmLocationLatitude,
                lon: toDoItem.alarmLocationLongitude)
        )
        self.locationInformation = locationInformation
    }
    
    private func saveToDo(_ toDoItem: ToDo) {
        toDoItem.content = content
        toDoItem.alarmType = alarmType
        toDoItem.alarmTime = alarmTime
        toDoItem.isRepeat = isRepeat
        toDoItem.alarmLocationLatitude = locationInformation.locationCoordinates.lat
        toDoItem.alarmLocationLongitude = locationInformation.locationCoordinates.lon
        toDoItem.alarmLocationName = locationInformation.locationName
        toDoItem.alarmDate = alarmTime.getFormatDate()
        toDoItem.isDone = false
        toDoItem.isNotificationVisible = false
        
        do {
            try toDoItem.save(viewContext: viewContext)
        } catch {
            errorTitle = "할 일 저장 실패🥲"
            errorMessage = error.localizedDescription
            showErrorAlert.toggle()
        }
    }
    
    private func checkValidLocation() -> Bool {
        if alarmType == "위치" && (locationInformation.locationCoordinates.lat == 0.0 || locationInformation.locationCoordinates.lon == 0.0) {
            errorTitle = "위치가 선택되지 않았습니다."
            errorMessage = "위치를 다시 선택해 주세요."
            showErrorAlert.toggle()
            return false
        }
        
        return true
    }
}
