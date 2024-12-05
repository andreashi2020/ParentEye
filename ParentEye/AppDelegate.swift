//
//  AppDelegate.swift
//  ParentEye
//
//  Created by Yuanyuan on 11/14/24.
//


import GoogleMaps


class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        GMSServices.provideAPIKey("AIzaSyAXWipZnTV-fRm5eZ5HdFOyCl1sT841jV4")
        return true
    }

    // Additional AppDelegate methods if needed
}
