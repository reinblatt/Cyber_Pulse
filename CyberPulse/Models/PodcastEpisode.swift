import CoreData
import Foundation

@objc(PodcastEpisode)
class PodcastEpisode: CoreDataModel {
    @NSManaged public var title: String
    @NSManaged public var descriptionText: String
    @NSManaged public var audioUrl: String
    @NSManaged public var duration: Double
    @NSManaged public var publishedAt: Date
    @NSManaged public var isDownloaded: Bool
    @NSManaged public var downloadProgress: Double
    @NSManaged public var localPath: String?
    @NSManaged public var podcastName: String
    @NSManaged public var podcastImageUrl: String?
    
    static func fetchRequest() -> NSFetchRequest<PodcastEpisode> {
        return NSFetchRequest<PodcastEpisode>(entityName: "PodcastEpisode")
    }
    
    static func create(in context: NSManagedObjectContext,
                      title: String,
                      descriptionText: String,
                      audioUrl: String,
                      duration: Double,
                      publishedAt: Date,
                      podcastName: String,
                      podcastImageUrl: String?) -> PodcastEpisode {
        let episode = PodcastEpisode(context: context)
        episode.title = title
        episode.descriptionText = descriptionText
        episode.audioUrl = audioUrl
        episode.duration = duration
        episode.publishedAt = publishedAt
        episode.isDownloaded = false
        episode.downloadProgress = 0.0
        episode.podcastName = podcastName
        episode.podcastImageUrl = podcastImageUrl
        return episode
    }
} 