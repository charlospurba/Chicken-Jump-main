//
//  AppDelegate.swift
//  Chicken Jump
//
//  Created by Charlos Purba on 27/06/24.
//

import UIKit
import AVFoundation

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    var music: AVAudioPlayer? = {
        //cara agar player taua, ngambil music dr mn
        guard let musicLocation = Bundle.main.url(forResource: "Bgmusic", withExtension: "mpeg") else {
            return nil
        }
        
        let audioPlayer = try?
        AVAudioPlayer(contentsOf: musicLocation)
        audioPlayer?.numberOfLoops = -1
        return audioPlayer
    }()


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        music?.play()
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }


}
