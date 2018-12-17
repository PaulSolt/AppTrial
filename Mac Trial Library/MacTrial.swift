//
//  MacTrial.swift
//  Mac Trial Library
//
//  Created by Paul Solt on 12/8/18.
//  Copyright © 2018 Paul Solt. All rights reserved.
//

import Foundation

// Helper functions

/// Creates a path to the Application Support folder
/// On Mac apps it should be of the form:
/// `/Users/paulsolt/Library/Containers/com.PaulSolt.Mac-Trial-Demo/Data/Library/Application%20Support/`
///
/// In unit tests it will be:
/// `/Users/paulsolt/Library/Application%20Support/`
///


func isUnitTestDirectory() -> Bool {
    if ProcessInfo.processInfo.environment.keys.contains("XCTestConfigurationFilePath") {
        return true
    }
    return false
}

func applicationSupportURL(isTestDirectory: Bool = isUnitTestDirectory()) -> URL {
    return try! FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
}


    
    // For each test
    // Create a temporary directory
    // Run the test

class MacUnitTestHelper {
    var testDirectory: URL
    var fileManager = FileManager.default
    
    init() {
//        Bundle.main.
        testDirectory = URL(fileURLWithPath: "empty")
        createUnitTestDirectory()
    }
    
    
    func createUnitTestDirectory(url: URL = FileManager.default.temporaryDirectory) {
        self.testDirectory = url
    }
    
    func clearUnitTestDirectory() {
        do {
            try fileManager.removeItem(at: testDirectory)
        } catch {
            print("Error removing the test directory: \(testDirectory)")
        }
    }
}

func createTestDirectory() {
    
}
func testDirectory() -> URL {
    return FileManager.default.temporaryDirectory
}




struct Constants {
    static let settingsFilename = "settings.json" // TODO: Change to settings for "security"
    struct Default {
        static let days = 7
    }
}

open class MacTrial {

    public static var settingsDirectory: URL = {
        return applicationSupportURL().appendingPathComponent("settings", isDirectory: true)
    }()
    
    /// The full path to the settings file in Application Support
    /// 
    public static var settingsURL: URL = {
        return settingsDirectory.appendingPathComponent(Constants.settingsFilename)
    }()
    
    /// Create a Codable struct
    /// Save to disk
    /// Load from disk
    /// Save to disk on first start (init)
    /// If already saved, then load and check valid
    /// Provide a boolean check to know if app is expiried or not
    
    
    static func loadSettings() throws -> TrialSettings {
        let decoder = JSONDecoder()
//        decoder.dateDecodingStrategy = .secondsSince1970
        
        let data = try Data(contentsOf: settingsURL)
        
        let settings = try decoder.decode(TrialSettings.self, from: data)
        return settings
    }
}


/// NOTE: In some situtations with different calendars or end time scenarios
/// this may fail, but it should work for small offsets between 7-365 days
func createDate(byAddingDays days: Int, to date: Date) -> Date {
    return Calendar.current.date(byAdding: .day, value: days, to: date)!
}

/// Settings structure for tracking trial period in an app
struct TrialSettings: Codable, Equatable {
    var dateInstalled: Date
    var dateExpired: Date
    var trialPeriodInDays: Int {
        didSet {
            dateExpired = createDate(byAddingDays: trialPeriodInDays, to: dateInstalled)
        }
    }
    
    init(dateInstalled: Date = Date(), trialPeriodInDays days: Int = Constants.Default.days) {
        self.dateInstalled = dateInstalled
        self.trialPeriodInDays = days
        self.dateExpired = createDate(byAddingDays: days, to: dateInstalled)
    }
    

}
