import Foundation

public struct SchoolClass: Identifiable, Hashable {
    public let id = UUID()
    public var name: String
    public var room: String
    
    public init(name: String, room: String) {
        self.name = name
        self.room = room
    }
}

public struct Student: Identifiable, Hashable {
    public let id = UUID()
    public var name: String
    public var assignedClass: String
    
    public init(name: String, assignedClass: String) {
        self.name = name
        self.assignedClass = assignedClass
    }
}

public struct TaskAssignment: Identifiable, Hashable {
    public let id = UUID()
    public var title: String
    public var studentName: String
    public var className: String
    public var status: String
    public var externalProvider: String? // e.g., "EdClub"
    
    public init(title: String, studentName: String, className: String, status: String = "Pending", externalProvider: String? = nil) {
        self.title = title
        self.studentName = studentName
        self.className = className
        self.status = status
        self.externalProvider = externalProvider
    }
}
