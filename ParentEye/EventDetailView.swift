//
//  EventDetailView.swift
//  ParentEye
//
//  Created by Yuanyuan on 11/14/24.
//
import SwiftUI

struct EventDetailView: View {
    let event: Event
    
    var body: some View {
        VStack(alignment: .leading) {
            // Event Image section with a label
            if let imageUrl = event.bigImgUrl, let url = URL(string: "https://www.parentmap.com/" + imageUrl) {
                
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(width: 200, height: 150)
                    case .failure:
                        Image(systemName: "photo.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 200, height: 150)
                            .foregroundColor(.gray)
                    @unknown default:
                        EmptyView()
                    }
                }
            } else {
                Label("No Image Available", systemImage: "photo.fill")
                    .foregroundColor(.gray)
            }

            
            Text(event.eventTitle)
                .font(.headline)
                .foregroundColor(.black)
            
            Label(event.eventDate ?? "N/A", systemImage: "calendar")
                .foregroundColor(.black)
            Label(event.eventTime ?? "N/A", systemImage: "clock")
                .foregroundColor(.black)
            Label((event.eventLocation?.trimmingCharacters(in: .whitespaces) ?? "N/A"), systemImage: "mappin.circle")
                .foregroundColor(.black)

            
            // Displaying 'Free' or 'Paid' based on isFree
            if let isFree = event.isFree {
                Label(isFree == 1 ? "Free Event" : "Paid Event", systemImage: "dollarsign.circle")
                    .foregroundColor(.black)
            } else {
                Label("Event Price: N/A", systemImage: "dollarsign.circle")
                    .foregroundColor(.black)
            }


            // URL section with arrow positioned at the right side
            HStack {
                Spacer() // Pushes the link and arrow to the right
                if let url = event.linkUrl {
                    Link("More Info", destination: URL(string: "https://www.parentmap.com/" + url)!)
                        .foregroundColor(.blue)
                    Image(systemName: "arrow.right.circle.fill")
                        .foregroundColor(.blue)
                }
            }
        }
        .padding()
    }
}
