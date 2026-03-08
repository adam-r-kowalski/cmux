import XCTest

final class TitlebarPaneActionsUITests: XCTestCase {
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }

    func testSingleTabPaneHidesHorizontalTabBarUntilNewTerminalIsCreated() {
        let app = XCUIApplication()
        app.launchEnvironment["CMUX_UI_TEST_MODE"] = "1"
        app.launch()

        XCTAssertTrue(waitForWindowCount(atLeast: 1, app: app, timeout: 8.0))
        app.activate()

        let newTerminalButton = app.buttons["titlebarPaneAction.newTerminal"]
        let newBrowserButton = app.buttons["titlebarPaneAction.newBrowser"]
        let splitRightButton = app.buttons["titlebarPaneAction.splitRight"]
        let splitDownButton = app.buttons["titlebarPaneAction.splitDown"]

        XCTAssertTrue(waitForElementVisible(newTerminalButton, timeout: 6.0))
        XCTAssertTrue(waitForElementVisible(newBrowserButton, timeout: 6.0))
        XCTAssertTrue(waitForElementVisible(splitRightButton, timeout: 6.0))
        XCTAssertTrue(waitForElementVisible(splitDownButton, timeout: 6.0))

        let tabBar = app.descendants(matching: .any)["BonsplitTabBar"]
        XCTAssertFalse(tabBar.exists, "A single-tab pane should not show the horizontal tab bar")

        newTerminalButton.tap()

        XCTAssertTrue(
            waitForElementVisible(tabBar, timeout: 6.0),
            "Creating a second terminal in the focused pane should reveal the horizontal tab bar"
        )
    }

    private func waitForWindowCount(atLeast count: Int, app: XCUIApplication, timeout: TimeInterval) -> Bool {
        pollUntil(timeout: timeout) {
            app.windows.count >= count
        }
    }

    private func waitForElementVisible(_ element: XCUIElement, timeout: TimeInterval) -> Bool {
        pollUntil(timeout: timeout) {
            if element.exists {
                let frame = element.frame
                if frame.width > 1, frame.height > 1 {
                    return true
                }
            }
            return false
        }
    }

    private func pollUntil(timeout: TimeInterval, condition: () -> Bool) -> Bool {
        let deadline = Date().addingTimeInterval(timeout)
        while Date() < deadline {
            if condition() {
                return true
            }
            RunLoop.current.run(until: Date().addingTimeInterval(0.05))
        }
        return condition()
    }
}
