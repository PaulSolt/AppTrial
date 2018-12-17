//
//  MacTrial_Library_Tests.swift
//  MacTrial Library Tests
//
//  Created by Paul Solt on 12/8/18.
//  Copyright © 2018 Paul Solt. All rights reserved.
//

import XCTest
@testable import Mac_Trial_Library

class MacTrial_Library_Tests: XCTestCase {
    
    var days = 7
    var dateInstalled = Date()
    
    var encoder = JSONEncoder()
    var decoder = JSONDecoder()
    
    override func setUp() {
        encoder = JSONEncoder()
        decoder = JSONDecoder()
        dateInstalled = Date()
    }
    
//    func testCreateDate7DaysIntoFuture() {
//        let date = Date()
//        let days = 7
//        let expectedDate = Calendar.current.date(byAdding: .day, value: days, to: date)
//
//        let actualDate = trial.createDate(byAdding: days, to: date)
//
//        XCTAssertEqual(actualDate, expectedDate)
//    }
    
    func testSaveFile() {
        let string = "BLAH"
        
        let saveFolder = try! FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        
        let url = saveFolder.appendingPathComponent("settingsPDA.json")
        print("Save: \(url)")

        do {
            try string.write(to: url, atomically: true, encoding: .utf8)
        } catch {
            print("ERROR: saving file: \(url) \(error)")
        }
        
        var input = ""
        do {
            input = try String(contentsOf: url)
        } catch {
            print("ERROR: loading file: \(url) \(error)")
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
    
    func createTrialSettings(dateInstalled: Date = Date(), days: Int = Constants.Default.days) -> TrialSettings {
        let settings = TrialSettings(dateInstalled: dateInstalled, trialPeriodInDays: days)
        return settings
    }
    
    func testSaveAndLoadData() {
        let trialSettings = createTrialSettings()

        
    }
    
    
    // Extend the trial period
    // Track number of opens
    // Track number of uses
    // Track number of social shares for extensions
}

extension MacTrial_Library_Tests {
    
}
