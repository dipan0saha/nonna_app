# Recommended Technology Stack for Nonna-App

This document outlines the definitive technology stack for the Nonna-App, chosen based on a detailed analysis of the project requirements.

## Core Technologies

*   **Frontend (Mobile App):** **Flutter**
    *   **Why:** A high-performance, cross-platform UI toolkit ideal for building beautiful and natively compiled applications for both iOS and Android from a single codebase. It enables fast development and an expressive, modern UI, aligning with the app's design goals.
    *   **Features Enabled:** The entire user interface, including user profiles, event calendars, baby registries, photo galleries, and all user interactions.

*   **Backend as a Service (BaaS):** **Supabase**
    *   **Why:** An open-source Firebase alternative that provides a comprehensive suite of backend tools built on enterprise-grade, open-source technologies. Its foundation on PostgreSQL makes it the ideal choice for the Nonna-App's relational data structure.
    *   **Features Enabled:** User management, a relational database, file storage, and server-side logic for the entire application.

## Supabase Services

*   **Authentication:** **Supabase Auth**
    *   **Why:** A secure, JWT-based authentication service that supports email/password, social logins, and more. It integrates seamlessly with the database using Row-Level Security (RLS) to provide the granular, role-based access control required by the app's `Parent` and `Follower` roles.
    *   **Features Enabled:** Secure user sign-up, login, password reset, and the enforcement of all user permissions.

*   **Database:** **Supabase Database (PostgreSQL)**
    *   **Why:** A full-featured PostgreSQL database. This is the **key advantage** for the Nonna-App, as it allows for the creation of a robust, scalable, and maintainable relational data model. It simplifies the implementation of complex relationships between users, profiles, events, and photos.
    *   **Features Enabled:** Storing and retrieving all application data, including user profiles, baby profiles, calendar events, registry items, comments, and likes ("squishes"). The relational structure ensures data integrity.

*   **File Storage:** **Supabase Storage**
    *   **Why:** A simple and scalable object storage service, perfect for handling user-generated content. It integrates with the PostgreSQL database to manage permissions, allowing you to easily control who can upload or access files.
    *   **Features Enabled:** Uploading, storing, and displaying all images for baby profiles, calendar events, and the photo gallery.

*   **Serverless Logic:** **Supabase Edge Functions**
    *   **Why:** Globally distributed, TypeScript-based functions that allow you to run custom backend logic. They are ideal for integrating with third-party services or performing tasks that require secure credentials.
    *   **Features Enabled:** Sending push notifications when a registry item is purchased, resizing images upon upload, or sending welcome emails via a third-party email service.

## Frontend Architecture (Flutter)

*   **State Management:**
    *   **Recommendation:** **Provider** or **BLoC (Business Logic Component)**
    *   **Why:** Provider is excellent for getting started and managing state in a simple way, while BLoC offers a more structured pattern that scales well for complex applications like this one.
    *   **Features Enabled:** Managing UI state, such as the current user's session, form data, and the data currently displayed on screen.

*   **Navigation:**
    *   **Recommendation:** **GoRouter**
    *   **Why:** The official declarative routing package from the Flutter team. It simplifies navigation, deep linking, and managing routes in a structured way.
    *   **Features Enabled:** All navigation within the app, such as moving from the main dashboard to the calendar, or from a photo gallery to an individual photo's detail view.

*   **Testing:**
    *   **Unit & Widget Testing:** **flutter_test** (built-in)
    *   **Mocking:** **Mockito**
    *   **Why:** Essential for ensuring the application is reliable and bug-free. A strong testing suite is critical for maintaining quality as the app grows.
    *   **Features Enabled:** Verifying the correctness of all application logic and UI components through automated tests.

## Additional Services

*   **Stability Monitoring:**
    *   **Recommendation:** **Sentry** or **Datadog**
    *   **Why:** Since Supabase doesn't have a built-in crash reporting tool like Firebase Crashlytics, integrating a dedicated service is crucial for monitoring the app's stability in real-time.
    *   **Features Enabled:** Automatically tracking, prioritizing, and debugging crashes and errors that occur on users' devices.

## DevOps

*   **Continuous Integration/Continuous Deployment (CI/CD):**
    *   **Recommendation:** **GitHub Actions**
    *   **Why:** Integrates seamlessly with the code repository to automate the process of building, testing, and deploying the app to the Apple App Store and Google Play Store.
    *   **Features Enabled:** Streamlining the release process, ensuring that every change is automatically tested and ready for deployment.
