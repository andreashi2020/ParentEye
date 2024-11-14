import SwiftUI
import MapKit

// Custom annotation class to hold event details
class EventAnnotation: NSObject, MKAnnotation {
    let title: String?
    let subtitle: String?
    let coordinate: CLLocationCoordinate2D
    let linkUrl: String
    
    init(event: Event) {
        // Safely unwrap eventDate and eventTime, and provide "N/A" as a fallback if they are nil
        let eventDate = event.eventDate ?? "N/A"
        let eventTime = event.eventTime ?? "N/A"
        
        self.title = event.eventTitle
        self.subtitle = eventDate + " " + eventTime
        
        self.coordinate = CLLocationCoordinate2D(latitude: event.locationLat ?? 0.0, longitude: event.locationLng ?? 0.0)
        self.linkUrl = event.linkUrl ?? ""
        super.init()
    }
}

// MapView to show events
struct MapView: UIViewRepresentable {
    @Binding var events: [Event]
    @Binding var region: MKCoordinateRegion
    @Binding var selectedEvent: Event?

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView(frame: .zero)
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = false
        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        // Check if the region center has changed by comparing latitude and longitude
        if region.center.latitude != uiView.region.center.latitude ||
            region.center.longitude != uiView.region.center.longitude {
            uiView.setRegion(region, animated: true)
        }
        
        uiView.removeAnnotations(uiView.annotations)
        let annotations = events.map { EventAnnotation(event: $0) }
        uiView.addAnnotations(annotations)
        
    }
    
    // Coordinator class to handle MapView interactions
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapView

        init(parent: MapView) {
            self.parent = parent
        }

        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            guard let annotation = view.annotation as? EventAnnotation else { return }
            if let event = parent.events.first(where: { $0.linkUrl == annotation.linkUrl }) {
                parent.selectedEvent = event
            }
        }
        
        func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
            parent.selectedEvent = nil
        }
    }
}

// ContentView with input box and buttons
struct ContentView: View {
    @StateObject private var eventViewModel = EventViewModel()  // Initialize EventViewModel
    @State private var zipCode: String = ""
    @State private var events: [Event] = []
    @State private var region: MKCoordinateRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 47.6061, longitude: -122.3328), latitudinalMeters: 10000, longitudinalMeters: 10000)
    @State private var successfulLocationsCount: Int = 0
    @State private var selectedEvent: Event? {
        didSet {
            // Update the region whenever the selected event changes
            if let event = selectedEvent, let lat = event.locationLat, let lng = event.locationLng {
                region.center = CLLocationCoordinate2D(latitude: lat, longitude: lng)
                region.span = MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02) // Adjust zoom level as desired
            }
        }
    }
    @State private var selectedDate: Date = Date()
    
    var body: some View {
        ZStack {
            Color.white
                .edgesIgnoringSafeArea(.all)
            
            MapView(events: $events, region: $region, selectedEvent: $selectedEvent)
                .edgesIgnoringSafeArea(.all)
                .frame(height: 400)
                
            
            VStack (spacing: 16) {
//                TextField("Enter Zip Code", text: $zipCode)
//                    .textFieldStyle(RoundedBorderTextFieldStyle())
//                    .multilineTextAlignment(.center)
//                    .padding(.top, 20)
//                    .background(Color(red: 0/255, green: 180/255, blue: 205/255))
//                    .background(Color.blue)
//                    .foregroundColor(.black)
//                    .cornerRadius(5)
                
                
                HStack {
                    // Label for the Zip Code input
                    Text("Enter Zip Code:")
                        .foregroundColor(.blue)
                        .fontWeight(.bold)
                        .padding(.trailing, 2)
                    
//                        // Background for the text field
//                        RoundedRectangle(cornerRadius: 5)
//                            .fill(Color.white) // Inner background color
//                            .frame(height: 44) // Height for the text field
                        
                    TextField("", text: $zipCode) // No default text
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white) // Text color
                        .padding(5)
                        .background(Color(red: 0/255, green: 180/255, blue: 205/255))
                        .cornerRadius(6)
                        .frame(width:130, height: 40)
                        .shadow(radius: 2)
                        
                    

                }
                .padding(.horizontal) // Outer padding for the HStack


                
                
                HStack {
                    Text("Select Date:")
                        .foregroundColor(.blue)
                        .fontWeight(.bold)
                        .padding(.trailing, 10)
                    DatePicker("", selection: $selectedDate, displayedComponents: .date)
                        .labelsHidden()
                        .padding(0)
                        .background(Color(red: 0/255, green: 180/255, blue: 205/255))
                        .cornerRadius(5)
                        .accentColor(.blue)
                        .frame(height:40)
                        .shadow(radius: 2)
                }
                .padding(.horizontal)

                Button(action: {
                    fetchEvents()
                }) {
                    Text("Find Nearby Events")
                        .fontWeight(.bold)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 25)
                        .background(Color(red: 0/255, green: 180/255, blue: 205/255))
                        .foregroundColor(.white)
                        .cornerRadius(5)
                        .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)
                        
                }
                .padding(.horizontal)

                Spacer()
            }
            .padding()
            
            if let event = selectedEvent {
                EventDetailView(event: event)
                    .transition(.move(edge: .bottom))
                    .animation(.easeInOut(duration: 0.3), value: selectedEvent)
            }
        }
    }

    // Modify fetchEvents to use backend API data
    func fetchEvents() {
        // Get coordinates from the zip code
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(zipCode) { placemarks, error in
            if let placemark = placemarks?.first, let location = placemark.location {
                region.center = location.coordinate
                region.span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)

                // Convert selected date to the required format
                let formatter = DateFormatter()
                formatter.dateFormat = "EEEE, MMM. dd" // Format for "Friday, Nov. 15"
                let formattedDate = formatter.string(from: selectedDate)
                
                // Use location coordinates for backend fetch
                eventViewModel.fetchEvents(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude, specificDate: formattedDate)
                
                // Observe updates from the eventViewModel
                self.events = eventViewModel.events

                // Filter events by the selected date
                self.events = self.events.filter { event in
                    let calendar = Calendar.current
                    let eventDate = event.eventDate ?? ""
                    return eventDate == formattedDate
                }
                
                self.successfulLocationsCount = self.events.count
            } else {
                print("Geocoding failed for zip code: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }
}

struct EventDetailView: View {
    let event: Event
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(event.eventTitle)
                        .font(.headline)
                        .lineLimit(2)
                    
                    if let date = event.eventDate {
                        Label(date, systemImage: "calendar")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    if let time = event.eventTime {
                        Label(time, systemImage: "clock")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    if let location = event.eventLocation {
                        Label(location, systemImage: "mappin.circle")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                if let urlString = event.linkUrl, let url = URL(string: "https://www.parentmap.com/" + urlString) {
                    Link(destination: url) {
                        Image(systemName: "arrow.right.circle.fill")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(red: 0/255, green: 180/255, blue: 205/255))
                .shadow(radius: 5)
        )
        .padding(.top, 550)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
