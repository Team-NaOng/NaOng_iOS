//
//  ContentView.swift
//  NaOng
//
//  Created by seohyeon park on 2023/05/23.
//

import SwiftUI
import CoreData
import Combine

struct ContentView: View {
    @AppStorage("isFirstRun") var isFirstRun: Bool = true
    @Environment(\.managedObjectContext) var viewContext
    @EnvironmentObject var localNotificationManager: LocalNotificationManager

    init() {
        UITabBar.appearance().backgroundColor = UIColor.white
    }
    
    var body: some View {
        TabView {
            let locationToDoListViewModel = LocationToDoListViewModel(viewContext: viewContext, localNotificationManager: localNotificationManager)
            LocationToDoListView(locationToDoListViewModel: locationToDoListViewModel)
                .tabItem {
                    Image(systemName: "mappin.and.ellipse")
                    Text("위치 할 일")
                        .font(.custom("Binggrae", size: 10))
                }
                .onAppear(perform: {
                    if isFirstRun {
                        locationToDoListViewModel.addInitialData()
                        isFirstRun = false
                    }
                })
            
            let timeToDoListViewModel = TimeToDoListViewModel(viewContext: viewContext, localNotificationManager: localNotificationManager)
            TimeToDoListView(timeToDoListViewModel: timeToDoListViewModel)
                .tabItem {
                    Image(systemName: "clock")
                    Text("시간 할 일")
                        .font(.custom("Binggrae", size: 10))
                }

            let weatherViewModel = WeatherViewModel(imageState: .loaded)
            WeatherView(weatherViewModel: weatherViewModel)
                .tabItem {
                    Image(systemName: "thermometer.sun.fill")
                    Text("오늘 날씨")
                        .font(.custom("Binggrae", size: 10))
                }
            
            let settingViewModel = SettingViewModel( localNotificationManager: localNotificationManager)
            SettingView(settingViewModel: settingViewModel)
                .tabItem {
                    Image(systemName: "gearshape")
                    Text("설정")
                        .font(.custom("Binggrae", size: 10))
                }
        }
        .tint(Color("primary"))
    }
}
