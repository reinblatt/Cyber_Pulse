import CoreData

class CoreDataManager {
    static let shared = CoreDataManager()
    
    private init() {}
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "CyberPulse")
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Unable to load persistent stores: \(error)")
            }
        }
        return container
    }()
    
    var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    // MARK: - Save Context
    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Error saving context: \(error)")
            }
        }
    }
    
    // MARK: - News Articles
    func saveArticle(_ article: NewsItem) {
        let fetchRequest: NSFetchRequest<NewsArticle> = NewsArticle.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "url == %@", article.url as NSURL)
        
        // Check if article already exists
        if let existingArticle = try? context.fetch(fetchRequest).first {
            // Update existing article
            existingArticle.title = article.title
            existingArticle.content = article.content
            existingArticle.date = article.date
            existingArticle.severity = article.severity.rawValue
        } else {
            // Create new article
            let newsArticle = NewsArticle(context: context)
            newsArticle.id = article.id
            newsArticle.title = article.title
            newsArticle.content = article.content
            newsArticle.source = article.source
            newsArticle.date = article.date
            newsArticle.severity = article.severity.rawValue
            newsArticle.url = article.url
            newsArticle.isRead = false
            newsArticle.isSaved = false
            
            // Download and save image data if available
            if let imageURL = article.imageURL {
                if let imageData = try? Data(contentsOf: imageURL) {
                    newsArticle.imageData = imageData
                }
            }
        }
        
        saveContext()
    }
    
    func fetchArticles(severity: NewsSeverity? = nil) -> [NewsArticle] {
        let fetchRequest: NSFetchRequest<NewsArticle> = NewsArticle.fetchRequest()
        
        // Add sort descriptor to show newest articles first
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \NewsArticle.date, ascending: false)]
        
        // Add severity filter if specified
        if let severity = severity {
            fetchRequest.predicate = NSPredicate(format: "severity == %@", severity.rawValue)
        }
        
        do {
            return try context.fetch(fetchRequest)
        } catch {
            print("Error fetching articles: \(error)")
            return []
        }
    }
    
    func searchArticles(query: String) -> [NewsArticle] {
        let fetchRequest: NSFetchRequest<NewsArticle> = NewsArticle.fetchRequest()
        fetchRequest.predicate = NSPredicate(
            format: "title CONTAINS[cd] %@ OR content CONTAINS[cd] %@",
            query, query
        )
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \NewsArticle.date, ascending: false)]
        
        do {
            return try context.fetch(fetchRequest)
        } catch {
            print("Error searching articles: \(error)")
            return []
        }
    }
    
    func markArticleAsRead(_ article: NewsArticle) {
        article.isRead = true
        saveContext()
    }
    
    func toggleArticleSaved(_ article: NewsArticle) {
        article.isSaved = !article.isSaved
        saveContext()
    }
    
    func deleteOldArticles(olderThan days: Int) {
        let fetchRequest: NSFetchRequest<NewsArticle> = NewsArticle.fetchRequest()
        let cutoffDate = Calendar.current.date(byAdding: .day, value: -days, to: Date())!
        fetchRequest.predicate = NSPredicate(format: "date < %@ AND isSaved == NO", cutoffDate as NSDate)
        
        do {
            let articlesToDelete = try context.fetch(fetchRequest)
            articlesToDelete.forEach { context.delete($0) }
            saveContext()
        } catch {
            print("Error deleting old articles: \(error)")
        }
    }
    
    // MARK: - Podcast Episodes
    func savePodcastEpisode(title: String, summary: String, audioURL: URL, podcastName: String, date: Date, duration: Int32?, imageURL: URL?) {
        let fetchRequest: NSFetchRequest<PodcastEpisode> = PodcastEpisode.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "audioURL == %@", audioURL as NSURL)
        
        // Check if episode already exists
        if let _ = try? context.fetch(fetchRequest).first {
            return // Skip if already exists
        }
        
        let episode = PodcastEpisode(context: context)
        episode.id = UUID()
        episode.title = title
        episode.summary = summary
        episode.audioURL = audioURL
        episode.podcastName = podcastName
        episode.date = date
        episode.duration = duration ?? 0
        episode.isDownloaded = false
        episode.isPlayed = false
        
        // Download and save image data if available
        if let imageURL = imageURL {
            if let imageData = try? Data(contentsOf: imageURL) {
                episode.imageData = imageData
            }
        }
        
        saveContext()
    }
    
    func fetchPodcastEpisodes(podcastName: String? = nil) -> [PodcastEpisode] {
        let fetchRequest: NSFetchRequest<PodcastEpisode> = PodcastEpisode.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \PodcastEpisode.date, ascending: false)]
        
        if let podcastName = podcastName {
            fetchRequest.predicate = NSPredicate(format: "podcastName == %@", podcastName)
        }
        
        do {
            return try context.fetch(fetchRequest)
        } catch {
            print("Error fetching podcast episodes: \(error)")
            return []
        }
    }
    
    func markEpisodeAsPlayed(_ episode: PodcastEpisode) {
        episode.isPlayed = true
        saveContext()
    }
    
    func markEpisodeAsDownloaded(_ episode: PodcastEpisode, localPath: String) {
        episode.isDownloaded = true
        episode.localAudioPath = localPath
        saveContext()
    }
    
    func deleteDownloadedEpisode(_ episode: PodcastEpisode) {
        // Delete local file if exists
        if let localPath = episode.localAudioPath {
            try? FileManager.default.removeItem(atPath: localPath)
        }
        
        episode.isDownloaded = false
        episode.localAudioPath = nil
        saveContext()
    }
    
    // MARK: - User Preferences
    func getUserPreferences() -> UserPreferences {
        let fetchRequest: NSFetchRequest<UserPreferences> = UserPreferences.fetchRequest()
        
        do {
            let preferences = try context.fetch(fetchRequest)
            if let existingPreferences = preferences.first {
                return existingPreferences
            }
        } catch {
            print("Error fetching preferences: \(error)")
        }
        
        // Create default preferences if none exist
        let newPreferences = UserPreferences(context: context)
        newPreferences.notificationsEnabled = true
        newPreferences.textToSpeechEnabled = true
        newPreferences.selectedSeverityLevels = NewsSeverity.allCases.map { $0.rawValue }
        newPreferences.selectedSources = []
        newPreferences.lastRefreshDate = Date()
        saveContext()
        
        return newPreferences
    }
    
    func updateUserPreferences(_ preferences: UserPreferences) {
        saveContext()
    }
} 