import Foundation
import FeedKit
import Combine

enum FeedError: Error {
    case invalidFeed
    case parsingError
    case networkError
}

class FeedService {
    static let shared = FeedService()
    private let coreDataManager = CoreDataManager.shared
    
    private init() {}
    
    // MARK: - Feed Management
    func refreshFeeds() -> AnyPublisher<Void, Error> {
        let feeds = Feed.defaultFeeds // Later can be fetched from user preferences
        
        return Publishers.MergeMany(
            feeds.map { feed in
                fetchFeed(feed)
                    .catch { error -> Empty<Void, Error> in
                        print("Error fetching feed \(feed.name): \(error)")
                        return Empty()
                    }
            }
        )
        .collect()
        .map { _ in () }
        .eraseToAnyPublisher()
    }
    
    private func fetchFeed(_ feed: Feed) -> AnyPublisher<Void, Error> {
        Future<Void, Error> { [weak self] promise in
            let parser = FeedParser(URL: feed.url)
            
            parser.parseAsync { [weak self] result in
                switch result {
                case .success(let parsedFeed):
                    switch parsedFeed {
                    case .atom(let atomFeed):
                        if feed.type == .rss {
                            self?.handleAtomFeed(atomFeed, source: feed.name)
                        }
                    case .rss(let rssFeed):
                        if feed.type == .rss {
                            self?.handleRSSFeed(rssFeed, source: feed.name)
                        } else if feed.type == .podcast {
                            self?.handlePodcastFeed(rssFeed, podcastName: feed.name)
                        }
                    case .json(let jsonFeed):
                        if feed.type == .rss {
                            self?.handleJSONFeed(jsonFeed, source: feed.name)
                        }
                    }
                    promise(.success(()))
                    
                case .failure(let error):
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    // MARK: - Feed Parsing
    private func handleRSSFeed(_ feed: RSSFeed, source: String) {
        guard let items = feed.items else { return }
        
        items.forEach { item in
            let severity = determineSeverity(from: item)
            
            let newsItem = NewsItem(
                title: item.title ?? "Untitled",
                content: item.description ?? "",
                source: source,
                date: item.pubDate ?? Date(),
                severity: severity,
                imageURL: extractImageURL(from: item),
                url: URL(string: item.link ?? "") ?? URL(string: "https://example.com")!
            )
            
            coreDataManager.saveArticle(newsItem)
        }
    }
    
    private func handlePodcastFeed(_ feed: RSSFeed, podcastName: String) {
        guard let items = feed.items else { return }
        
        items.forEach { item in
            guard let audioURL = item.enclosure?.attributes?.url,
                  let url = URL(string: audioURL) else { return }
            
            let duration = parseDuration(from: item.iTunes?.duration)
            let imageURL = item.iTunes?.image?.attributes?.href.flatMap { URL(string: $0) }
                ?? feed.iTunes?.image?.attributes?.href.flatMap { URL(string: $0) }
            
            coreDataManager.savePodcastEpisode(
                title: item.title ?? "Untitled",
                summary: item.description ?? "",
                audioURL: url,
                podcastName: podcastName,
                date: item.pubDate ?? Date(),
                duration: duration,
                imageURL: imageURL
            )
        }
    }
    
    private func handleAtomFeed(_ feed: AtomFeed, source: String) {
        feed.entries?.forEach { entry in
            let severity = determineSeverity(from: entry)
            
            let newsItem = NewsItem(
                title: entry.title ?? "Untitled",
                content: entry.content?.value ?? "",
                source: source,
                date: entry.published ?? Date(),
                severity: severity,
                imageURL: nil, // Extract from content if needed
                url: URL(string: entry.links?.first?.attributes?.href ?? "") ?? URL(string: "https://example.com")!
            )
            
            coreDataManager.saveArticle(newsItem)
        }
    }
    
    private func handleJSONFeed(_ feed: JSONFeed, source: String) {
        feed.items?.forEach { item in
            let severity = determineSeverity(from: item)
            
            let newsItem = NewsItem(
                title: item.title ?? "Untitled",
                content: item.contentHtml ?? item.contentText ?? "",
                source: source,
                date: item.datePublished ?? Date(),
                severity: severity,
                imageURL: URL(string: item.image ?? ""),
                url: URL(string: item.url ?? "") ?? URL(string: "https://example.com")!
            )
            
            coreDataManager.saveArticle(newsItem)
        }
    }
    
    // MARK: - Helper Methods
    private func parseDuration(from duration: String?) -> Int32? {
        guard let duration = duration else { return nil }
        
        // Try HH:MM:SS format
        let components = duration.components(separatedBy: ":")
        if components.count == 3,
           let hours = Int32(components[0]),
           let minutes = Int32(components[1]),
           let seconds = Int32(components[2]) {
            return hours * 3600 + minutes * 60 + seconds
        }
        
        // Try MM:SS format
        if components.count == 2,
           let minutes = Int32(components[0]),
           let seconds = Int32(components[1]) {
            return minutes * 60 + seconds
        }
        
        // Try seconds format
        if let seconds = Int32(duration) {
            return seconds
        }
        
        return nil
    }
    
    private func determineSeverity(from item: RSSFeedItem) -> NewsSeverity {
        let title = item.title?.lowercased() ?? ""
        let description = item.description?.lowercased() ?? ""
        let content = title + " " + description
        
        return determineSeverityFromText(content)
    }
    
    private func determineSeverity(from entry: AtomFeedEntry) -> NewsSeverity {
        let title = entry.title?.lowercased() ?? ""
        let content = entry.content?.value?.lowercased() ?? ""
        let combined = title + " " + content
        
        return determineSeverityFromText(combined)
    }
    
    private func determineSeverity(from item: JSONFeedItem) -> NewsSeverity {
        let title = item.title?.lowercased() ?? ""
        let content = (item.contentHtml ?? item.contentText ?? "").lowercased()
        let combined = title + " " + content
        
        return determineSeverityFromText(combined)
    }
    
    private func determineSeverityFromText(_ text: String) -> NewsSeverity {
        if text.contains("critical") || text.contains("urgent") || text.contains("emergency") {
            return .critical
        } else if text.contains("high") || text.contains("severe") || text.contains("major") {
            return .high
        } else if text.contains("medium") || text.contains("moderate") {
            return .medium
        } else {
            return .low
        }
    }
    
    private func extractImageURL(from item: RSSFeedItem) -> URL? {
        // Try to find image in enclosures
        if let enclosure = item.enclosure, let urlString = enclosure.attributes?.url,
           let url = URL(string: urlString), enclosure.attributes?.type?.starts(with: "image/") == true {
            return url
        }
        
        // Try to find image in content
        if let content = item.description {
            let pattern = "src=['\"]([^'\"]+)['\"]"
            if let regex = try? NSRegularExpression(pattern: pattern),
               let match = regex.firstMatch(in: content, range: NSRange(content.startIndex..., in: content)) {
                let urlRange = Range(match.range(at: 1), in: content)
                if let urlString = urlRange.flatMap({ String(content[$0]) }),
                   let url = URL(string: urlString) {
                    return url
                }
            }
        }
        
        return nil
    }
} 