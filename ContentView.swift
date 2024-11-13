import SwiftUI
import MapKit
//import SwiftSoup
//import GoogleMaps
//import GooglePlaces

// Activity Model to represent nearby activities, conforming to Decodable
struct Activity: Decodable, Equatable {
    let eventTitle: String?
    var eventDate: String?
    var eventLocation: String?
    var latitude: Double?
    var longitude: Double?
    var linkUrl: String
}

// Custom annotation class to hold activity details
class ActivityAnnotation: NSObject, MKAnnotation {
    let title: String?
    let subtitle: String?
    let coordinate: CLLocationCoordinate2D
    let linkUrl: String
    
    init(activity: Activity) {
        self.title = activity.eventTitle
        self.subtitle = activity.linkUrl
        self.coordinate = CLLocationCoordinate2D(latitude: activity.latitude ?? 0.0, longitude: activity.longitude ?? 0.0)
        self.linkUrl = activity.linkUrl
        super.init()
    }
}

// MapView to show activities
struct MapView: UIViewRepresentable {
    @Binding var activities: [Activity]
    @Binding var region: MKCoordinateRegion
    @Binding var selectedActivity: Activity?

    
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
        uiView.removeAnnotations(uiView.annotations)
        let annotations = activities.map { ActivityAnnotation(activity: $0) }
        uiView.addAnnotations(annotations)
        uiView.setRegion(region, animated: true)
    }
    
    // Coordinator class to handle MapView interactions
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapView

        init(parent: MapView) {
            self.parent = parent
        }

        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            guard let annotation = view.annotation as? ActivityAnnotation else { return }
            print("Annotation selected: \(annotation.title ?? "No Title")") // Add this line for debugging
            
            print("Activities count: \(parent.activities.count)")
            for activity in parent.activities {
                print("Activity linkUrl: \(activity.linkUrl)")
            }
            
            if let activity = parent.activities.first(where: { $0.linkUrl == annotation.linkUrl }) {
                parent.selectedActivity = activity
                print("selectedActivity set to: \(parent.selectedActivity?.eventTitle ?? "None")") // Log the selected activity
            } else {
                print("No matching activity found for linkUrl: \(annotation.linkUrl)")
            }
        }
        
        // Deselect annotation when the user taps outside
        func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
            parent.selectedActivity = nil
        }
    }
}

