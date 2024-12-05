//
//  EventModel.swift
//  parenteye-fetch-demo
//
//  Created by Nendo on 2024/11/7.
//
import Foundation
import SwiftUI

@MainActor
class EventViewModel: ObservableObject {
    @Published var events: [Event] = []
    
    func fetchEvents(
        latitude: Double = 47.6091814,
        longitude: Double = -122.1795901,
        rangeInKm: Double = 10,
        numOfResult: Int = 10
    ) {
        // Construct URL with parameters
        var components = URLComponents(string: "https://parenteye-backend.parenteye.workers.dev/getNearbyLatestEvents")!
        components.queryItems = [
            URLQueryItem(name: "latitude", value: String(latitude)),
            URLQueryItem(name: "longitude", value: String(longitude)),
            URLQueryItem(name: "rangeInKm", value: String(rangeInKm)),
            URLQueryItem(name: "numOfResult", value: String(numOfResult))
        ]
        
        guard let url = components.url else {
            print("Error: Invalid URL")
            return
        }
        
        print("Fetching from URL: \(url.absoluteString)")
        
        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                print("\nRaw API Response:")
                if let jsonString = String(data: data, encoding: .utf8) {
                    print(jsonString)
                }
                
                events = try JSONDecoder().decode([Event].self, from: data)
                print("\nDecoded Events:")
                events.forEach { event in
                    print("""
                    
                    Title: \(event.eventTitle)
                    Date: \(event.eventDate ?? "N/A")
                    Location: \(event.eventLocation ?? "N/A")
                    Timestamp: \(event.eventTimestamp ?? 0)
                    Lat/Lng: \(event.locationLat ?? 0) / \(event.locationLng ?? 0)
                    ----------------------------------------
                    """)
                }
            } catch {
                print("Error: \(error)")
                if let decodingError = error as? DecodingError {
                    print("Decoding Error Details: \(decodingError)")
                }
            }
        }
    }
}
