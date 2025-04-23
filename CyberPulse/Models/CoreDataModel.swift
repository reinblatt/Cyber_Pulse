import CoreData
import Foundation

class CoreDataModel: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var createdAt: Date
    @NSManaged public var updatedAt: Date
    
    override func awakeFromInsert() {
        super.awakeFromInsert()
        id = UUID()
        createdAt = Date()
        updatedAt = Date()
    }
    
    override func willSave() {
        super.willSave()
        updatedAt = Date()
    }
} 