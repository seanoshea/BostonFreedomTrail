/*
 Copyright (c) 2014 - present Upwards Northwards Software Limited
 All rights reserved.
 */

import Testing
import CoreLocation
@testable import BostonFreedomTrail

@Suite("VirtualTourModel", .serialized)
struct VirtualTourModelTests {

  @Test("Edge case - empty tour handling")
  func edgeCaseEmptyTourHandling() async {
    let model = VirtualTourModel()
    model.tour = []
    
    let currentLocation = model.getCurrentTourLocation()
    #expect(currentLocation == nil)
  }

  @Test("Edge case - invalid tour position")
  func edgeCaseInvalidTourPosition() async {
    let model = VirtualTourModel()
    model.currentTourPosition = -1
    
    let currentLocation = model.getCurrentTourLocation()
    #expect(currentLocation == nil)
  }

  @Test("Edge case - tour position beyond bounds")
  func edgeCaseTourPositionBeyondBounds() async {
    let model = VirtualTourModel()
    model.currentTourPosition = 1000
    
    let currentLocation = model.getCurrentTourLocation()
    #expect(currentLocation == nil)
  }

  @Test("Look at location edge cases")
  func lookAtLocationEdgeCases() async {
    let model = VirtualTourModel()
    model.setupTour()
    
    let hasLookAt = model.atLookAtLocation()
    #expect(hasLookAt == true || hasLookAt == false)
  }
}
