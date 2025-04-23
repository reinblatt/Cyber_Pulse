import CoreData
import Foundation

@objc(NewsArticle)
class NewsArticle: CoreDataModel {
    @NSManaged public var title: String
    @NSManaged public var content: String
    @NSManaged public var source: String
    @NSManaged public var url: String
    @NSManaged public var imageUrl: String?
    @NSManaged public var publishedAt: Date
    @NSManaged public var isRead: Bool
    @NSManaged public var isBookmarked: Bool
    @NSManaged public var category: String
    
    static func fetchRequest() -> NSFetchRequest<NewsArticle> {
        return NSFetchRequest<NewsArticle>(entityName: "NewsArticle")
    }
    
    static func create(in context: NSManagedObjectContext, 
                      title: String,
                      content: String,
                      source: String,
                      url: String,
                      imageUrl: String?,
                      publishedAt: Date,
                      category: String) -> NewsArticle {
        let article = NewsArticle(context: context)
        article.title = title
        article.content = content
        article.source = source
        article.url = url
        article.imageUrl = imageUrl
        article.publishedAt = publishedAt
        article.isRead = false
        article.isBookmarked = false
        article.category = category
        return article
    }
} 