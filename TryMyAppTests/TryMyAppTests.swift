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

class TryMyAppTests: XCTestCase {
    
    var days = 7
    var dateInstalled = Date()
    
    var encoder = JSONEncoder()
    var decoder = JSONDecoder()
    var fileManager = FileManager()
    
    override func setUp() {
        encoder = JSONEncoder()
        decoder = JSONDecoder()
        dateInstalled = Date()
        fileManager = FileManager()
        // create settings directory
        
        setupTestDirectory()
        
    }
    
    override func tearDown() {
        removeTestDirectory()
    }
    
    func testDirectory() -> URL {
        return TryMyApp.settingsDirectory
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
        let string = "BLAH"
        
        let settingsURL = TryMyApp.settingsDirectory.appendingPathComponent(Constants.settingsFilename)
        
        print("Save: \(settingsURL)")
        print("Save path: \(settingsURL.path)")
        
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
        print("INPUT: \(input)")
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
            try data.write(to: TryMyApp.settingsURL, options: .atomicWrite)
            
            let loadedSettings = try TryMyApp.loadSettings()
            
            XCTAssertEqual(trialSettings, loadedSettings)
        } catch {
            print("Failed to load TrialSettings from disk \(error)")
        }
    }
    
    func testChangeTrialPeriodShouldUpdateDateExpired() {
        var trialSettings = TrialSettings(dateInstalled: dateInstalled, trialPeriodInDays: Constants.Default.days)
        let newDays = 30
        let expectedDate = createDate(byAddingDays: newDays, to: dateInstalled)
        
        trialSettings.trialPeriodInDays = newDays
        
        XCTAssertEqual(expectedDate, trialSettings.dateExpired)
    }
    
    func testSaveSettings() {
        var trialSettings = TrialSettings()
        trialSettings.trialPeriodInDays = 17
        
        do {
            try TryMyApp.saveSettings(settings: trialSettings)
            
            let loadedSettings = try TryMyApp.loadSettings()
            XCTAssertEqual(trialSettings, loadedSettings)
        } catch {
            XCTFail("Failed to load or save settings: \(error)")
        }
    }
    
    func testSaveSettingsCreatesDirectoryIfItDoesNotExist() {
        var trialSettings = TrialSettings()
        trialSettings.trialPeriodInDays = 17
        removeTestDirectory()
        
        do {
            try TryMyApp.saveSettings(settings: trialSettings)
            
            XCTAssertTrue(fileManager.fileExists(atPath: TryMyApp.settingsDirectory.path))
            XCTAssertTrue(fileManager.fileExists(atPath: TryMyApp.settingsURL.path))
        } catch {
            XCTFail("Failed to create save folder: \(error)")
        }
    }
    
    /// A testing class to step forward in time so that we can
    // verify date logic
    class TimeTraveler {
        var date = Date()

        func generateDate() -> Date {
            return date
        }
        
        func timeTravel(bySeconds seconds: TimeInterval) {
            date = date.addingTimeInterval(seconds)
        }
    }
    
    /// Testing time based logic requires the ability to share the same date, or
    /// method for generating dates
    func testLoadSettingsCreatesDefaultIfItDoesNotExist() {
        let timeTraveler = TimeTraveler()
        TryMyApp.dateGenerator = timeTraveler.generateDate
        var expectedSettings = TrialSettings(dateInstalled: timeTraveler.date)
        expectedSettings.trialPeriodInDays = Constants.Default.days
        removeTestDirectory()
        
        do {
            let loadedSettings = try TryMyApp.loadSettings()
            
            XCTAssertEqual(expectedSettings, loadedSettings)
        } catch {
            XCTFail("Default settings need to be loaded on first try")
        }
    }
    
    
    /// TODO:
    /// TODO: App Load from disk
    /// TODO: App Save to disk on first start (init)
    /// TODO: If already saved, then load and check valid
    /// TODO: Provide a boolean check() to know if app is expiried or not
    // TODO: Track number of opens
    // TODO: Track number of uses
    // TODO: Track number of social shares for extensions (Or just extend based on action)
}
