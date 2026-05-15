import XCTest

final class MovieQuizUITests: XCTestCase {
    // swiftlint:disable:next implicitly_unwrapped_optional
    var app: XCUIApplication!

    override func setUpWithError() throws {
        try super.setUpWithError()

        app = XCUIApplication()
        app.launch()

        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()

        app.terminate()
        app = nil
    }

    func testPosterChangesAfterYesTap() {
        sleep(2)

        let firstPoster = app.images["Poster"].screenshot().pngRepresentation
        app.buttons["Yes"].tap()
        sleep(2)
        let secondPoster = app.images["Poster"].screenshot().pngRepresentation

        XCTAssertNotEqual(firstPoster, secondPoster)
    }

    func testPosterChangesAfterNoTap() {
        sleep(2)

        let firstPoster = app.images["Poster"].screenshot().pngRepresentation
        app.buttons["No"].tap()
        sleep(2)
        let secondPoster = app.images["Poster"].screenshot().pngRepresentation

        XCTAssertNotEqual(firstPoster, secondPoster)
    }

    func testGameFinish() {
        sleep(2)

        for _ in 1...10 {
            app.buttons["No"].tap()
            sleep(2)
        }

        let alert = app.alerts["Game results"]

        XCTAssertTrue(alert.exists)
        XCTAssertEqual(alert.label, "Раунд окончен!")
        XCTAssertEqual(alert.buttons.firstMatch.label, "Сыграть ещё раз")
        
        print(app.debugDescription)
    }

    func testAlertDismiss() {
        sleep(2)

        for _ in 1...10 {
            app.buttons["No"].tap()
            sleep(2)
        }

        let alert = app.alerts["Game results"]
        alert.buttons.firstMatch.tap()

        sleep(2)

        let indexLabel = app.staticTexts["Index"]

        XCTAssertFalse(alert.exists)
        XCTAssertEqual(indexLabel.label, "1/10")
    }
}
