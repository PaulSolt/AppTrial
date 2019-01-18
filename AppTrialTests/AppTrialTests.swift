//
//  AppTrialTests.swift
//  AppTrialTests
//
//  Created by Paul Solt on 12/18/18.
//  Copyright © 2018 Paul Solt. All rights reserved.
//

import XCTest

@testable import AppTrial

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
        appTrial = AppTrial(dateGenerator: timeTraveler.generateDate)
        
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
    
//    func testDaysRemainingAfterTimeTraveling() {
//        timeTraveler.timeTravel(byDays: 2)
//        XCTAssertEqual(5, appTrial.daysRemaining())
//
//        timeTraveler.timeTravel(bySeconds: 1)
//        XCTAssertEqual(4, appTrial.daysRemaining())
//
//        timeTraveler.timeTravel(bySeconds: -2)
//        XCTAssertEqual(5, appTrial.daysRemaining())
//
//        timeTraveler.timeTravel(bySeconds: 1)
//        XCTAssertEqual(5, appTrial.daysRemaining())
//
//        timeTraveler.timeTravel(byDays: 2)
//        XCTAssertEqual(3, appTrial.daysRemaining())
//
//        timeTraveler.timeTravel(byDays: 3)
//        XCTAssertEqual(0, appTrial.daysRemaining())
//
//        timeTraveler.timeTravel(byDays: 1)
//        timeTraveler.timeTravel(bySeconds: 1)
//        XCTAssertEqual(-1, appTrial.daysRemaining())
//    }
//
//    func testDaysRemainingIncludesPartialTime() {
//        let seconds: TimeInterval = 60 * 60 * 12
//        timeTraveler.timeTravel(bySeconds: seconds)
//
//        XCTAssertEqual(Double(appTrial.daysRemaining()), 6.5, accuracy: 0.1)
//
//    }
    
    func createFixedDate() -> Date {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let components = DateComponents(year: 2018, month: 1, day: 18)
        return calendar.date(from: components)!
    }
    
    func testDaysRemainingExpiresInAbout7Days() {
        timeTraveler.date = createFixedDate()
        appTrial = AppTrial(dateGenerator: timeTraveler.generateDate)
        
        XCTAssertEqual("about 7 days", appTrial.daysRemaining())
    }
    
    func testDateInstalled() {
        XCTAssertEqual(appTrial.dateInstalled(), appTrial.settings.dateInstalled)
    }
    
    func testTotalDays() {
        XCTAssertEqual(appTrial.totalDays(), appTrial.settings.trialPeriodInDays)
    }
    
    func testDaysRemainingExpiresInAbout6Days12Hours() {
        let date = createFixedDate()
        timeTraveler.date = date
        appTrial = AppTrial(dateGenerator: timeTraveler.generateDate)
        
        timeTraveler.timeTravel(bySeconds: 60 * 60 * 12)

        XCTAssertEqual("about 6 days, 12 hours", appTrial.daysRemaining())
    }
    
    func testDaysRemainingExpiresInAbout12Hours() {
        let date = createFixedDate()
        timeTraveler.date = date
        appTrial = AppTrial(dateGenerator: timeTraveler.generateDate)
        
        timeTraveler.timeTravel(bySeconds: 60 * 60 * 12)
        timeTraveler.timeTravel(byDays: 6)
        
        print("dateGenerator: \(appTrial.dateGenerator())")
        
        XCTAssertEqual("about 12 hours", appTrial.daysRemaining())
    }
    
    func testDaysRemainingExpired() {
        let date = createFixedDate()
        timeTraveler.date = date
        appTrial = AppTrial(dateGenerator: timeTraveler.generateDate)
        
//        timeTraveler.timeTravel(bySeconds: 60 * 60 * 12)
        timeTraveler.timeTravel(byDays: 7)
        timeTraveler.timeTravel(bySeconds: 1)
        
        print("dateGenerator: \(appTrial.dateGenerator())")
        
        XCTAssertEqual("0 days", appTrial.daysRemaining())
    }
    
    func testExpireTrialExpiresInMemoryAndFromDisk() {
        appTrial.expireTrial()
        
        XCTAssertTrue(appTrial.isExpired())
        
        appTrial.reloadFromDisk()
        XCTAssertTrue(appTrial.isExpired())
    }
    
    func testResetTrialPeriodInMemoryAndFromDisk() {
        let dateExpired = createDate(byAddingDays: 7, to: timeTraveler.date)
        appTrial.expireTrial()

        appTrial.resetTrialPeriod()

        XCTAssertEqual(timeTraveler.date, appTrial.dateInstalled())
        XCTAssertEqual(dateExpired, appTrial.dateExpired())
  
        appTrial.reloadFromDisk()
        
        XCTAssertEqual(timeTraveler.date, appTrial.dateInstalled())
        XCTAssertEqual(dateExpired, appTrial.dateExpired())
    }
}
