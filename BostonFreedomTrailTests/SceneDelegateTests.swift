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

        // SceneDelegate should initialize successfully
        #expect(type(of: sceneDelegate) == SceneDelegate.self)
        #expect(sceneDelegate.window == nil) // Initially nil
    }

    @Test("Scene delegate methods exist and are callable")
    func sceneDelegateMethods() {
        let sceneDelegate = SceneDelegate()

        // Verify that the SceneDelegate has the required methods
        // We can't easily test the actual functionality without a real scene,
        // but we can verify the methods exist and the delegate is properly structured
        #expect(sceneDelegate.responds(to: #selector(SceneDelegate.sceneDidDisconnect(_:))))
        #expect(sceneDelegate.responds(to: #selector(SceneDelegate.sceneDidBecomeActive(_:))))
        #expect(sceneDelegate.responds(to: #selector(SceneDelegate.sceneWillResignActive(_:))))
        #expect(sceneDelegate.responds(to: #selector(SceneDelegate.sceneWillEnterForeground(_:))))
        #expect(sceneDelegate.responds(to: #selector(SceneDelegate.sceneDidEnterBackground(_:))))
    }
}
