# Android Keystore Instructions

To prepare your app for release on Google Play Store, you need to create a signing key.

## Generate a Release Keystore

Run this command to create your release keystore:

```bash
keytool -genkey -v -keystore android/app/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

## Create key.properties file

Create `android/key.properties` with:

```
storePassword=YOUR_STORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD  
keyAlias=upload
storeFile=upload-keystore.jks
```

## Update build.gradle.kts

The build.gradle.kts file will be updated to use your signing configuration.

⚠️ IMPORTANT: 
- Keep your keystore file and passwords secure
- Never commit key.properties or keystore files to version control
- Make backups of your keystore file
