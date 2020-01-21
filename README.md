# UserVoice End User API Demo (iOS)

A simple iOS app to demonstrate the OAuth authentication_code flow and basic functionality of the UserVoice [End User API](https://developer.uservoice.com/).

> NOTE: This app should only serve as an example for how to use the UserVoice End User API. It is not intended to highlight iOS best practices.

## Project Dependencies
* [CocoaPods](https://cocoapods.org/): Dependency manager for Swift
* [OAuthSwift](https://github.com/OAuthSwift/OAuthSwift): Swift library for handling the OAuth2 flow

## Installation (requires Xcode)
1. Clone the repository: `git clone git@github.com:uservoice/end-user-api-ios-demo.git`.
2. Ensure CocoaPods dependency manager is installed: `sudo gem install cocoapods`.
3. Navigate into project directory and install dependencies: `cd end-user-api-ios-demo && pod install`.
4. Create an API key from the UserVoice admin console and set the "Callback URL" to `com.uv.Demo:/oauth2Callback`.
   * For more information on creating an API key and implementing the OAuth flow, see [this guide](https://developer.uservoice.com/docs/end-user-api/auth/).
5. Open `end-user-api-demo.xcworkspace` in Xcode.
6. Set the environment variables referenced at the top of [UvApi.swift](https://github.com/uservoice/end-user-api-ios-demo/blob/master/end-user-api-demo/UvApi.swift) by configuring the Xcode Scheme.
7. Build and run the app.

## Resources
* [UserVoice End User API Reference](https://developer.uservoice.com/docs/end-user-api/reference/)
* [OAuth Authentication Code Flow with PKCE](https://developer.uservoice.com/docs/end-user-api/auth/)
* [OAuthSwift](https://github.com/OAuthSwift/OAuthSwift)
