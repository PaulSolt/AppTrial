# TryMyApp
A simple library to make it easy to offer trial periods in macOS apps

## Dev Notes

Using TDD (Red Green Refactor) and principles from Clean Code (Uncle Bob) to write the logic.

The goal isn't security, since that's a hard moving target, instead it's to make it quick and easy to create an app that will have a timeout. 

So that the vast majority of your users will take the call to action (CTA) to upgrade to the full version, either by linking directly to the paid app on the [Mac App Store](https://paddle.com), or using a service like Paddle to sell a license key.

I'm building this for my [Super Easy Timer](https://itunes.apple.com/us/app/super-easy-timer/id1353137878?ls=1&mt=12) app, which was previously using a build date, but it's annoying to rebuild every X months, so I want this to track time using a timeframe (i.e.: 7 days).

There are more "secure" ways (keychain) to prevent users from tampering with the "install date", but I'm not worried about that for my first release.

Paddle has a way to automatically expire a trial if you change the time, which would be a nice feature, but again that's more complexity, when the simiple solution should be enough for the vast amount of users.

