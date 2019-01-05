//
//  AppTrialTests.swift
//  AppTrialTests
//
//  Created by Paul Solt on 12/18/18.
//  Copyright © 2018 Paul Solt. All rights reserved.
//

import XCTest

@testable import AppTrial

/// A testing class to step forward in time so that we can
// verify date logic
class TimeTraveler {
    private let daysInSeconds: TimeInterval = 86_400
    
    var date = Date()
    
    func generateDate() -> Date {
        return date
    }
    
    func timeTravel(bySeconds seconds: TimeInterval) {
        date = date.addingTimeInterval(seconds)
    }
    
    func timeTravel(byDays days: Int) {
        date = date.addingTimeInterval(daysInSeconds * TimeInterval(days))
    }
}

class AppTrialTests: XCTestCase {
    
    var days = 14
    var dateInstalled = Date()
    
    var encoder = JSONEncoder()
    var decoder = JSONDecoder()
    var fileManager = FileManager()
    
    var timeTraveler = TimeTraveler()
    var appTrial = AppTrial()
    
    override func setUp() {
        encoder = JSONEncoder()
        decoder = JSONDecoder()
        dateInstalled = Date()
        fileManager = FileManager()
        timeTraveler = TimeTraveler()
        appTrial = AppTrial()
        appTrial.dateGenerator = timeTraveler.generateDate
        
        setupTestDirectory()
    }
    
    override func tearDown() {
        removeTestDirectory()
    }
    
    func testDirectory() -> URL {
        return appTrial.settingsFile.deletingLastPathComponent()
    }
    
    func setupTestDirectory() {
        if doesTestDirectoryExist() {
            removeTestDirectory()
        }
        createTestDirectory()
    }
    
    func doesTestDirectoryExist() -> Bool {
        return fileManager.fileExists(atPath: testDirectory().path)
    }
    
    func createTestDirectory() {
        do {
            try fileManager.createDirectory(at: testDirectory(), withIntermediateDirectories: true, attributes: nil)
        } catch {
            print("Failed to create settings directory: \(testDirectory())")
        }
    }
    
    func removeTestDirectory() {
        do {
            try fileManager.removeItem(at: testDirectory())
        } catch {
            print("Failed to remove settings directory: \(testDirectory())")
        }
    }
    
    
    func testCreateTestDirectory() {
        removeTestDirectory()
        
        createTestDirectory()
        
        XCTAssertTrue(fileManager.fileExists(atPath: testDirectory().path))
    }
    
    func testRemoveTestDirectory() {
        XCTAssertTrue(fileManager.fileExists(atPath: testDirectory().path))
        
        removeTestDirectory()
        
        XCTAssertFalse(fileManager.fileExists(atPath: testDirectory().path))
    }
    
    
    func testSaveFile() {
        let string = "save me to disk"
        let settingsURL = appTrial.settingsFile
        
        do {
            try string.write(to: settingsURL, atomically: true, encoding: .utf8)
        } catch {
            print("ERROR: saving file: \(settingsURL) \(error)")
        }
        
        var input = ""
        do {
            input = try String(contentsOf: settingsURL)
        } catch {
            print("ERROR: loading file: \(settingsURL) \(error)")
        }
        XCTAssertEqual(string, input)
    }
    
    func testStoreInstallDate() {
        let trialSettings = TrialSettings(dateInstalled: dateInstalled)
        
        XCTAssertEqual(dateInstalled, trialSettings.dateInstalled)
    }
    
    func testSetExpireDays() {
        let dateExpired = Calendar.current.date(byAdding: .day, value: days, to: dateInstalled)
        
        let trialSettings = TrialSettings(dateInstalled: dateInstalled, trialPeriodInDays: days)
        
        XCTAssertEqual(dateExpired, trialSettings.dateExpired)
    }
    
    func testCodable() {
        let trialSettings = TrialSettings(dateInstalled: dateInstalled, trialPeriodInDays: days)
        
        do {
            let jsonData = try encoder.encode(trialSettings)
            let decodedSettings = try decoder.decode(TrialSettings.self, from: jsonData)
            
            XCTAssertEqual(trialSettings, decodedSettings)
        } catch {
            XCTFail("Failed to encode or decode JSON data")
        }
    }
    
    func testLoadSettings() {
        var trialSettings = TrialSettings()
        trialSettings.trialPeriodInDays = 20
        
        do {
            let data = try encoder.encode(trialSettings)
            try data.write(to: appTrial.settingsFile, options: .atomicWrite)
            
            let loadedSettings = try appTrial.loadSettings()
            
            XCTAssertEqual(trialSettings, loadedSettings)
        } catch {
            XCTFail("Failed to load TrialSettings from disk: \(error)")
        }
    }
    
    func testLoadSettingsWithoutSavedFile() {
        let defaultSettings = TrialSettings(dateInstalled: timeTraveler.date)
        
        do {
            let loadedSettings = try appTrial.loadSettings()
            
            XCTAssertEqual(defaultSettings, loadedSettings)
        } catch {
            XCTFail("Failed to load TrialSettings from disk: \(error)")
        }
    }
    
