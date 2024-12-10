# ParentEye

ParentEye is an iOS application designed to help parents discover and explore local family-friendly events. Using zip code-based searching and an interactive map interface, users can easily find events in their area.

## Features

- **Location-Based Search**: Find events by entering a zip code
- **Date Selection**: Filter events for specific dates
- **Dual View Options**:
  - Map View: Visual representation of event locations using Google Maps
  - List View: Detailed list of all events in the area
- **Event Details**: View comprehensive information about each event including:
  - Event name
  - Date and time
  - Location
  - Description
- **Interactive Map**: 
  - Event markers
  - Tap to view event details
  - Automatic camera positioning based on search location

<img src="https://github.com/user-attachments/assets/e3cd3572-a0da-4a8a-88bb-e5afea0620b5" alt="Sample Image" width="200">
<img src="https://github.com/user-attachments/assets/4cc2f4a0-f3ee-4369-b39c-5e716e65ce68" alt="Sample Image" width="200">
<img src="https://github.com/user-attachments/assets/85deb1f1-9f6c-49ac-a87b-4809dc3f2874" alt="Sample Image" width="200">


## Technologies Used

- SwiftUI
- Google Maps SDK
- Combine Framework
- CoreLocation
- Swift Async/Await

## Requirements

- iOS 15.0+
- Xcode 13.0+
- Google Maps API Key
- CocoaPods

## Installation

1. Clone the repository
``git clone https://github.com/andreashi2020/ParentEye.git``

2. Install dependencies using CocoaPods
``cd ParentEye
pod install``


3. Add your Google Maps API key to the appropriate configuration file
- Open `Info.plist`
- Add your API key under `GMSAPIKey`

4. Open `ParentEye.xcworkspace` in Xcode

5. Build and run the project

## Configuration

To use the Google Maps functionality, you'll need to:
1. Obtain a Google Maps API key from the [Google Cloud Console](https://console.cloud.google.com/)
2. Enable the following APIs:
   - Maps SDK for iOS
   - Geocoding API

## Usage

1. Launch the app
2. Enter a zip code in the search field
3. Select a date
4. Tap "Find Nearby Events"
5. Toggle between map and list views using the bottom navigation
6. Tap on any event to view more details


## Acknowledgments

- Google Maps SDK for iOS
- SwiftUI Framework
- All contributors who have helped with the project

## Contact

yuanyuanshi111@gmail.com


