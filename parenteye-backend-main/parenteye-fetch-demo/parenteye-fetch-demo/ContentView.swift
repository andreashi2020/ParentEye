//
//  ContentView.swift
//  parenteye-fetch-demo
//
//  Created by Nendo on 2024/11/7.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = EventViewModel()
    
    // Example coordinates for Seattle area
    let seattleLocation = (
        latitude: 47.6062,
        longitude: -122.3321
    )
    
    var body: some View {
        List(viewModel.events) { event in
            Text(event.eventTitle)
        }
        .task {
            // Example: Fetch events near Seattle within 20km
            viewModel.fetchEvents(
                latitude: seattleLocation.latitude,
                longitude: seattleLocation.longitude,
                rangeInKm: 20,
                numOfResult: 15
            )
        }
    }
}
