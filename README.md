# CyberPulse

CyberPulse is an iOS application that provides news articles and podcast episodes with a focus on cybersecurity and technology topics.

## Features

### News Feed
- Real-time cybersecurity news updates
- Severity-based sorting and filtering
- Offline reading capability
- Customizable news sources
- Push notifications for critical updates
- Text-to-speech functionality

### Podcast Integration
- Security-focused podcast episodes
- Offline playback support
- Background audio playback
- Playback speed control
- Episode download management
- Playback progress tracking

### Privacy & Security
- All data stored locally using CoreData
- No user tracking or analytics
- Offline-first approach
- Secure data storage
- User-controlled data management

## Requirements

- Xcode 13.0 or later
- iOS 15.0 or later
- Swift 5.5 or later
- macOS 11.0 or later (for development)

## Dependencies

- FeedKit: For RSS and podcast feed parsing
- CoreData: For local data storage
- AVFoundation: For audio playback
- UserNotifications: For push notifications

## Project Setup

1. **Clone the Repository**
   ```bash
   git clone https://github.com/yourusername/CyberPulse.git
   cd CyberPulse
   ```

2. **Open the Project**
   - Open `CyberPulse.xcodeproj` in Xcode
   - Wait for Xcode to finish indexing and resolving dependencies

3. **Configure Signing**
   - Select the CyberPulse project in the navigator
   - Select the CyberPulse target
   - Go to the "Signing & Capabilities" tab
   - Select your development team
   - Ensure the bundle identifier is set to `com.cyberpulse.app`

4. **Add App Icons**
   - Open `Assets.xcassets`
   - Navigate to `AppIcon.appiconset`
   - Add the required app icon images for all sizes:
     - iPhone: 20pt, 29pt, 40pt, 60pt (2x and 3x)
     - iPad: 20pt, 29pt, 40pt, 76pt, 83.5pt (1x and 2x)
     - App Store: 1024x1024 (1x)

## Build and Run

1. **Select Target Device**
   - Choose a simulator or connected device from the device menu
   - Ensure the selected device runs iOS 15.0 or later

2. **Build the Project**
   - Press ⌘B or select Product > Build
   - Wait for the build to complete

3. **Run the App**
   - Press ⌘R or select Product > Run
   - The app will launch on the selected device

## Project Structure

```
CyberPulse/
├── App/
│   ├── AppDelegate.swift
│   ├── SceneDelegate.swift
│   └── Info.plist
├── Models/
│   ├── CoreDataModel.swift
│   ├── NewsArticle.swift
│   ├── PodcastEpisode.swift
│   ├── UserPreferences.swift
│   └── CyberPulse.xcdatamodeld/
├── Views/
│   ├── ContentView.swift
│   ├── MainTabBarController.swift
│   ├── PodcastPlayerView.swift
│   ├── PodcastView.swift
│   ├── Common/
│   └── News/
├── Resources/
│   ├── Assets.xcassets/
│   └── LaunchScreen.storyboard
└── Services/
```

## Core Features

- News article browsing and reading
- Podcast episode streaming and downloading
- User preferences management
- Background audio playback
- Push notifications

## Security Considerations

1. **Data Storage**
   - All data is stored locally using CoreData
   - No cloud synchronization
   - User preferences control data retention

2. **Network Security**
   - HTTPS for all network requests
   - Feed validation and sanitization
   - Error handling for network failures

3. **User Privacy**
   - No user tracking
   - No analytics collection
   - Optional push notifications
   - User-controlled data management

## App Store Submission Checklist

- [ ] App icon and launch screen
- [ ] Privacy policy
- [ ] App Store screenshots
- [ ] App description and keywords
- [ ] Age rating and content description
- [ ] Support URL and marketing URL
- [ ] Version number and build number
- [ ] Required capabilities and entitlements
- [ ] App Store Connect metadata
- [ ] TestFlight testing
- [ ] Final App Store review submission

## Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details. 