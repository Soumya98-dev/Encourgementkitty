import SwiftUI
import PencilKit

struct NoteData: Codable, Identifiable {
    let id: UUID
    let drawingData: Data
    let date: Date
}

struct PencilCanvasView: UIViewRepresentable {
    @Binding var currentTool: PKTool
    @Binding var currentDrawing: PKDrawing
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> PKCanvasView {
        let canvasView = PKCanvasView()
        canvasView.delegate = context.coordinator
        canvasView.drawingPolicy = .anyInput
        canvasView.backgroundColor = .clear
        canvasView.tool = currentTool
        canvasView.drawing = currentDrawing
        
        // Add UIPencilInteraction to capture Apple Pencil double-tap gesture.
        let pencilInteraction = UIPencilInteraction()
        pencilInteraction.delegate = context.coordinator
        canvasView.addInteraction(pencilInteraction)
        
        return canvasView
    }
    
    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        if type(of: uiView.tool) != type(of: currentTool) {
            uiView.tool = currentTool
        }
        if uiView.drawing != currentDrawing {
            uiView.drawing = currentDrawing
        }
    }
    
    // MARK: - Coordinator
    
    class Coordinator: NSObject, PKCanvasViewDelegate, UIPencilInteractionDelegate {
        var parent: PencilCanvasView
        
        init(_ parent: PencilCanvasView) {
            self.parent = parent
        }
        
        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            parent.currentDrawing = canvasView.drawing
        }
        
        // This delegate method is called when the user double-taps the Apple Pencil.
        func pencilInteractionDidTap(_ interaction: UIPencilInteraction) {
            // Toggle between pen and eraser.
            if parent.currentTool is PKEraserTool {
                parent.currentTool = PKInkingTool(.pen, color: .black, width: 5)
            } else {
                parent.currentTool = PKEraserTool(.bitmap)
            }
        }
    }
}


struct SavedNotesView: View {
    @Environment(\.dismiss) var dismiss
    @State private var notes: [NoteData] = []
    
    var body: some View {
        NavigationView {
            List(notes) { note in
                NavigationLink(destination: NoteEditorView(note: note)) {
                    HStack {
                        // Thumbnail for the drawing
                        if let thumbnail = drawingThumbnail(from: note.drawingData) {
                            Image(uiImage: thumbnail)
                                .resizable()
                                .frame(width: 50, height: 50)
                                .cornerRadius(4)
                        }
                        VStack(alignment: .leading) {
                            Text(note.date, style: .date)
                                .font(.headline)
                            Text(note.date, style: .time)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Saved Notes")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            notes = loadNotesFromDisk()
        }
    }
    
    // Convert drawing data into a thumbnail image.
    func drawingThumbnail(from drawingData: Data) -> UIImage? {
        do {
            let drawing = try PKDrawing(data: drawingData)
            let bounds = drawing.bounds.insetBy(dx: -20, dy: -20)
            return drawing.image(from: bounds, scale: 0.2)
        } catch {
            print("Error decoding drawing: \(error)")
            return nil
        }
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
    
    func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}

struct NotesPageView: View {
    // PencilKit tool state (default: black pen).
    @State private var currentTool: PKTool = PKInkingTool(.pen, color: .black, width: 5)
    // Holds the current drawing.
    @State private var currentDrawing = PKDrawing()
    // Controls whether the SavedNotesView is shown.
    @State private var showSavedNotes = false
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            // 1) Background: light pink paper.
            Color(red: 1.0, green: 0.95, blue: 0.9)
                .edgesIgnoringSafeArea(.all)
            
            // 2) Horizontal ruled lines.
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
            
            // 3) Left margin strip.
            Rectangle()
                .fill(Color(red: 1.0, green: 0.8, blue: 0.85))
                .frame(width: 80)
                .edgesIgnoringSafeArea(.vertical)
            
            // 4) PencilKit drawing canvas (transparent so the ruled lines show).
            PencilCanvasView(currentTool: $currentTool, currentDrawing: $currentDrawing)
                .edgesIgnoringSafeArea(.all)
            
            // 5) Top bar icons.
            HStack {
                // First Icon: Save the current note.
                Button(action: {
                    saveCurrentNote()
                }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(red: 1.0, green: 0.7, blue: 0.8))
                            .frame(width: 40, height: 40)
                        Image(systemName: "square.and.arrow.down")
                            .foregroundColor(.white)
                    }
                }
                
                // Second Icon: Show list of saved notes.
                Button(action: {
                    showSavedNotes = true
                }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(red: 1.0, green: 0.7, blue: 0.8))
                            .frame(width: 40, height: 40)
                        Image(systemName: "list.bullet.rectangle")
                            .foregroundColor(.white)
                    }
                }
                .padding(.leading, 20)
                
                Spacer()
                
                // Right Icon: Toggle between pen and eraser.
                Button(action: {
                    if currentTool is PKEraserTool {
                        currentTool = PKInkingTool(.pen, color: .black, width: 5)
                    } else {
                        currentTool = PKEraserTool(.bitmap)
                    }
                }) {
                    Image(systemName: (currentTool is PKEraserTool) ? "pencil" : "eraser")
                        .foregroundColor(.white)
                        .padding(8)
                        .background(Color(red: 1.0, green: 0.7, blue: 0.8))
                        .cornerRadius(8)
                }
                .padding(.trailing, 20)
            }
            .padding(.leading, 90)
            .padding(.top, 20)
        }
        // Present the SavedNotesView in a sheet.
        .sheet(isPresented: $showSavedNotes) {
            SavedNotesView()
        }
        // Load a previously saved drawing when the view appears.
        .onAppear {
            loadDrawing()
        }
    }
    
    // MARK: - Saving and Loading Functions
    
    /// Save the current drawing as a new note.
    func saveCurrentNote() {
        let newNote = NoteData(
            id: UUID(),
            drawingData: currentDrawing.dataRepresentation(),
            date: Date()
        )
        var allNotes = loadNotesFromDisk()
        allNotes.append(newNote)
        writeNotesToDisk(allNotes)
    }
    
    /// Load a previously saved drawing into the canvas.
    func loadDrawing() {
        let url = getDocumentsDirectory().appendingPathComponent("SavedDrawing.data")
        guard let data = try? Data(contentsOf: url) else { return }
        do {
            currentDrawing = try PKDrawing(data: data)
        } catch {
            print("Error loading drawing: \(error)")
        }
    }
    
    /// Load saved notes from disk.
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
    
    /// Write an array of notes to disk.
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
    
    /// Helper: Return the URL for the app’s Documents directory.
    func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}

struct NotesPageView_Previews: PreviewProvider {
    static var previews: some View {
        NotesPageView()
            .previewDevice("iPad (10th generation)")
            .previewInterfaceOrientation(.portrait)
    }
}
