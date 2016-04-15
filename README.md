# Appium Mobile Grid Example

## Getting Started

Assumptions:
  * You have AndroidStudios and Xcode installed.
  * You have Xcode command line tools installed.
  * You have npm & Appium installed. https://www.npmjs.com/package/appium
  * You followed the Appium setup instructions http://appium.io/slate/en/1.5/?ruby#setup for android & iOS.
  * You're running this on a Mac for iOS. For android, you can run on Windows and Linux with some tweaking.
  * You have Homebrew installed. http://brew.sh/
  * You have ideviceinstaller installed for iOS tests. `brew install ideviceinstaller`
  * You have enabled UI Automation in Settings > Developer for iOS.
  * You have android emulators installed or USB connected devices with USB Debug enabled.

To set up:

* Ensure you running at least Ruby version 2.0 or above. You can check this by
  running:

  `ruby -v`

  If you have an older version of Ruby installed, consider using
  [rbenv](https://github.com/sstephenson/rbenv) for installing a newer version
  of Ruby.

* Install Bundler:

  `gem install bundler`

* Run bundle install:

  `bundle install`

* Install Allure Report: https://github.com/allure-framework/allure-cli

  `brew tap allure-framework/allure`

  `brew install allure-cli`

## Running Specs

* Start android emulators or connect devices!
* iOS is setup to only run on real devices. This is due to Apple's limitation of allowing only one running emulator per machine.

To run specs single threaded:

  `rake android[single]`
  `rake ios[single]`

To run specs in parallel:

  `rake android[parallel]`
  `rake ios[parallel]`

To run specs distributed:

  `rake android[dist]`
  `rake ios[dist]`

To run specs on SauceLabs:
  * Goto saucelabs.com and signup.
  * Then add your SauceLabs environment variables.

  `export SAUCE_USERNAME=<user sauce user_id>`

  `export SAUCE_ACCESS_KEY=<your sauce access key>`

  `rake android/ios[single,sauce]` <- "Will run tests tagged with :sauce single threaded"

  `rake android/ios[dist,sauce]` <- "Will run tests tagged with :sauce distributed"

Generate Allure report: (Displays test results, hub log, appium log, screenshots and video)

  `allure generate report output/allure/*`

  `allure report open`

## iOS debugging:
  * There could be times when the tests hang on iOS. This is most likely due to a pairing issue with ideviceinstaller.

  `idevicepair -u <udid> unpair`

  `idevicepair -u <udid> pair`

  * Accept the "Trust this computer" popup on the device.

  `idevicepair -u <udid> validate`

  * Make sure you get "SUCCESS: Validated pairing with device <udid>"
  * You should now be able to install the app manually.

  `ideviceinstaller -u <udid> -i ./appium-mobile-grid/ios/TestApp/build/Release-iphoneos/TestApp.app.zip`

  * Build the app with xcodebuild

  `cd ios/TestApp`

  `xcodebuild -sdk iphoneos` <- This will place a new binary in appium-mobile-grid/ios/TestApp/build/Release-iphoneos

  `ideviceinstaller -u <udid> -i ./appium-mobile-grid/ios/TestApp/build/Release-iphoneos/TestApp.app`

## Capture Metadata

  `$ gem install flick`
	
  * See [here](https://github.com/isonic1/flick) for more details.
  * Also see [here](https://github.com/isonic1/appium-mobile-grid/blob/flick/android/spec/spec_helper.rb#L15-L16) for example of implementation.

## Disclaimer:
  * This example was built quickly, so the code is not in the optimal state of dryness.
  * No page objects were used. The tests are soley for example purposes.