// ContentView with input box and buttons
struct ContentView: View {
    @State private var zipCode: String = ""
    @State private var activities: [Activity] = []
    @State private var region: MKCoordinateRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 47.6097, longitude: -122.3331), latitudinalMeters: 10000, longitudinalMeters: 10000)
    @State private var successfulLocationsCount: Int = 0
    @State private var selectedActivity: Activity? = nil
    @State private var selectedDate: Date = Date()
    

    var body: some View {
        ZStack {
            MapView(activities: $activities, region: $region, selectedActivity: $selectedActivity)
                .edgesIgnoringSafeArea(.all)
                .frame(height: 400)
            
            VStack {
                TextField("Enter Zip Code", text: $zipCode)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .multilineTextAlignment(.center)
                    .padding(.top, 20)
                    .background(Color(red: 0/255, green: 180/255, blue: 205/255))
                    .foregroundColor(.black)
                    .cornerRadius(5)
                
                HStack {
                    Text("Select Date:")
                        .foregroundColor(.blue)
                        .fontWeight(.bold)
                        .padding(.trailing, 10)
                    DatePicker("", selection: $selectedDate, displayedComponents: .date)
                        .labelsHidden()
                        .padding(5)
                        .background(Color(red: 0/255, green: 180/255, blue: 205/255))
                        .cornerRadius(5)
                        .accentColor(.blue)
                }
                .padding(.horizontal)

                Button(action: {
                    fetchActivities()
                    print("Button pressed: Fetching activities...")
                }) {
                    Text("Find Nearby Activities")
                        .fontWeight(.bold)
                        .padding()
                        .background(Color(red: 0/255, green: 180/255, blue: 205/255))
                        .foregroundColor(.black)
                        .cornerRadius(5)
                        .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)
                }
                .padding(.horizontal)

                Spacer()
            }
            .padding()
            
//            if let activity = selectedActivity {
//                VStack {
//                    Spacer()
//                    VStack {
//                        Text(activity.eventTitle ?? "No Title")
//                            .font(.headline)
//                        Text(activity.eventDate ?? "No Date")
//                            .font(.subheadline)
//                        Text(activity.eventLocation ?? "No Location")
//                            .font(.subheadline)
//                        if let url = URL(string: activity.linkUrl) {
//                            Link("Event Link", destination: url)
//                                .font(.subheadline)
//                                .foregroundColor(.blue)
//                        }
//                    }
//                    .padding()
//                    .background(Color.white)
//                    .cornerRadius(10)
//                    .shadow(radius: 5)
//                    .padding()
//                }
//                .transition(.move(edge: .bottom))
//                .animation(.easeInOut)
//            }
            
            // Activity Detail Panel
            if let activity = selectedActivity {
                ActivityDetailView(activity: activity)
                    .transition(.move(edge: .bottom))
                    .animation(.easeInOut(duration: 0.3), value: selectedActivity)
            }
//            VStack {
//                Spacer()
//                HStack {
//                    Spacer()
//                    VStack {
//                        Button(action: zoomIn) {
//                            Text("+")
//                                .font(.largeTitle)
//                                .padding()
//                                .background(Color.white)
//                                .clipShape(Circle())
//                                .shadow(radius: 5)
//                        }
//                        .padding(.bottom, 10)
//
//                        Button(action: zoomOut) {
//                            Text("-")
//                                .font(.largeTitle)
//                                .padding()
//                                .background(Color.white)
//                                .clipShape(Circle())
//                                .shadow(radius: 5)
//                        }
//                    }
//                }
//            }
        }
        .onChange(of: selectedActivity) { oldActivity, newActivity in
            if oldActivity != newActivity {
                print("selectedActivity updated from: \(oldActivity?.eventTitle ?? "None") to: \(newActivity?.eventTitle ?? "None")")
            }
        }


    }

    func fetchActivities() {
       
        guard let dataFileURL = Bundle.main.url(forResource: "data", withExtension: "json") else {
            print("data.json file not found.")
            return
        }

        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(zipCode) { placemarks, error in
            if let placemark = placemarks?.first, let location = placemark.location {
                region.center = location.coordinate
                region.span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            } else {
                print("Geocoding failed for zip code: \(error?.localizedDescription ?? "Unknown error")")
            }
        }

        do {
            let jsonData = try Data(contentsOf: dataFileURL)
            var decodedActivities = try JSONDecoder().decode([Activity].self, from: jsonData)

            let dateOnlyFormatter = DateFormatter()
            dateOnlyFormatter.dateFormat = "EEEE, MMM. d"
            let selectedDateWithoutTime = dateOnlyFormatter.string(from: selectedDate)

            decodedActivities = decodedActivities.filter { activity in
                let eventDateComponents = activity.eventDate?.components(separatedBy: "\n").first?.trimmingCharacters(in: .whitespacesAndNewlines)
                return eventDateComponents == selectedDateWithoutTime
            }

            var geocodingResults: [Activity] = []
            let group = DispatchGroup()
            
            for activity in decodedActivities {
                group.enter()
                if let locationName = activity.eventLocation {
                    let geocoder = CLGeocoder()
                    geocoder.geocodeAddressString(locationName) { placemarks, error in
                        if let placemark = placemarks?.first, let location = placemark.location {
                            var geocodedActivity = activity
                            geocodedActivity.latitude = location.coordinate.latitude
                            geocodedActivity.longitude = location.coordinate.longitude
                            geocodingResults.append(geocodedActivity)
                        }
                        group.leave()
                    }
                } else {
                    geocodingResults.append(activity)
                    group.leave()
                }
            }

            group.notify(queue: .main) {
                self.activities = geocodingResults
                self.successfulLocationsCount = geocodingResults.count
            }
        } catch {
            print("Error decoding JSON: \(error)")
        }
    }

    func zoomIn() {
        let zoomFactor: CLLocationDistance = 5000
        region = MKCoordinateRegion(center: region.center, latitudinalMeters: zoomFactor, longitudinalMeters: zoomFactor)
    }

    func zoomOut() {
        let zoomFactor: CLLocationDistance = 20000
        region = MKCoordinateRegion(center: region.center, latitudinalMeters: zoomFactor, longitudinalMeters: zoomFactor)
    }
}

struct ActivityDetailView: View {
    let activity: Activity
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(activity.eventTitle ?? "Untitled Event")
                        .font(.headline)
                        .lineLimit(2)
                    
                    if let date = activity.eventDate {
                        Label(date, systemImage: "calendar")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    if let location = activity.eventLocation {
                        Label(location, systemImage: "mappin.circle")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                if let url = URL(string: activity.linkUrl) {
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
                .fill(Color(UIColor.systemBackground))
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
