//
//  AppTrial.swift
//  AppTrial Library
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
func applicationSupportURL() -> URL {
    return try! FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
}

public typealias DateGenerator = () -> Date

fileprivate let settingsDirectory = "settings"
fileprivate let settingsFilename = "settings.json"
fileprivate let defaultDirectory: URL = applicationSupportURL().appendingPathComponent(settingsDirectory, isDirectory: true)
fileprivate let defaultSettingsFile: URL = defaultDirectory.appendingPathComponent(settingsFilename)

open class AppTrial {
    var dateGenerator: DateGenerator
    var formatter: DateComponentsFormatter
    
    var settingsFile: URL = defaultSettingsFile
    private(set) var settings: TrialSettings = TrialSettings()
    
    public init(dateGenerator: @escaping DateGenerator = Date.init,
                formatter: DateComponentsFormatter = defaultDateComponentFormatter()) {
        self.dateGenerator = dateGenerator
        self.formatter = formatter
        
        loadOrCreateSettings()
        saveToDisk()
    }
    
    public static func defaultDateComponentFormatter() -> DateComponentsFormatter {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .full
        formatter.includesApproximationPhrase = true
        formatter.allowedUnits = [.day, .hour]
        return formatter
    }
    
    public func isExpired() -> Bool {
        return dateGenerator() > settings.dateExpired
    }
    
    public func dateExpired() -> Date {
        return settings.dateExpired
    }

    public func dateInstalled() -> Date {
        return settings.dateInstalled
    }
    
    public func extendTrial(byAdding days: Int) {
        settings = settings.extended(byAddingDays: days)
        saveToDisk()
    }
    
    public func daysRemaining() -> String {
        var result = ""
        if !isExpired() {
            formatter.includesApproximationPhrase = true
            formatter.allowedUnits = [.day, .hour]
            let duration = formatter.string(from: dateGenerator(), to: dateExpired())!
            result = duration.lowercased()
        } else {
            formatter.includesApproximationPhrase = false
            formatter.allowedUnits = [.day]
            let duration = formatter.string(from: 0)!
            result = duration.lowercased()
        }
        return result
    }
    
    public func totalDays() -> Int {
        return settings.trialPeriodInDays
    }
    
    private func loadOrCreateSettings() {
        do {
            settings = try loadSettings()
        } catch {
            print("Error: failed to load settings: \(settingsFile)")
            settings = createDefaultSettings()
        }
    }
    
    public func reloadFromDisk() {
        if let settings = try? loadSettings() {
            self.settings = settings
        }
    }
    
    public func resetTrialPeriod() {
        settings = createDefaultSettings()
        saveToDisk()
    }
    
    public func expireTrial() {
        settings.trialPeriodInDays = -1
        saveToDisk()
    }

    private func saveToDisk() {
        do {
            try saveSettings(settings: settings)
        } catch {
            print("Error: failed to save settings: \(settingsFile)")
        }
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
        return TrialSettings(dateInstalled: dateGenerator())
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


/// Settings structure for tracking trial period in an app
public struct TrialSettings: Codable, Equatable {
    public static let defaultDurationInDays = 7

    public let dateInstalled: Date
    public private(set) var dateExpired: Date
    public var trialPeriodInDays: Int {
        didSet {
            self.dateExpired = createDate(byAddingDays: trialPeriodInDays, to: dateInstalled)
        }
    }
    
    public init(dateInstalled: Date = Date(), trialPeriodInDays days: Int = defaultDurationInDays) {

        self.dateInstalled = dateInstalled
        self.trialPeriodInDays = days
        self.dateExpired = createDate(byAddingDays: days, to: dateInstalled)
    }
    
    public func extended(byAddingDays days: Int) -> TrialSettings {
        let duration = trialPeriodInDays + days
        return TrialSettings(dateInstalled: dateInstalled, trialPeriodInDays: duration)
    }
}

func createDate(byAddingDays days: Int, to date: Date) -> Date {
    return Calendar.current.date(byAdding: .day, value: days, to: date)!
}

