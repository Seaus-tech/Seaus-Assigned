import SwiftUI

struct AdaptiveStandardView: View {
    @Binding var classes: [SchoolClass]
    @Binding var students: [Student]
    @Binding var assignments: [TaskAssignment]
    
    @State private var newClassName = ""
    @State private var newClassRoom = ""
    @State private var newStudentName = ""
    @State private var selectedStudentClass = ""
    @State private var newAssignmentTitle = ""
    @State private var selectedAssignmentStudent = ""
    
    #if os(iOS)
    @Environment(\.horizontalSizeClass) var sizeClass
    #endif
    
    let statuses = ["Pending", "In Progress", "Completed"]
    
    var body: some View {
        #if os(iOS)
        if sizeClass == .compact {
            TabView {
                NavigationView { DashboardPanel().navigationTitle("Ledger") }
                    .tabItem { Label("Assignments", systemImage: "doc.plaintext") }
                NavigationView { ControlPanel().navigationTitle("Management") }
                    .tabItem { Label("Controls", systemImage: "slider.horizontal.3") }
            }
            .tint(Color.blue)
        } else {
            SplitWidescreenView()
        }
        #else
        SplitWidescreenView()
        #endif
    }
    
    @ViewBuilder
    func SplitWidescreenView() -> some View {
        NavigationView {
            ControlPanel().navigationTitle("Seaus Control")
            DashboardPanel().navigationTitle("Dashboard")
        }
        .tint(Color.blue) // Manually injects system blue accent to satisfy global asset missing errors
    }
    
    @ViewBuilder
    func ControlPanel() -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                #if os(iOS) || os(macOS)
                EdClubSyncButton(assignments: $assignments)
                #endif
                
                // Class Form
                VStack(alignment: .leading, spacing: 8) {
                    Text("🏫 Create Course").font(.headline)
                    TextField("Class Name", text: $newClassName).textFieldStyle(.roundedBorder)
                    TextField("Room Number", text: $newClassRoom).textFieldStyle(.roundedBorder)
                    Button("Save Class") {
                        if !newClassName.isEmpty {
                            classes.append(SchoolClass(name: newClassName, room: newClassRoom))
                            newClassName = ""; newClassRoom = ""
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Color.blue)
                }
                .padding().background(Color.secondary.opacity(0.08)).cornerRadius(12)
                
                // Student Form
                VStack(alignment: .leading, spacing: 8) {
                    Text("👨‍🎓 Register Student").font(.headline)
                    TextField("Full Name", text: $newStudentName).textFieldStyle(.roundedBorder)
                    Picker("Course Group", selection: $selectedStudentClass) {
                        Text("No Class").tag("")
                        ForEach(classes, id: \.self) { Text($0.name).tag($0.name) }
                    }.pickerStyle(.menu)
                    Button("Add Student") {
                        if !newStudentName.isEmpty {
                            students.append(Student(name: newStudentName, assignedClass: selectedStudentClass))
                            newStudentName = ""
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Color.green)
                }
                .padding().background(Color.secondary.opacity(0.08)).cornerRadius(12)
                
                // Assignment Form
                VStack(alignment: .leading, spacing: 8) {
                    Text("📝 Assign Task").font(.headline)
                    TextField("Task Title / Seat Id", text: $newAssignmentTitle).textFieldStyle(.roundedBorder)
                    Picker("Target Student", selection: $selectedAssignmentStudent) {
                        Text("-- Select --").tag("")
                        ForEach(students, id: \.self) { Text($0.name).tag($0.name) }
                    }.pickerStyle(.menu)
                    Button("Issue Assignment") {
                        if !newAssignmentTitle.isEmpty && !selectedAssignmentStudent.isEmpty {
                            let target = students.first(where: { $0.name == selectedAssignmentStudent })
                            let className = target?.assignedClass ?? "General Base"
                            assignments.append(TaskAssignment(title: newAssignmentTitle, studentName: selectedAssignmentStudent, className: className))
                            newAssignmentTitle = ""
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Color.purple)
                }
                .padding().background(Color.secondary.opacity(0.08)).cornerRadius(12)
            }.padding()
        }
    }
    
    @ViewBuilder
    func DashboardPanel() -> some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                MetricWidget(title: "Classes", count: classes.count, color: Color.blue)
                MetricWidget(title: "Students", count: students.count, color: Color.green)
                MetricWidget(title: "Tasks", count: assignments.count, color: Color.purple)
            }.padding()
            
            #if os(iOS)
            List {
                AssignmentRowsView()
            }.listStyle(.insetGrouped)
            #else
            List {
                AssignmentRowsView()
            }.listStyle(.inset)
            #endif
        }
    }
    
    @ViewBuilder
    func AssignmentRowsView() -> some View {
        ForEach(assignments.indices, id: \.self) { index in
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    HStack(spacing: 6) {
                        Text(assignments[index].title).font(.headline)
                        if let provider = assignments[index].externalProvider {
                            Text(provider)
                                .font(.system(size: 9, weight: .bold))
                                .padding(.horizontal, 5)
                                .padding(.vertical, 1.5)
                                .background(Color.orange.opacity(0.15))
                                .foregroundColor(.orange)
                                .cornerRadius(4)
                        }
                    }
                    Spacer()
                    Button(action: { assignments.remove(at: index) }) {
                        Image(systemName: "trash").foregroundColor(.red)
                    }.buttonStyle(.borderless)
                }
                HStack {
                    Label(assignments[index].studentName, systemImage: "person.fill")
                    Spacer()
                    Label(assignments[index].className, systemImage: "graduationcap.fill")
                }.font(.subheadline).foregroundColor(.secondary)
                
                Picker("Status", selection: $assignments[index].status) {
                    ForEach(statuses, id: \.self) { Text($0).tag($0) }
                }
                .pickerStyle(.segmented)
                .padding(.top, 2)
                .tint(Color.blue)
            }.padding(.vertical, 4)
        }
    }
}

struct MetricWidget: View {
    var title: String
    var count: Int
    var color: Color
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title.uppercased()).font(.caption2).bold().foregroundColor(.secondary)
            Text("\(count)").font(.title2).bold().foregroundColor(color)
        }
        .frame(maxWidth: .infinity, alignment: .leading).padding()
        .background(Color.secondary.opacity(0.05)).cornerRadius(10)
    }
}
