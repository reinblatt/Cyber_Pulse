# CyberPulse

CyberPulse is an iOS application that provides real-time cybersecurity news and podcast updates with a focus on user privacy and offline functionality.

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

- iOS 15.0+
- Xcode 13.0+
- Swift 5.5+

## Dependencies

- FeedKit: For RSS and podcast feed parsing
- CoreData: For local data storage
- AVFoundation: For audio playback
- UserNotifications: For push notifications

## Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/CyberPulse.git
```

2. Open the project in Xcode:
```bash
cd CyberPulse
open CyberPulse.xcodeproj
```

3. Build and run the project in Xcode

## Architecture

The app follows the MVVM (Model-View-ViewModel) architecture pattern:

### Models
- `NewsArticle`: CoreData entity for news articles
- `PodcastEpisode`: CoreData entity for podcast episodes
- `UserPreferences`: CoreData entity for user settings
- `Feed`: Model for RSS and podcast feeds

### ViewModels
- `NewsViewModel`: Manages news article data and operations
- `PodcastViewModel`: Handles podcast playback and episode management

### Views
- `ContentView`: Main tab-based interface
- `PodcastView`: Podcast episode list and player
- `PodcastPlayerView`: Full-screen podcast player

### Services
- `CoreDataManager`: Handles local data storage
- `FeedService`: Manages RSS and podcast feed updates

## Project Structure

```
CyberPulse/
├── App/
│   ├── AppDelegate.swift
│   └── SceneDelegate.swift
├── Models/
│   ├── Feed.swift
│   ├── NewsItem.swift
│   └── CyberPulse.xcdatamodeld/
├── ViewModels/
│   ├── NewsViewModel.swift
│   └── PodcastViewModel.swift
├── Views/
│   ├── ContentView.swift
│   ├── PodcastView.swift
│   └── PodcastPlayerView.swift
├── Services/
│   ├── CoreDataManager.swift
│   └── FeedService.swift
└── Resources/
    └── Assets.xcassets/
```

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