//
//  EventMarker.swift
//  ParentEye
//
//  Created by Yuanyuan on 11/14/24.
//
import GoogleMaps
// Custom annotation class to hold event details
class EventMarker: GMSMarker {
    let event: Event
    
    init(event: Event) {
        self.event = event
        super.init()
        
        self.position = CLLocationCoordinate2D(latitude: event.locationLat ?? 0.0, longitude: event.locationLng ?? 0.0)
        self.title = event.eventTitle
        self.snippet = "\(event.eventDate ?? "N/A") \(event.eventTime ?? "N/A")"
        // Load the image for the marker icon
        if let image = UIImage(named: "toys") {
            self.icon = image
        } else {
            print("Error: Image 'toys' not found")
        }
    }
}
