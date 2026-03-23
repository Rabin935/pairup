# PairUp

<p align="center">
	<img src="assets/images/pairup.png" alt="PairUp banner" width="220" />
</p>

<p align="center">
	<img src="https://readme-typing-svg.demolab.com?font=Fira+Code&size=22&pause=1200&color=1D9BF0&center=true&vCenter=true&width=700&lines=Find+people+you+click+with;Match+%2B+Chat+%2B+Connect;Built+with+Flutter+%26+Clean+Architecture" alt="Typing intro" />
</p>

<p align="center">
	<img src="https://media.giphy.com/media/v1.Y2lkPTc5MGI3NjExY2phc3N3dTUwcHA5aWptOW9zZjQ5N2lwdTE5c2VhYm5jc3A3NnllNSZlcD12MV9naWZzX3NlYXJjaCZjdD1n/l0MYt5jPR6QX5pnqM/giphy.gif" alt="Moving sticker 1" width="80" />
	<img src="https://media.giphy.com/media/v1.Y2lkPTc5MGI3NjExM24yNjF4bTVtNzNrc25hZGl1Y2xmeXkyeGp2cXk2OGQxbGR3NjQxNyZlcD12MV9naWZzX3NlYXJjaCZjdD1n/3o7aD2saalBwwftBIY/giphy.gif" alt="Moving sticker 2" width="80" />
	<img src="https://media.giphy.com/media/v1.Y2lkPTc5MGI3NjExM3NwOHVhM2V3OXNzNnJnNDRvMXNmdWo3OWRjY3J0djB0aDk2aWRtdCZlcD12MV9naWZzX3NlYXJjaCZjdD1n/xT0xeJpnrWC4XWblEk/giphy.gif" alt="Moving sticker 3" width="80" />
</p>

PairUp is a social matching app built with Flutter.

In simple words:
- You create your profile.
- You discover people with shared interests.
- You send likes and get matches.
- You chat in real-time when both sides connect.

---

## Why This Project Exists

PairUp is designed as a practical, modern Flutter app that combines:
- clean feature-based architecture,
- real-time communication,
- profile and media management,
- offline-friendly local storage.

It is useful as both:
- a real product base, and
- a learning reference for building large Flutter apps.

---

## Core Features

### 1) Onboarding and Authentication
- Smooth splash and onboarding flow.
- Login and signup with validation.
- Session persistence with secure storage.
- Social auth support (Google / Apple integration present in dependencies).

### 2) Discover and Match
- Explore user profiles.
- Like profiles and receive match requests.
- View match percentages and profile highlights.

### 3) Real-time Chat
- Chat tabs for match requests, new requests, and active messages.
- Unread message counters.
- Socket-based chat infrastructure for live updates.

### 4) Notifications
- Notification feed with read-state updates.
- In-app notification badge counters.
- Respond to relevant requests directly from app flows.

### 5) Rich Profile System
- Edit profile details (bio, interests, location, age, etc.).
- Upload/manage profile media.
- Track profile activity stats (views, likes, matches).
- Privacy and visibility settings.

### 6) Motion/Sensor Integration
- Sensor feature module included (accelerometer/gyroscope based interactions).
- Motion-based action support in home/discovery experiences.

### 7) Localization and Theme
- Multi-language support (`assets/lang/en.json`, `assets/lang/ne.json`).
- Light and dark theme mode support.

---

## Tech Stack

- Flutter + Dart
- State management: Riverpod
- Networking: Dio
- Local database: Hive
- Real-time: WebSocket / socket.io client
- Auth/session: Secure storage + shared preferences + JWT handling
- Media: image/video pick, compress, thumbnail and cache
- Background tasks: Workmanager

---

## Project Structure (Simplified)

```text
lib/
	core/        # shared services, theme, api, localization, utils
	features/
		auth/      # login/signup/session
		chat/      # chat, requests, sockets
		notification/
		sensor/    # motion sensor logic
		splash/    # splash, onboarding, navigation shell, bottom screens
		user/      # profile and user data
```

---

## Quick Start

### Prerequisites
- Flutter SDK (stable)
- Dart SDK (comes with Flutter)
- Android Studio or VS Code

### Setup

```bash
flutter pub get
flutter run
```

### Useful Commands

```bash
# Run tests
flutter test

# Analyze code
flutter analyze

# Build release apk
flutter build apk --release
```

---

## Permissions Used

The app requests permissions for features such as:
- camera/photo access (profile media),
- notifications,
- motion sensors,
- network communication.

---

## Asset Notes

- App logo and images live in `assets/images` and `assets/icons`.
- Fonts are configured in `pubspec.yaml`.

---

## Development Status

This project already includes core social app modules and tests across multiple layers (`test/unit`, `test/widget`, `test/screen`).

If you want, I can also create:
- a section with real app screenshots,
- API/environment setup instructions,
- contribution guidelines,
- release notes summary from `docs/release_notes`.