    func testChangeTrialPeriodShouldUpdateDateExpired() {
        var trialSettings = TrialSettings(dateInstalled: dateInstalled, trialPeriodInDays: 7)
        let newDays = 30
        let expectedDate = createDate(byAddingDays: newDays, to: dateInstalled)
        
        trialSettings.trialPeriodInDays = newDays
        
        XCTAssertEqual(expectedDate, trialSettings.dateExpired)
    }
    
    func testSaveSettings() {
        var trialSettings = TrialSettings()
        trialSettings.trialPeriodInDays = 17
        
        do {
            try appTrial.saveSettings(settings: trialSettings)
            
            let loadedSettings = try appTrial.loadSettings()
            XCTAssertEqual(trialSettings, loadedSettings)
        } catch {
            XCTFail("Failed to load or save settings: \(error)")
        }
    }
    
    func testSaveSettingsCreatesDirectoryIfItDoesNotExist() {
        var trialSettings = TrialSettings()
        trialSettings.trialPeriodInDays = 17
        removeTestDirectory()
        let settingsDirectoryPath = appTrial.settingsFile.deletingLastPathComponent().path
        
        do {
            try appTrial.saveSettings(settings: trialSettings)
            
            XCTAssertTrue(fileManager.fileExists(atPath: settingsDirectoryPath))
            XCTAssertTrue(fileManager.fileExists(atPath: appTrial.settingsFile.path))
        } catch {
            XCTFail("Failed to create save folder: \(error)")
        }
    }
    
    func testLoadSettingsCreatesDefaultIfItDoesNotExist() {
        let expectedSettings = TrialSettings(dateInstalled: timeTraveler.date)
        removeTestDirectory()
        
        do {
            let loadedSettings = try appTrial.loadSettings()
            
            XCTAssertEqual(expectedSettings, loadedSettings)
        } catch {
            XCTFail("Default settings need to be loaded on first try")
        }
    }
    
    func testTrialSettingsIsNotExpiredOnStart() {
        let settings = TrialSettings(dateInstalled: timeTraveler.date, trialPeriodInDays: days)
        try! appTrial.saveSettings(settings: settings)
        
        XCTAssertFalse(appTrial.isExpired())
    }
    
    func testTrialSettingsIsNotExpiredAfter7Days() {
        let settings = TrialSettings(dateInstalled: timeTraveler.date, trialPeriodInDays: days)
        try! appTrial.saveSettings(settings: settings)
        timeTraveler.timeTravel(byDays: 7)
        
        XCTAssertFalse(appTrial.isExpired())
    }
    
    func testTrialSettingsIsExpiredAfter7DaysPlus1Second() {
        let settings = TrialSettings(dateInstalled: timeTraveler.date, trialPeriodInDays: days)
        try! appTrial.saveSettings(settings: settings)
        timeTraveler.timeTravel(byDays: 7)
        timeTraveler.timeTravel(bySeconds: 1)
        
        XCTAssertTrue(appTrial.isExpired())
    }
    
    func testTrialSettingsExtendedBy20Days() {
        let settings = TrialSettings(dateInstalled: timeTraveler.date, trialPeriodInDays: 7)
        let expectedSettings = TrialSettings(dateInstalled: timeTraveler.date, trialPeriodInDays: 27)
        
        let actualSettings = settings.extended(byAddingDays: 20)
        
        XCTAssertEqual(expectedSettings, actualSettings)
    }
    
    func testExtendTrialByAdding30DaysAndSavesToDisk() {
        let totalDays = appTrial.settings.trialPeriodInDays + 30
        let expectedExpired = createDate(byAddingDays: totalDays, to: appTrial.settings.dateInstalled)
        appTrial.extendTrial(byAdding: 30)
        
        XCTAssertEqual(expectedExpired, appTrial.dateExpired())
        
        do {
            let loadedSettings = try appTrial.loadSettings()
            XCTAssertEqual(expectedExpired, loadedSettings.dateExpired)
        } catch {
            XCTFail("Loading settings failed")
        }
    }
    
    func testDaysRemainingAfterTimeTraveling() {
        timeTraveler.timeTravel(byDays: 2)
        XCTAssertEqual(5, appTrial.daysRemaining())
        
        timeTraveler.timeTravel(bySeconds: 1)
        XCTAssertEqual(4, appTrial.daysRemaining())

        timeTraveler.timeTravel(bySeconds: -2)
        XCTAssertEqual(5, appTrial.daysRemaining())

        timeTraveler.timeTravel(bySeconds: 1)
        XCTAssertEqual(5, appTrial.daysRemaining())

        timeTraveler.timeTravel(byDays: 2)
        XCTAssertEqual(3, appTrial.daysRemaining())
        
        timeTraveler.timeTravel(byDays: 3)
        XCTAssertEqual(0, appTrial.daysRemaining())
        
        timeTraveler.timeTravel(byDays: 1)
        timeTraveler.timeTravel(bySeconds: 1)
        XCTAssertEqual(-1, appTrial.daysRemaining())
    }
    
    
    // TODO: Track number of opens
    // TODO: Track number of uses
    // TODO: Track number of social shares for extensions (Or just extend based on action)
}
