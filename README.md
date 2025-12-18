# nonna_app

A Flutter application powered by Supabase.

## 📚 Documentation

### Supabase Feasibility Study
Comprehensive analysis on Supabase scalability for 10,000+ users with real-time updates.

- 📄 [Executive Summary](docs/EXECUTIVE_SUMMARY.md) - Quick overview and recommendations
- 📊 [Full Feasibility Study](docs/supabase-feasibility-study.md) - Detailed technical analysis
- 🛠️ [Implementation Guide](docs/supabase-implementation-guide.md) - Developer guide with code samples
- 💰 [Cost Analysis](docs/supabase-cost-analysis.md) - Pricing projections and financial planning
- 📖 [Docs Index](docs/README.md) - Navigation guide for all documentation

**Key Findings:**
- ✅ Supabase can handle 10,000+ users with real-time updates
- ✅ Estimated cost: $150-250/month for 10,000 users
- ✅ Implementation timeline: 8 weeks
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
