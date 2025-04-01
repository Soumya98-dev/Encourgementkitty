import SwiftUI
import PencilKit

struct NoteEditorView: View {
    @Environment(\.dismiss) var dismiss
    var note: NoteData
    @State private var currentDrawing: PKDrawing
    @State private var currentTool: PKTool = PKInkingTool(.pen, color: .black, width: 5)
    
    // Initialize state from the note’s drawing data.
    init(note: NoteData) {
        self.note = note
        _currentDrawing = State(initialValue: (try? PKDrawing(data: note.drawingData)) ?? PKDrawing())
    }
    
    var body: some View {
        VStack {
            ZStack(alignment: .topLeading) {
                // Background with pink paper and ruled lines
                Color(red: 1.0, green: 0.95, blue: 0.9)
                    .edgesIgnoringSafeArea(.all)
                
                GeometryReader { geo in
                    let lineSpacing: CGFloat = 40
                    let lineCount = Int(geo.size.height / lineSpacing)
                    ForEach(0..<lineCount, id: \.self) { i in
                        Path { path in
                            let yPos = lineSpacing * CGFloat(i) + 80
                            path.move(to: CGPoint(x: 0, y: yPos))
                            path.addLine(to: CGPoint(x: geo.size.width, y: yPos))
                        }
                        .stroke(Color(red: 1.0, green: 0.85, blue: 0.9), lineWidth: 1)
                    }
                }
                
                Rectangle()
                    .fill(Color(red: 1.0, green: 0.8, blue: 0.85))
                    .frame(width: 80)
                    .edgesIgnoringSafeArea(.vertical)
                
                // PencilKit canvas loaded with the saved drawing
                PencilCanvasView(currentTool: $currentTool, currentDrawing: $currentDrawing)
                    .edgesIgnoringSafeArea(.all)
            }
            
            // Button to update the note
            Button(action: {
                updateNote()
            }) {
                Text("Save Update")
                    .font(.headline)
                    .padding()
                    .background(Color(red: 1.0, green: 0.7, blue: 0.8))
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding()
        }
        .navigationTitle("Edit Note")
    }
    
    func updateNote() {
        // Load the saved notes from disk.
        var notes = loadNotesFromDisk()
        // Find the index of the note to update.
        if let index = notes.firstIndex(where: { $0.id == note.id }) {
            // Create an updated note with the new drawing and current timestamp.
            let updatedNote = NoteData(
                id: note.id,
                drawingData: currentDrawing.dataRepresentation(),
                date: Date()
            )
            notes[index] = updatedNote
            writeNotesToDisk(notes)
        }
        dismiss()
    }
    
    // Helper functions for disk storage.
    func loadNotesFromDisk() -> [NoteData] {
        let url = getDocumentsDirectory().appendingPathComponent("SavedNotes.json")
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            return try decoder.decode([NoteData].self, from: data)
        } catch {
            print("Failed to load notes: \(error)")
            return []
        }
    }
    
    func writeNotesToDisk(_ notes: [NoteData]) {
        let url = getDocumentsDirectory().appendingPathComponent("SavedNotes.json")
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(notes)
            try data.write(to: url, options: .atomic)
        } catch {
            print("Error writing notes: \(error)")
        }
    }
    
    func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}


