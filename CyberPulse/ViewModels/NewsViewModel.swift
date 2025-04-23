import Foundation
import Combine
import CoreData

class NewsViewModel: ObservableObject {
    @Published var newsItems: [NewsArticle] = []
    @Published var isLoading = false
    @Published var error: Error?
    
    private let coreDataManager = CoreDataManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Load saved articles on init
        fetchNews()
        
        // Clean up old articles (older than 30 days and not saved)
        coreDataManager.deleteOldArticles(olderThan: 30)
    }
    
    func fetchNews() {
        isLoading = true
        error = nil
        
        // Fetch from local database
        newsItems = coreDataManager.fetchArticles()
        isLoading = false
        
        // Optional: Fetch new articles from RSS feeds or APIs
        // and save them to CoreData
    }
    
    func filterBySeverity(_ severity: NewsSeverity) {
        isLoading = true
        newsItems = coreDataManager.fetchArticles(severity: severity)
        isLoading = false
    }
    
    func searchNews(query: String) {
        isLoading = true
        newsItems = coreDataManager.searchArticles(query: query)
        isLoading = false
    }
    
    func markAsRead(_ article: NewsArticle) {
        coreDataManager.markArticleAsRead(article)
    }
    
    func toggleSaved(_ article: NewsArticle) {
        coreDataManager.toggleArticleSaved(article)
    }
    
    // MARK: - Sample Data
    func loadSampleData() {
        let sampleArticles = [
            NewsItem(
                title: "Critical Zero-Day Vulnerability Found in Popular Software",
                content: "Security researchers have discovered a critical vulnerability that affects millions of users...",
                source: "CyberNews",
                severity: .critical,
                url: URL(string: "https://example.com/article1")!
            ),
            NewsItem(
                title: "New Ransomware Strain Targets Healthcare Sector",
                content: "A sophisticated ransomware operation has been targeting healthcare facilities...",
                source: "SecurityWeek",
                severity: .high,
                url: URL(string: "https://example.com/article2")!
            ),
            NewsItem(
                title: "Best Practices for Securing Remote Work Environment",
                content: "As remote work continues to be prevalent, organizations must ensure proper security measures...",
                source: "CyberDefense",
                severity: .medium,
                url: URL(string: "https://example.com/article3")!
            )
        ]
        
        sampleArticles.forEach { coreDataManager.saveArticle($0) }
        fetchNews()
    }
} 