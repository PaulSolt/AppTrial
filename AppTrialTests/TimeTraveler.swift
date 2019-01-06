//
//  TimeTraveler.swift
//  AppTrialTests
//
//  Created by Paul Solt on 1/6/19.
//  Copyright © 2019 Paul Solt. All rights reserved.
//

import Foundation

/// A testing class to step forward in time so that we can
/// verify date logic
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
