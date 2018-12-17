//
//  MacTrial_Library_Tests.swift
//  MacTrial Library Tests
//
//  Created by Paul Solt on 12/8/18.
//  Copyright © 2018 Paul Solt. All rights reserved.
//

import XCTest
@testable import Mac_Trial_Library


class TestDirectory_Tests: XCTestCase {
    
    
    
}

class MacTrial_Library_Tests: XCTestCase {
    
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
        return MacTrial.settingsDirectory
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
    
    
    func testCreateUnitTestDirectory() {
//        settings
    }
    
    func testCleanupUnitTestDirectory() {
        
    }
    
    
    func testSaveFile() {
        let string = "BLAH"
        
        let settingsURL = MacTrial.settingsDirectory.appendingPathComponent(Constants.settingsFilename)
        
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
    

    // Test Helpers
    
//    func createTrialSettings(dateInstalled: Date = Date(), days: Int = Constants.Default.days) -> TrialSettings {
//        let settings = TrialSettings(dateInstalled: dateInstalled, trialPeriodInDays: days)
//        return settings
//    }
    
    func testLoadSettings() {
        var trialSettings = TrialSettings()
        trialSettings.trialPeriodInDays = 20
        
        let data = try! encoder.encode(trialSettings)
        let url = applicationSupportURL().appendingPathComponent(Constants.settingsFilename)
        try! data.write(to: url, options: .atomicWrite)
        
        do {
            let loadedSettings = try MacTrial.loadSettings()
            XCTAssertEqual(trialSettings, loadedSettings)
        } catch {
            print("Failed to load TrialSettings from disk")
        }
        
        // TODO: Cleanup file between tests
    }
    
    func testChangeTrialPeriodShouldUpdateDateExpired() {
        var trialSettings = TrialSettings(dateInstalled: dateInstalled, trialPeriodInDays: Constants.Default.days)
        let newDays = 30
        let expectedDate = createDate(byAddingDays: newDays, to: dateInstalled)
        
        trialSettings.trialPeriodInDays = newDays
        
        XCTAssertEqual(expectedDate, trialSettings.dateExpired)
    }
    
    // TODO:
    /// TODO:
    /// Load from disk
    /// Save to disk on first start (init)
    /// If already saved, then load and check valid
    /// Provide a boolean check to know if app is expiried or not

    // Check if the trial has expired
    
    // Extend the trial period
    // Track number of opens
    // Track number of uses
    // Track number of social shares for extensions
}

extension MacTrial_Library_Tests {
    
}
