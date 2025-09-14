fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

## iOS

### ios test_api_key

```sh
[bundle exec] fastlane ios test_api_key
```

Test API key configuration

### ios check_app

```sh
[bundle exec] fastlane ios check_app
```

Check if app exists in App Store Connect

### ios setup

```sh
[bundle exec] fastlane ios setup
```

Setup development environment

### ios test_api

```sh
[bundle exec] fastlane ios test_api
```

Test App Store Connect API connection

### ios test_build

```sh
[bundle exec] fastlane ios test_build
```

Test build without uploading (local certificates)

### ios test

```sh
[bundle exec] fastlane ios test
```

Run tests

### ios build_release

```sh
[bundle exec] fastlane ios build_release
```

Build the app for release

### ios build_release_api_auth

```sh
[bundle exec] fastlane ios build_release_api_auth
```

Build with Flutter then sign with Fastlane (BREAKTHROUGH SOLUTION)

### ios testflight_upload

```sh
[bundle exec] fastlane ios testflight_upload
```

Upload to TestFlight

### ios appstore_upload

```sh
[bundle exec] fastlane ios appstore_upload
```

Upload to App Store

### ios deploy_testflight

```sh
[bundle exec] fastlane ios deploy_testflight
```

Deploy to TestFlight (build + upload)

### ios deploy_appstore

```sh
[bundle exec] fastlane ios deploy_appstore
```

Deploy to App Store (build + upload + submit)

### ios deploy_appstore_no_precheck

```sh
[bundle exec] fastlane ios deploy_appstore_no_precheck
```

Deploy to App Store (skip precheck entirely)

### ios upload_existing_ipa

```sh
[bundle exec] fastlane ios upload_existing_ipa
```

Upload existing IPA to TestFlight

### ios certificates

```sh
[bundle exec] fastlane ios certificates
```

Setup certificates and provisioning profiles

### ios refresh_certificates

```sh
[bundle exec] fastlane ios refresh_certificates
```

Refresh certificates and provisioning profiles

### ios test_certificates

```sh
[bundle exec] fastlane ios test_certificates
```

Test certificate creation with API key

### ios diagnose_certificates

```sh
[bundle exec] fastlane ios diagnose_certificates
```

Diagnose certificates and provisioning profiles

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
