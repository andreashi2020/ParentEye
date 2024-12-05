import SwiftUI
import GoogleMaps
import Combine

// ContentView with input box and buttons
struct ContentView: View {
    @StateObject private var eventViewModel = EventViewModel()
    @State private var zipCode: String = ""
    @State private var events: [Event] = []
    @State private var showEventDetail = false
    @State private var selectedEvent: Event?
    @State private var selectedDate: Date = Date()
    @State private var selectedView: String = "Map" // Tracks the selected view (List or Map)
    @State private var mapView = GMSMapView() // Added mapView state here
    @State private var cameraCoordinate = CLLocationCoordinate2D(latitude: 47.6062, longitude: -122.3321) // Default to Seattle
    
    
    
    // Update the body section with streamlined logic
    var body: some View {
        VStack {
            Rectangle()
                .frame(height: 100)
                .foregroundColor(Color(red: 0/255, green: 180/255, blue: 205/255))
                .edgesIgnoringSafeArea(.top)
            
            // Zip code input and date picker
            HStack {
                Text("Enter Zip Code:")
                    .foregroundColor(Color(red: 0/255, green: 180/255, blue: 205/255))
                    .fontWeight(.bold)
                
               
                TextField("Zip Code", text: $zipCode)
                    .padding(5)
                    .background(Color(red: 0/255, green: 180/255, blue: 205/255))
                    .cornerRadius(8)
                    .foregroundColor(.white) // Optional: Set the text color to white
                    .frame(width: 110)
                    .multilineTextAlignment(.center) // Ensures the text is centered inside the TextField




                    
            }
            
            HStack {
                Text("Select Date:")
                    .foregroundColor(Color(red: 0/255, green: 180/255, blue: 205/255))
                    .fontWeight(.bold)
                
                DatePicker("", selection: $selectedDate, displayedComponents: .date)
                    .labelsHidden()
                   
            }
            
            Button(action: {
                fetchEvents()
            }) {
                Text("Find Nearby Events")
                    .fontWeight(.bold)
                    .padding()
                    .background(Color(red: 0/255, green: 180/255, blue: 205/255))
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            
            // Conditional rendering of views
            if selectedView == "List" {
                List(events, id: \.eventId) { event in
                    EventDetailView(event: event)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 8).fill(Color.white))
                        .padding(.bottom, 8)
                        .onTapGesture {
                            selectedEvent = event
                            showEventDetail = true
                        }
                }
                .frame(maxHeight: .infinity)
                .background(Color.white)
                .listStyle(PlainListStyle())
                
            } else {
                GoogleMapView(
                    events: $events,
                    selectedEvent: $selectedEvent,
                    mapView: $mapView,
                    cameraCoordinate: $cameraCoordinate,
                    zipCode: zipCode
                )
                .frame(maxHeight: .infinity)
            }
            
            Spacer()
            
            // Bottom buttons for List/Map view toggle
            HStack(spacing: 16) {
                Button(action: {
                    selectedView = "List"
                }) {
                    VStack {
                        Image(systemName: "list.dash")
                        Text("List View")
                            .font(.subheadline)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 6)
                    .foregroundColor(selectedView == "List" ? Color(red: 0/255, green: 180/255, blue: 205/255) : Color.gray)
                    .cornerRadius(12)
                }
                
                Button(action: {
                    selectedView = "Map"
                }) {
                    VStack {
                        Image(systemName: "map.fill")
                        Text("Map View")
                            .font(.subheadline)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .foregroundColor(selectedView == "Map" ? Color(red: 0/255, green: 180/255, blue: 205/255) : Color.gray)
                    .cornerRadius(12)
                }
            }
            .padding(.leading, 24)
        }
        .overlay(
            ZStack {
                if showEventDetail, let event = selectedEvent {
                    Color.black.opacity(0.5)
                        .edgesIgnoringSafeArea(.all)
                        .onTapGesture {
                            showEventDetail.toggle()
                        }
                    
                    VStack {
                        EventDetailView(event: event)
                            .frame(width: 300, height: 300)
                            .background(RoundedRectangle(cornerRadius: 16).fill(Color.white).shadow(radius: 10))
                            .overlay(
                                HStack {
                                    Spacer()
                                    Button(action: {
                                        showEventDetail.toggle()
                                    }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .font(.title)
                                            .foregroundColor(.gray)
                                            .padding(0)
                                    }
                                }
                                .padding(), alignment: .topTrailing
                            )
                    }
                    .padding(20)
                }
            }
        )
        .onChange(of: selectedEvent) { event in
            if let event = event {
                showEventDetail = true
            }
        }

        .background(Color.white)
    }

    
    func fetchEvents() {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(zipCode) { placemarks, error in
            if let location = placemarks?.first?.location {
                let formatter = DateFormatter()
                formatter.dateFormat = "EEEE, MMM. dd"
                let formattedDate = formatter.string(from: selectedDate)
                
                // Use async/await pattern with Task
                Task {
                    await eventViewModel.fetchEvents(latitude: location.coordinate.latitude, 
                                                  longitude: location.coordinate.longitude, 
                                                  specificDate: formattedDate)
                    
                    // Update UI on main thread after events are fetched
                    DispatchQueue.main.async {
                        self.events = self.eventViewModel.events.filter { $0.eventDate == formattedDate }
                        self.cameraCoordinate = location.coordinate
                    }
                }
            } else {
                print("Geocoding failed: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }
    
    //    func fetchEventsForLocation(location: CLLocation) {
    //        let formatter = DateFormatter()
    //        formatter.dateFormat = "EEEE, MMM. dd"
    //        let formattedDate = formatter.string(from: selectedDate)
    //
    //        eventViewModel.fetchEvents(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude, specificDate: formattedDate)
    //        self.events = eventViewModel.events.filter { $0.eventDate == formattedDate }
    //
    //        // Update map camera position to the geocoded location
    //        cameraCoordinate = location.coordinate
    //    }
    //}
    //
    //    // Helper function to update map camera
    //    func updateMapCamera(to coordinate: CLLocationCoordinate2D) {
    //        if isMapLoaded, let mapView = getMapView() { // Check if map is loaded and available
    //            let camera = GMSCameraPosition.camera(
    //                withLatitude: coordinate.latitude,
    //                longitude: coordinate.longitude,
    //                zoom: 10.0
    //            )
    //            mapView.animate(to: camera)
    //        }
    //    }
    //
    func updateRegionFromZipCode() {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(zipCode) { placemarks, error in
            if let location = placemarks?.first?.location {
                // Adjust map position based on zip code
                if let mapView = getMapView() {
                    let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude, longitude: location.coordinate.longitude, zoom: 10.0)
                    mapView.animate(to: camera)
                }
            } else {
                print("Geocoding failed for zip code: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }
    //
    //
    func getMapView() -> GMSMapView? {
        // Your logic to fetch the map view
        return nil
    }
}





struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
