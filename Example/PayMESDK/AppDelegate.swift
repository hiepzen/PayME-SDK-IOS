//
//  AppDelegate.swift
//  PayMESDK
//
//  Created by HuyOpen on 10/19/2020.
//  Copyright (c) 2020 HuyOpen. All rights reserved.
//

import UIKit
import Sentry
import PayMESDK

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        if let rootViewController = UIApplication.shared.windows.first(where: {
            $0.rootViewController is UINavigationController
        })?.rootViewController {
            if let viewController = (rootViewController as! UINavigationController).viewControllers.first(where: {
                $0 is ViewController
            }) {
                print("zo zo zo, ale ale ale")
                print(url.absoluteString)
                (viewController as! ViewController).payME?.setupOpenURL(url: url)
            }
        }

//        if let navigationController = UIApplication.shared.windows.first?.rootViewController as? UINavigationController,
//           let viewController = navigationController.viewControllers.first as? ViewController {
//            viewController.payME?.setupOpenURL(url: url)
//        }
        return true
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        SentrySDK.start { options in
            options.dsn = "https://6fd9d4fe732e4edfac761cc9a31ea9ba@o405361.ingest.sentry.io/5870689"
            options.debug = true // Enabled debug when first installing is always helpful
        }

        return true
    }


    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

}

