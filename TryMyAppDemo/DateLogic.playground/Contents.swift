import Cocoa

var str = "Hello, playground"

let cal = Calendar.current
let d1 = Date()



let d2 = Date.init(timeIntervalSince1970: 1524787200) // April 27, 2018 12:00:00 AM
let components = cal.dateComponents([.hour], from: d2, to: d1)
var diff = components.hour!


let comp = cal.dateComponents([.day], from: d2, to: d1)
diff = comp.day!


let currentDate = Date()

let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: currentDate)!
let sevenDaysFuture = Calendar.current.date(byAdding: .day, value: 7, to: currentDate)!

print("Today:\t\(currentDate)")
print("7 Days:\t\(sevenDaysFuture)")

let justBefore = sevenDaysFuture.addingTimeInterval(-1)
let justAfter = sevenDaysFuture.addingTimeInterval(1)

if justBefore < sevenDaysFuture {
    print("Just before: \(justBefore)")
}

if justAfter > sevenDaysFuture {
    print("Just after: \(justAfter)")
}

// Store a date for 7 days in the future in JSON
// Verify stored date is less than current date
// Test with TimeTraveler
// Abstract logic for date testing
// Make it so I don't need to rebuild the app
// Where can I securely store date?
// Store in NSUserDefaults, make it simple, make it work
// We want to get this feature out to market as fast as possible, so that we can start making money, push people to the mac app store
struct Beta: Codable {
    let expireDate: Date
    let installDate: Date
}


// https://stackoverflow.com/questions/14534319/implement-free-trial-period-in-ios

func storeDate(date: Date = Date()) {
    
}


/// Save location

//FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: <#T##URL?#>, create: <#T##Bool#>)

// When can this fail?
// What's the appropriateFor attribute? Volume (i.e. which hard drive)

//do {
//    let url = try FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
//    // Can this be nil???
//    // I don't think so ... crash if it isn't
//} catch {
//    print("Error: unable to access Application Support Directory: \(url)")
//}

let url = try! FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)


print("URL: \(url)")
