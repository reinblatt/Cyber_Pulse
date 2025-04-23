import Foundation

enum NewsSeverity: String, CaseIterable {
    case critical
    case high
    case medium
    case low
    
    var color: UIColor {
        switch self {
        case .critical:
            return .systemRed
        case .high:
            return .systemOrange
        case .medium:
            return .systemYellow
        case .low:
            return .systemGreen
        }
    }
}

struct NewsItem: Identifiable {
    let id: UUID
    let title: String
    let content: String
    let source: String
    let date: Date
    let severity: NewsSeverity
    let imageURL: URL?
    let url: URL
    
    init(id: UUID = UUID(),
         title: String,
         content: String,
         source: String,
         date: Date = Date(),
         severity: NewsSeverity,
         imageURL: URL? = nil,
         url: URL) {
        self.id = id
        self.title = title
        self.content = content
        self.source = source
        self.date = date
        self.severity = severity
        self.imageURL = imageURL
        self.url = url
    }
} 