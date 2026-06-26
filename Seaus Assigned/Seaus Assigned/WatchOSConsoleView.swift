import SwiftUI

struct WatchOSConsoleView: View {
    @Binding var classes: [SchoolClass]
    @Binding var students: [Student]
    @Binding var assignments: [TaskAssignment]
    
    var body: some View {
        #if os(watchOS)
        List {
            MainWatchContent()
        }
        .listStyle(.carousel)
        #else
        List {
            MainWatchContent()
        }
        #endif
    }
    
    @ViewBuilder
    func MainWatchContent() -> some View {
        Section(header: Text("Task Allocations")) {
            ForEach(assignments.indices, id: \.self) { i in
                VStack(alignment: .leading) {
                    Text(assignments[i].title).font(.caption).bold()
                    Text(assignments[i].studentName).font(.system(size: 10)).foregroundColor(.secondary)
                    
                    Button(action: {
                        assignments[i].status = assignments[i].status == "Pending" ? "Completed" : "Pending"
                    }) {
                        Text(assignments[i].status)
                            .font(.system(size: 9))
                            .foregroundColor(assignments[i].status == "Completed" ? .green : .orange)
                    }
                }
            }
        }
        Section(header: Text("Totals")) {
            Text("Classes: \(classes.count)")
            Text("Students: \(students.count)")
        }
    }
}
