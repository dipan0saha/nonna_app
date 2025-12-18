# nonna_app

A Flutter application powered by Supabase.

## 📚 Documentation

### Story 1.1: Supabase Feasibility Study
Comprehensive analysis on Supabase scalability for 10,000+ users with real-time updates.

- 📄 [Executive Summary](docs/1.1_feasibility_study/EXECUTIVE_SUMMARY.md) - Quick overview and recommendations
- 📊 [Full Feasibility Study](docs/1.1_feasibility_study/supabase-feasibility-study.md) - Detailed technical analysis
- 🛠️ [Implementation Guide](docs/1.1_feasibility_study/supabase-implementation-guide.md) - Developer guide with code samples
- 💰 [Cost Analysis](docs/1.1_feasibility_study/supabase-cost-analysis.md) - Pricing projections and financial planning
- 📖 [Docs Index](docs/1.1_feasibility_study/README.md) - Navigation guide for all documentation

**Key Findings:**
- ✅ Supabase can handle 10,000+ users with real-time updates
- ✅ Estimated cost: $150-250/month for 10,000 users
- ✅ Implementation timeline: 8 weeks
- ✅ Risk level: LOW

### Story 2.2: Flutter Android Performance Assessment
Comprehensive analysis of Flutter performance on Android for photo uploads and push notifications.

- 📄 [Executive Summary](docs/2.2_flutter_performance_android/EXECUTIVE_SUMMARY.md) - Quick overview and go/no-go decision
- 📊 [Performance Assessment](docs/2.2_flutter_performance_android/flutter-android-performance-assessment.md) - Detailed technical analysis
- 📖 [Docs Index](docs/2.2_flutter_performance_android/README.md) - Navigation guide

**Key Findings:**
- ✅ Photo uploads: Within 10% of native Android performance
- ✅ Push notifications: Identical to native Android (FCM)
- ✅ Development velocity: 50% faster than native
- ✅ ROI: $14,000-21,000 savings in Year 1
- ✅ Risk level: LOW

## Getting Started

This project is a Flutter application using Supabase as the backend.

### Prerequisites
- Flutter SDK (^3.10.1)
- Dart SDK
- Supabase account

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

3. Configure Supabase (see [Implementation Guide](docs/supabase-implementation-guide.md) for details):
- Create a Supabase project
- Copy your project URL and anon key
- Update configuration in the app

4. Run the app:
```bash
flutter run
```

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
