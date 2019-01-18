# AppTrial

A library to make it easy to offer trial periods in macOS apps based on first install date.

## Dev Notes

Using TDD (Red Green Refactor) and principles from Clean Code (Uncle Bob) to write the logic.

The goal isn't bullet-proof trial security, instead it's to make it fast to create a Mac app that will have a trial period (or beta period). So that you can focus on developing a worthwhile app that doesn't live forever.

The timeout will allow you to ask users to upgrade to the full version (or download a new beta), by linking directly to the paid app on the Mac App Store, or using a service like [Paddle](https://paddle.com) to sell a license key.

I built this for my [Super Easy Timer](https://itunes.apple.com/us/app/super-easy-timer/id1353137878?ls=1&mt=12) app, which was previously using a build date, but it's annoying to rebuild every X months, so I want this to track time using a timeframe (i.e.: 7 days).

## Future Features

There are more "secure" ways (keychain) to prevent users from tampering with the "install date", but I'm not worried about that for my first release.

Paddle has a way to automatically expire a trial if you change the time, which would be a nice feature, but again that's more complexity, when the simple solution should be enough for the vast amount of developers.
