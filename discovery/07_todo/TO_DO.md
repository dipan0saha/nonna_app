


### 2.4 Realtime Service Setup

**Step 1: Enable Realtime**

Navigate to Database → Replication:

1. Enable Realtime for tables:
   - `photos`
   - `events`
   - `photo_comments`
   - `event_comments`
   - `notifications`
   - `owner_update_markers` (for cache invalidation)

2. Configure realtime settings:
   - Max concurrent connections: 10,000 (Free tier: 200)
   - Max rows per query: 1000
   - Enable broadcast and presence features (optional)

**Step 2: Test Realtime Subscriptions**

```dart
// Test realtime subscription
final subscription = supabase
  .from('photos')
  .stream(primaryKey: ['id'])
  .listen((data) {
    print('New photo: $data');
  });
```


# Step 3: Configure Function Environment Variables

## Set secrets for Edge Functions
supabase secrets set SENDGRID_API_KEY=SG.xxx
supabase secrets set ONESIGNAL_API_KEY=os_xxx
supabase secrets set ONESIGNAL_APP_ID=app_xxx


# 3.3 Database Security
## Connection Security:

All connections use SSL/TLS by default
Connection strings include sslmode=require

## Backup Security:

Enable automatic daily backups (Pro tier)
Enable point-in-time recovery for critical data (Pro/Team tier)
Backups encrypted at rest (AES-256)
Test restore process quarterly


# Google OAuth
## Production keystore file
To get the path to your production keystore file (e.g., my-keystore.jks) for Android app signing, follow these steps. This is required for releasing your Flutter app on Google Play.

1. Generate a Production Keystore (if you don't have one):
Run this command in your terminal (replace placeholders):
keytool -genkey -v -keystore /path/to/my-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias my-key

/path/to/my-keystore.jks: Choose a secure location (e.g., ~/Documents/keystores/my-keystore.jks).
You'll be prompted for passwords and details (e.g., name, organization).
Store the keystore file securely (e.g., in a password manager) and back it up.
2. Locate the Keystore Path:
The path is where you saved the .jks file (e.g., /Users/dipansaha/Documents/keystores/my-keystore.jks).
For existing keystores, find the file on your system.
3. Use in Flutter Builds:
Add to android/key.properties or pass via command:
flutter build apk --release --keystore=/path/to/my-keystore.jks --keystore-password=your-password --key-password=your-key-password --key-alias=my-key

For CI/CD, store the path and passwords as secrets.
