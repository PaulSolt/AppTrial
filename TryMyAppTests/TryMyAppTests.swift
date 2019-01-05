//
//  TryMyAppTests.swift
//  TryMyAppTests
//
//  Created by Paul Solt on 12/18/18.
//  Copyright © 2018 Paul Solt. All rights reserved.
//

import XCTest

//@testable import TryMyApp

@testable import TryMyApp

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

class TryMyAppTests: XCTestCase {
    
    var days = 14
    var dateInstalled = Date()
    
    var encoder = JSONEncoder()
    var decoder = JSONDecoder()
    var fileManager = FileManager()
    
    var timeTraveler = TimeTraveler()
    var tryMyApp = TryMyApp()
    
    override func setUp() {
        encoder = JSONEncoder()
        decoder = JSONDecoder()
        dateInstalled = Date()
        fileManager = FileManager()
        timeTraveler = TimeTraveler()
        tryMyApp = TryMyApp()
        tryMyApp.dateGenerator = timeTraveler.generateDate
        
        setupTestDirectory()
    }
    
    override func tearDown() {
        removeTestDirectory()
    }
    
    func testDirectory() -> URL {
        return tryMyApp.settingsFile.deletingLastPathComponent()
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
        let settingsURL = tryMyApp.settingsFile
        
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
            try data.write(to: tryMyApp.settingsFile, options: .atomicWrite)
            
            let loadedSettings = try tryMyApp.loadSettings()
            
            XCTAssertEqual(trialSettings, loadedSettings)
        } catch {
            XCTFail("Failed to load TrialSettings from disk: \(error)")
        }
    }
    
    func testLoadSettingsWithoutSavedFile() {
        let defaultSettings = TrialSettings(dateInstalled: timeTraveler.date)
        
        do {
            let loadedSettings = try tryMyApp.loadSettings()
            
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
            try tryMyApp.saveSettings(settings: trialSettings)
            
            let loadedSettings = try tryMyApp.loadSettings()
            XCTAssertEqual(trialSettings, loadedSettings)
        } catch {
            XCTFail("Failed to load or save settings: \(error)")
        }
    }
    
    func testSaveSettingsCreatesDirectoryIfItDoesNotExist() {
        var trialSettings = TrialSettings()
        trialSettings.trialPeriodInDays = 17
        removeTestDirectory()
        let settingsDirectoryPath = tryMyApp.settingsFile.deletingLastPathComponent().path
        
        do {
            try tryMyApp.saveSettings(settings: trialSettings)
            
            XCTAssertTrue(fileManager.fileExists(atPath: settingsDirectoryPath))
            XCTAssertTrue(fileManager.fileExists(atPath: tryMyApp.settingsFile.path))
        } catch {
            XCTFail("Failed to create save folder: \(error)")
        }
    }
    
    func testLoadSettingsCreatesDefaultIfItDoesNotExist() {
        let expectedSettings = TrialSettings(dateInstalled: timeTraveler.date)
        removeTestDirectory()
        
        do {
            let loadedSettings = try tryMyApp.loadSettings()
            
            XCTAssertEqual(expectedSettings, loadedSettings)
        } catch {
            XCTFail("Default settings need to be loaded on first try")
        }
    }
    
    func testTrialSettingsIsNotExpiredOnStart() {
        let settings = TrialSettings(dateInstalled: timeTraveler.date, trialPeriodInDays: days)
        try! tryMyApp.saveSettings(settings: settings)
        
        XCTAssertFalse(try! tryMyApp.isExpired())
    }
    
    func testTrialSettingsIsNotExpiredAfter7Days() {
        let settings = TrialSettings(dateInstalled: timeTraveler.date, trialPeriodInDays: days)
        try! tryMyApp.saveSettings(settings: settings)
        timeTraveler.timeTravel(byDays: 7)
        
        XCTAssertFalse(try! tryMyApp.isExpired())
    }
    
    func testTrialSettingsIsExpiredAfter7DaysPlus1Second() {
        let settings = TrialSettings(dateInstalled: timeTraveler.date, trialPeriodInDays: days)
        try! tryMyApp.saveSettings(settings: settings)
        timeTraveler.timeTravel(byDays: 7)
        timeTraveler.timeTravel(bySeconds: 1)
        
        XCTAssertTrue(try! tryMyApp.isExpired())
        
    }
    
    /// TODO: App Load from disk
    /// TODO: App Save to disk on first start (init)
    /// TODO: If already saved, then load and check valid
    /// TODO: Provide a boolean check() to know if app is expiried or not
    // TODO: Track number of opens
    // TODO: Track number of uses
    // TODO: Track number of social shares for extensions (Or just extend based on action)
}
