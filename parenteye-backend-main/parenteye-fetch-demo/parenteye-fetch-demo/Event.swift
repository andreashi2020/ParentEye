//
//  Event.swift
//  parenteye-fetch-demo
//
//  Created by Nendo on 2024/11/7.
//

struct Event: Identifiable, Codable {
    let eventId: String
    let linkUrl: String?
    let imgUrl: String?
    let eventTitle: String
    let eventYear: String?
    let eventDate: String?
    let eventTime: String?
    let eventLocation: String?
    let isEditorsChoice: Int?
    let isFree: Int?
    let types: String?
    let isVirtual: Int?
    let datesDuration: String?
    let bigImgUrl: String?
    let eventContent: String?
    let detailedDates: String?
    let googleMapUrl: String?
    let price: String?
    let recommendedAge: String?
    let venueName: String?
    let venueAddress: String?
    let eventUrl: String?
    let eventTimestamp: Int?
    let locationLat: Double?
    let locationLng: Double?
    
    var id: String { eventId }
}
