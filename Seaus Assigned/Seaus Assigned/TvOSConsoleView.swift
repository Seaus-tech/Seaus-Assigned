import SwiftUI

struct TvOSConsoleView: View {
    @Binding var classes: [SchoolClass]
    @Binding var students: [Student]
    @Binding var assignments: [TaskAssignment]
    
    var body: some View {
        HStack(spacing: 40) {
            VStack(alignment: .leading, spacing: 20) {
                Text("📺 Seaus TV Console").font(.title).bold()
                Text("Active Classrooms: \(classes.count)").font(.title3)
                Text("Total Student Registry: \(students.count)").font(.title3)
                Spacer()
            }
            .frame(width: 500)
            
            List {
                Text("Assignments Matrix Ledger").font(.headline).padding()
                ForEach(assignments.indices, id: \.self) { i in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(assignments[i].title).font(.title3)
                            Text("\(assignments[i].studentName) — \(assignments[i].className)").font(.body).foregroundColor(.secondary)
                        }
                        Spacer()
                        Button(assignments[i].status) {
                            assignments[i].status = assignments[i].status == "Pending" ? "Completed" : "Pending"
                        }
                    }
                    .padding()
                }
            }
        }
        .padding(60)
    }
}
