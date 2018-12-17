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
func applicationSupportURL() -> URL {
    return try! FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
    
}

struct Constants {
    static let settingsFilename = "settings"
    struct Default {
        static let days = 7
    }
}

open class MacTrial {

    /// The full path to the settings file in Application Support
    /// 
    open var settingsURL: URL = {
        return applicationSupportURL().appendingPathComponent(Constants.settingsFilename)
    }()
    
    /// Create a Codable struct
    /// Save to disk
    /// Load from disk
    /// Save to disk on first start (init)
    /// If already saved, then load and check valid
    /// Provide a boolean check to know if app is expiried or not
    
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
    var trialPeriodInDays: Int
    
    init(dateInstalled: Date = Date(), trialPeriodInDays days: Int = Constants.Default.days) {
        self.dateInstalled = dateInstalled
        self.trialPeriodInDays = days
        self.dateExpired = createDate(byAddingDays: days, to: dateInstalled)
    }
    
}
