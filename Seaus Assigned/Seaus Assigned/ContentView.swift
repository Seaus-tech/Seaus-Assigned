import SwiftUI

struct ContentView: View {
    @State private var classes: [SchoolClass] = [
        SchoolClass(name: "Advanced Mathematics", room: "Room 402"),
        SchoolClass(name: "Bio-Chemistry", room: "Lab 3")
    ]
    @State private var students: [Student] = [
        Student(name: "Jane Doe", assignedClass: "Advanced Mathematics"),
        Student(name: "John Smith", assignedClass: "Bio-Chemistry")
    ]
    @State private var assignments: [TaskAssignment] = [
        TaskAssignment(title: "Term Paper Assignment", studentName: "Jane Doe", className: "Advanced Mathematics", status: "Pending")
    ]

    var body: some View {
        #if os(watchOS)
        WatchOSConsoleView(classes: $classes, students: $students, assignments: $assignments)
        #else
        #if os(tvOS)
        TvOSConsoleView(classes: $classes, students: $students, assignments: $assignments)
        #else
        AdaptiveStandardView(classes: $classes, students: $students, assignments: $assignments)
        #endif
        #endif
    }
}
