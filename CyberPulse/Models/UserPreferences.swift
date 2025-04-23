import CoreData
import Foundation

@objc(UserPreferences)
class UserPreferences: CoreDataModel {
    @NSManaged public var theme: String
    @NSManaged public var fontSize: Double
    @NSManaged public var autoDownloadEpisodes: Bool
    @NSManaged public var downloadQuality: String
    @NSManaged public var notificationEnabled: Bool
    @NSManaged public var notificationTime: Date?
    @NSManaged public var selectedCategories: [String]
    @NSManaged public var selectedSources: [String]
    @NSManaged public var lastSyncDate: Date?
    
    static func fetchRequest() -> NSFetchRequest<UserPreferences> {
        return NSFetchRequest<UserPreferences>(entityName: "UserPreferences")
    }
    
    static func create(in context: NSManagedObjectContext) -> UserPreferences {
        let preferences = UserPreferences(context: context)
        preferences.theme = "system"
        preferences.fontSize = 16.0
        preferences.autoDownloadEpisodes = false
        preferences.downloadQuality = "high"
        preferences.notificationEnabled = false
        preferences.selectedCategories = []
        preferences.selectedSources = []
        return preferences
    }
    
    override func awakeFromInsert() {
        super.awakeFromInsert()
        selectedCategories = []
        selectedSources = []
    }
} 