//
//  MacTrial.swift
//  Mac Trial Library
//
//  Created by Paul Solt on 12/8/18.
//  Copyright © 2018 Paul Solt. All rights reserved.
//

import Foundation

/// Creates a path to the Application Support folder
/// On Mac apps it should be of the form:
/// `/Users/paulsolt/Library/Containers/com.PaulSolt.Mac-Trial-Demo/Data/Library/Application%20Support/`
///
/// In unit tests it will be:
/// `/Users/paulsolt/Library/Application%20Support/`
///
func applicationSupportURL() -> URL {
    return try! FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
}

typealias DateGenerator = () -> Date

fileprivate let settingsDirectory = "settings"
fileprivate let settingsFilename = "settings.json"
fileprivate let defaultDays = 7

open class TryMyApp {
    
    // TODO: refactor constnats to this file
    

    var dateGenerator: DateGenerator = Date.init
    var settingsFile: URL = TryMyApp.defaultSettingsFile

    private var settings: TrialSettings!
    
    public init() {
        // Load settings or create a new settings if it does not exist
        do {
            settings = try loadSettings()
        } catch {
            print("Error: failed to load settings: \(settingsFile)")
            settings = createDefaultSettings()
        }
        
        // Save settings file to disk on start
        do {
            try saveSettings(settings: settings)
        } catch {
            print("Error: failed to save settings: \(settingsFile)")
        }
    }
    
    private static var defaultDirectory: URL = applicationSupportURL().appendingPathComponent(settingsDirectory, isDirectory: true)
    
    private static var defaultSettingsFile: URL = defaultDirectory.appendingPathComponent(settingsFilename)
    
    public func isExpired() -> Bool {
        return dateGenerator() > settings.dateExpired
    }
    
    public func dateExpired() -> Date {
        return settings.dateExpired
    }
    
    public func loadSettings() throws -> TrialSettings {
        if settingsExists() {
            let data = try loadSettingsFrom(url: settingsFile)
            return try decodeSettings(from: data)
        }
        return createDefaultSettings()
    }
    
    fileprivate func settingsExists() -> Bool {
        return FileManager.default.fileExists(atPath: settingsFile.path)
    }
    
    fileprivate func loadSettingsFrom(url: URL) throws -> Data {
        return try Data(contentsOf: settingsFile)
    }
    
    fileprivate func decodeSettings(from data: Data) throws -> TrialSettings {
        let decoder = JSONDecoder()
        return try decoder.decode(TrialSettings.self, from: data)
    }
 
    fileprivate func createDefaultSettings() -> TrialSettings {
        return TrialSettings(dateInstalled: dateGenerator(), trialPeriodInDays: defaultDays)
    }
    
    public func saveSettings(settings: TrialSettings) throws {
        let data = try encodeSettings(settings: settings)
        try createSettingsDirectoryIfMissing()
        try saveSettings(data: data, to: settingsFile)
    }
    
    fileprivate func encodeSettings(settings: TrialSettings) throws -> Data {
        let encoder = JSONEncoder()
        return try encoder.encode(settings)
    }
    
    fileprivate func createSettingsDirectoryIfMissing() throws {
        if !settingsDirectoryExists() {
            try createSettingsDirectory()
        }
    }
    
    fileprivate func settingsDirectoryExists() -> Bool {
        let settingsDirectoryPath = settingsFile.deletingLastPathComponent().path
        return FileManager.default.fileExists(atPath: settingsDirectoryPath)
    }
    
    fileprivate func createSettingsDirectory() throws {
        let settingsDirectoryPath = settingsFile.deletingLastPathComponent().path
        try FileManager.default.createDirectory(atPath: settingsDirectoryPath, withIntermediateDirectories: true, attributes: nil)
    }

    fileprivate func saveSettings(data: Data, to url: URL) throws {
        try data.write(to: url, options: .atomic)
    }
}

func createDate(byAddingDays days: Int, to date: Date) -> Date {
    return Calendar.current.date(byAdding: .day, value: days, to: date)!
}

/// Settings structure for tracking trial period in an app
public struct TrialSettings: Codable, Equatable {
    var dateInstalled: Date
    var dateExpired: Date
    var trialPeriodInDays: Int {
        didSet {
            changeTrialDuration(to: trialPeriodInDays)
        }
    }
    
    init(dateInstalled: Date = Date(), trialPeriodInDays days: Int = defaultDays) {
        self.dateInstalled = dateInstalled
        self.trialPeriodInDays = days
        self.dateExpired = createDate(byAddingDays: days, to: dateInstalled)
    }
    
    private mutating func changeTrialDuration(to days: Int) {
        dateExpired = createDate(byAddingDays: trialPeriodInDays, to: dateInstalled)
    }
}
