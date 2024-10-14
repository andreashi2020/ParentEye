import SwiftUI
import MapKit
import SwiftSoup  // Import SwiftSoup for HTML parsing

// Activity Model to represent nearby activities
struct Activity: Identifiable {
    let id = UUID()
    let name: String
    let date: String
    let location: String
}

// MapView to show activities
struct MapView: UIViewRepresentable {
    var activities: [Activity]  // Activities to be displayed

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView(frame: .zero)
        mapView.showsUserLocation = false // No need to show user location
        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        // Clear existing annotations
        uiView.removeAnnotations(uiView.annotations)

        // Add annotations for activities
        let annotations = activities.map { activity -> MKPointAnnotation in
            let annotation = MKPointAnnotation()
            annotation.title = activity.name
            // Set appropriate coordinates if you have them for each activity
            annotation.coordinate = CLLocationCoordinate2D(latitude: 47.6097, longitude: -122.3331) // Example coordinate
            return annotation
        }
        uiView.addAnnotations(annotations)
    }
}

struct ContentView: View {
    @State private var zipCode: String = ""  // State for the zip code input
    @State private var activities: [Activity] = []  // Activities to be displayed

    var body: some View {
        VStack {
            // Input field for zip code
            TextField("Enter Zip Code", text: $zipCode)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            // Button to fetch activities based on zip code
            Button("Find Activities") {
                fetchActivities(for: zipCode)  // Fetch activities based on the input zip code
            }
            .padding()

            // Displaying the map view with nearby activities
            MapView(activities: activities)
                .edgesIgnoringSafeArea(.all)
                .frame(height: 400)  // Set a height for the map view
        }
        .padding()
    }

    // Function to fetch activities from the ParentMap calendar
    func fetchActivities(for zipCode: String) {
        let urlString = "https://www.parentmap.com/calendar"
        guard let url = URL(string: urlString) else { return }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching activities: \(error)")
                return
            }

            guard let data = data else { return }
            do {
                let html = String(data: data, encoding: .utf8)  // Convert data to String
                if let html = html {
                    // Parse the HTML using SwiftSoup
                    let document = try SwiftSoup.parse(html)
                    let eventElements = try document.select("div.well")  // Adjust selector based on actual HTML structure

                    var fetchedActivities: [Activity] = []

                    for element in eventElements {
                        let title = try element.select("h3.event-title a").text()  // Get event title
                        let date = try element.select("h4.event-date").text()  // Get event date
                        let location = try element.select("h5.event-location").text()  // Get event location

                        // Here you could filter based on zipCode if you had a mapping of events to zip codes
                        // For now, just append all activities
                        let activity = Activity(name: title, date: date, location: location)
                        fetchedActivities.append(activity)
                    }

                    DispatchQueue.main.async {
                        self.activities = fetchedActivities  // Update activities on the main thread
                    }
                }
            } catch {
                print("Error parsing HTML: \(error)")
            }
        }

        task.resume()
    }
}

