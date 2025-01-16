//
//  CountdownUITestsLaunchTests.swift
//  CountdownUITests
//
//  Created by neo on 12/25/24.
//

import XCTest

final class CountdownUITestsLaunchTests: XCTestCase {

    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testLaunch() throws {
        let app = XCUIApplication()
        app.launch()

        // Lemme know how shi runs pls i need feedback lmao
        // Im trash at developing, open for any suggestions

        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Launch Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
