import GoogleMaps
import SwiftUI

// Google Maps view to show events
// MapView update when events or cameracoordinates changes
struct GoogleMapView: UIViewRepresentable {
    @Binding var events: [Event]
    @Binding var selectedEvent: Event?
    @Binding var mapView: GMSMapView // Bind the mapView to allow updates from ContentView
    @Binding var cameraCoordinate: CLLocationCoordinate2D // Add a binding to pass camera coordinates

    var zipCode: String

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIView(context: Context) -> GMSMapView {
        mapView.delegate = context.coordinator
        mapView.isMyLocationEnabled = true
        
        // Set default location to Seattle
        let seattleLocation = CLLocationCoordinate2D(latitude: 47.6062, longitude: -122.3321)
        let camera = GMSCameraPosition.camera(withTarget: seattleLocation, zoom: 10.0)
        mapView.camera = camera
        
        return mapView
    }

    func updateUIView(_ uiView: GMSMapView, context: Context) {
        uiView.clear()

        for event in events {
            let marker = EventMarker(event: event)
            marker.map = uiView
        }

        if let selectedEvent = selectedEvent {
            let location = CLLocationCoordinate2D(latitude: selectedEvent.locationLat ?? 0.0, longitude: selectedEvent.locationLng ?? 0.0)
            let camera = GMSCameraPosition.camera(withLatitude: location.latitude, longitude: location.longitude, zoom: 12.0)
            uiView.animate(to: camera)
        }

        // Update the camera to the new coordinate when provided
        // Here, we are no longer using optional binding, as cameraCoordinate is non-optional
        if cameraCoordinate.latitude != 0.0 && cameraCoordinate.longitude != 0.0 {
            let camera = GMSCameraPosition.camera(withLatitude: cameraCoordinate.latitude, longitude: cameraCoordinate.longitude, zoom: 10.0)
            uiView.animate(to: camera)
        }
    }

    class Coordinator: NSObject, GMSMapViewDelegate {
        var parent: GoogleMapView

        init(parent: GoogleMapView) {
            self.parent = parent
        }

        func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
            if let eventMarker = marker as? EventMarker {
                parent.selectedEvent = eventMarker.event
                return true
            }
            return false
        }
    }
}
