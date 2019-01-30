//
//  AppDelegate.swift
//  Cathedral
//
//  Created by Doug Goldstein on 1/29/19.
//  Copyright © 2019 Doug Goldstein. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate
{
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool
    {
        // Make and present window with tab bar controller
        window = UIWindow(frame: UIScreen.main.bounds)
        window!.rootViewController = GameViewController()
        window!.makeKeyAndVisible()
        
        return true
    }
}
