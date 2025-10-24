/*
 Copyright (c) 2014 - present Upwards Northwards Software Limited
 All rights reserved.
 */

import Testing
import UIKit
@testable import BostonFreedomTrail

@Suite("SceneDelegate")
@MainActor
struct SceneDelegateTests {

    @Test("Scene delegate initializes correctly")
    func sceneDelegateInitializesCorrectly() {
        let sceneDelegate = SceneDelegate()

        #expect(sceneDelegate != nil)
        #expect(sceneDelegate.window == nil) // Initially nil
    }

    @Test("Scene will connect to session")
    func sceneWillConnectToSession() {
        let sceneDelegate = SceneDelegate()
        let windowScene = UIWindowScene(session: UISceneSession(), connectionOptions: UIScene.ConnectionOptions())
        let session = UISceneSession()
        let options = UIScene.ConnectionOptions()

        // This should not crash
        sceneDelegate.scene(windowScene, willConnectTo: session, options: options)

        #expect(true) // Test passes if no crash occurs
    }

    @Test("Scene lifecycle methods execute without errors")
    func sceneLifecycleMethods() {
        let sceneDelegate = SceneDelegate()
        let windowScene = UIWindowScene(session: UISceneSession(), connectionOptions: UIScene.ConnectionOptions())

        // Test all lifecycle methods
        sceneDelegate.sceneDidDisconnect(windowScene)
        sceneDelegate.sceneDidBecomeActive(windowScene)
        sceneDelegate.sceneWillResignActive(windowScene)
        sceneDelegate.sceneWillEnterForeground(windowScene)
        sceneDelegate.sceneDidEnterBackground(windowScene)

        #expect(true) // Test passes if no crashes occur
    }
}
