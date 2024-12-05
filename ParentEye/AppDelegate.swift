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
        GMSServices.provideAPIKey("Replace with your API key")
        return true
    }

    // Additional AppDelegate methods if needed
}
