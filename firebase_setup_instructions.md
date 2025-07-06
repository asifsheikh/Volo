# Firebase Phone Authentication Setup Instructions

## SHA-256 Fingerprint for Firebase Console

**Debug SHA-256:** `8B:84:30:C1:DD:90:A2:8E:D3:37:8F:BA:6B:6C:35:E3:F9:C4:9D:7D:49:BB:AC:93:79:3F:49:E8:10:61:37:AA`

## Steps to Configure Firebase Console:

### 1. Add SHA-256 Fingerprint
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: **volo-app-1**
3. Go to **Project Settings** (gear icon)
4. Scroll down to **Your apps** section
5. Click on your Android app: **com.volo.volo**
6. Click **Add fingerprint**
7. Paste the SHA-256 fingerprint above
8. Click **Save**

### 2. Enable Phone Authentication
1. In Firebase Console, go to **Authentication**
2. Click on **Sign-in method** tab
3. Find **Phone** in the list
4. Click on it and **Enable** it
5. Click **Save**

### 3. Add Test Phone Numbers (for development)
1. In **Authentication > Sign-in method > Phone**
2. Scroll down to **Phone numbers for testing**
3. Click **Add phone number**
4. Add your test phone numbers (e.g., +1234567890)
5. You can add up to 20 test numbers

### 4. Configure SMS Template (Optional)
1. In **Authentication > Sign-in method > Phone**
2. Scroll down to **SMS template**
3. Customize the message if needed
4. The default template includes `%APP_NAME%` which will show your app name

## Common Issues and Solutions:

### Issue: "Fail to send OTP, please try again"
**Possible causes:**
- SHA-256 fingerprint not added to Firebase Console
- Phone Authentication not enabled
- Using real phone number without test configuration
- Network connectivity issues

### Issue: "App verification failed"
**Solution:** 
- Make sure SHA-256 fingerprint is added
- The app now includes activity parameter for reCAPTCHA

### Issue: "Missing activity for reCAPTCHA"
**Solution:**
- The code now includes the activity parameter
- This should resolve the reCAPTCHA verification issue

## Testing:

### For Development/Testing:
1. Use test phone numbers added in Firebase Console
2. These numbers will receive OTP without actual SMS
3. You can see the OTP in Firebase Console logs

### For Production:
1. Use real phone numbers
2. Make sure to add production SHA-256 fingerprint
3. Test with actual devices

## Current App Configuration:

- **Package Name:** com.volo.volo
- **Debug SHA-256:** 8B:84:30:C1:DD:90:A2:8E:D3:37:8F:BA:6B:6C:35:E3:F9:C4:9D:7D:49:BB:AC:93:79:3F:49:E8:10:61:37:AA
- **Firebase Project:** volo-app-1
- **Authentication SDK:** Latest version with Play Integrity support

## Next Steps:

1. Add the SHA-256 fingerprint to Firebase Console
2. Enable Phone Authentication
3. Add test phone numbers
4. Test the app again
5. Check the logs for detailed debugging information 