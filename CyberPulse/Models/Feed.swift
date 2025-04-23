import Foundation

enum FeedType: String {
    case rss
    case podcast
}

struct Feed: Codable {
    let id: UUID
    let name: String
    let url: URL
    let type: FeedType
    let category: String
    var lastUpdated: Date
    
    init(id: UUID = UUID(), name: String, url: URL, type: FeedType, category: String, lastUpdated: Date = Date()) {
        self.id = id
        self.name = name
        self.url = url
        self.type = type
        self.category = category
        self.lastUpdated = lastUpdated
    }
}

// Default cybersecurity feeds
extension Feed {
    static let defaultFeeds: [Feed] = [
        // RSS Feeds
        Feed(name: "Krebs on Security", 
             url: URL(string: "https://krebsonsecurity.com/feed/")!,
             type: .rss,
             category: "Security News"),
        Feed(name: "The Hacker News",
             url: URL(string: "https://feeds.feedburner.com/TheHackersNews")!,
             type: .rss,
             category: "Security News"),
        Feed(name: "Threatpost",
             url: URL(string: "https://threatpost.com/feed/")!,
             type: .rss,
             category: "Security News"),
        
        // Podcast Feeds
        Feed(name: "Darknet Diaries",
             url: URL(string: "https://feeds.megaphone.fm/darknetdiaries")!,
             type: .podcast,
             category: "Security Podcasts"),
        Feed(name: "Security Now",
             url: URL(string: "https://feeds.twit.tv/sn.xml")!,
             type: .podcast,
             category: "Security Podcasts"),
        Feed(name: "SANS Internet Stormcast",
             url: URL(string: "https://isc.sans.edu/podcast.xml")!,
             type: .podcast,
             category: "Security Podcasts")
    ]
} 