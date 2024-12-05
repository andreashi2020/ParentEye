import Foundation
import SwiftUI

@MainActor
class EventViewModel: ObservableObject {
    @Published var events: [Event] = []
    @Published var errorMessage: String? = nil
    
    func fetchEvents(
        latitude: Double = 47.6061,
        longitude: Double = -122.3328,
        rangeInKm: Double = 80,
        numOfResult: Int = 100,
        specificDate: String? = nil
    ) async {
        // Construct URL with parameters
        var components = URLComponents(string: "https://parenteye-backend.parenteye.workers.dev/getNearbyLatestEvents")!
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "latitude", value: String(latitude)),
            URLQueryItem(name: "longitude", value: String(longitude)),
            URLQueryItem(name: "rangeInKm", value: String(rangeInKm)),
            URLQueryItem(name: "numOfResult", value: String(numOfResult))
        ]
        
        if let date = specificDate {
            queryItems.append(URLQueryItem(name: "eventDate", value: date))
        }
        
        components.queryItems = queryItems
        
        guard let url = components.url else {
            print("Error: Invalid URL")
            return
        }
        
        print("Fetching from URL: \(url.absoluteString)")
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            print("\nRaw API Response:")
            if let jsonString = String(data: data, encoding: .utf8) {
                print(jsonString)
            }
            
            self.events = try JSONDecoder().decode([Event].self, from: data)
            print("\nDecoded Events:")
            self.events.forEach { event in
                print("""
                
                Title: \(event.eventTitle)
                Date: \(event.eventDate ?? "N/A")
                Location: \(event.eventLocation ?? "N/A")
                Timestamp: \(event.eventTimestamp ?? 0)
                Lat/Lng: \(event.locationLat ?? 0) / \(event.locationLng ?? 0)
                ImageURL: \(event.imgUrl ?? "N/A")
                ----------------------------------------
                """)
            }
            
            // Reset any previous error messages
            self.errorMessage = nil
            
        } catch {
            print("Error: \(error)")
            if let decodingError = error as? DecodingError {
                print("Decoding Error Details: \(decodingError)")
                self.errorMessage = "Failed to decode event data."
            } else {
                self.errorMessage = "An unexpected error occurred while fetching events."
            }
        }
    }
}
