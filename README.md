# nonna_app

A Flutter application powered by Supabase.

## Getting Started

This project is a Flutter application using Supabase as the backend.

### Prerequisites
- Flutter SDK (^3.10.1)
- Dart SDK
- Supabase account
- Android Studio or VS Code with Flutter extensions

### Installation

1. Clone the repository:
```bash
git clone https://github.com/dipan0saha/nonna_app.git
cd nonna_app
```

2. Install dependencies:
```bash
flutter pub get
```

3. Configure Supabase environment variables:
   
   a. Create a `.env` file in the root directory by copying the example:
   ```bash
   cp .env.example .env
   ```
   
   b. Update the `.env` file with your Supabase credentials:
   ```
   SUPABASE_URL=https://your-project.supabase.co
   SUPABASE_ANON_KEY=your-anon-key-here
   ```
   
   To get these values:
   - Go to your [Supabase dashboard](https://app.supabase.com)
   - Select your project
   - Go to Settings > API
   - Copy the Project URL and anon/public key

4. Configure Android signing (for release builds):
   
   a. Generate a keystore (if you don't have one):
   ```bash
   keytool -genkey -v -keystore ~/nonna-release-key.jks -storetype PKCS12 -keyalg RSA -keysize 2048 -validity 10000 -alias nonna
   ```
   
   **Note**: PKCS12 format is used as JKS is deprecated.
   
   b. Create `android/key.properties` by copying the example:
   ```bash
   cp android/key.properties.example android/key.properties
   ```
   
   c. Update `android/key.properties` with your keystore information:
   ```
   storeFile=/path/to/your/keystore.jks
   storePassword=your-store-password
   keyAlias=nonna
   keyPassword=your-key-password
   ```
   
   **Note:** Never commit `key.properties` or your keystore file to version control!

5. Run the app:
```bash
flutter run
```

For more details, see the [Implementation Guide](docs/supabase-implementation-guide.md).

## Tech Stack

- **Frontend:** Flutter
- **Backend:** Supabase
  - PostgreSQL database
  - Real-time subscriptions
  - Authentication
  - Storage
  - Auto-generated APIs

## Resources

### Flutter Resources
- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)
- [Flutter Documentation](https://docs.flutter.dev/)

### Supabase Resources
- [Supabase Documentation](https://supabase.com/docs)
- [Flutter SDK Guide](https://supabase.com/docs/reference/dart/introduction)
- [Supabase Discord Community](https://discord.supabase.com)

## License

This project is licensed under the MIT License.
