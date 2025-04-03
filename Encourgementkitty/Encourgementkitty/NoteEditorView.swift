import SwiftUI
import PencilKit

struct NoteEditorView: View {
    @Environment(\.dismiss) var dismiss
    var note: NoteData
    @State private var currentDrawing: PKDrawing
    @State private var currentTool: PKTool = PKInkingTool(.pen, color: .black, width: 5)
    @State private var emojiOverlays: [EmojiOverlay]
    
    // Initialize state from the note’s drawing data and emoji overlays.
    init(note: NoteData) {
        self.note = note
        _currentDrawing = State(initialValue: (try? PKDrawing(data: note.drawingData)) ?? PKDrawing())
        _emojiOverlays = State(initialValue: note.emojiOverlays)
    }
    
    var body: some View {
        VStack {
            ZStack(alignment: .topLeading) {
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
                
                PencilCanvasView(currentTool: $currentTool, currentDrawing: $currentDrawing)
                    .edgesIgnoringSafeArea(.all)
            }
            
            // Emoji overlays.
//            ForEach(emojiOverlays) { overlay in
//                Text(overlay.emoji)
//                    .font(.system(size: 50))
//                    .position(overlay.position.toCGPoint())
//                    .gesture(
//                        DragGesture().onChanged { value in
//                            if let index = emojiOverlays.firstIndex(where: { $0.id == overlay.id }) {
//                                emojiOverlays[index].position = CodablePoint(x: value.location.x, y: value.location.y)
//                            }
//                        }
//                    )
//            }
            ForEach(emojiOverlays) { overlay in
                Image(overlay.emoji)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                    .position(overlay.position.toCGPoint())
                    .gesture(
                        DragGesture().onChanged { value in
                            if let index = emojiOverlays.firstIndex(where: { $0.id == overlay.id }) {
                                emojiOverlays[index].position = CodablePoint(x: value.location.x, y: value.location.y)
                            }
                        }
                    )
            }

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
        var notes = loadNotesFromDisk()
        if let index = notes.firstIndex(where: { $0.id == note.id }) {
            let updatedNote = NoteData(
                id: note.id,
                drawingData: currentDrawing.dataRepresentation(),
                date: Date(),
                emojiOverlays: emojiOverlays
            )
            notes[index] = updatedNote
            writeNotesToDisk(notes)
        }
        dismiss()
    }
    
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
