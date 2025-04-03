import SwiftUI
import PencilKit

// MARK: - Helper Types for Emoji Overlays

struct CodablePoint: Codable {
    var x: CGFloat
    var y: CGFloat
}

extension CodablePoint {
    func toCGPoint() -> CGPoint {
        CGPoint(x: x, y: y)
    }
}

struct EmojiOverlay: Codable, Identifiable {
    let id: UUID
    let emoji: String
    var position: CodablePoint
}

// MARK: - Updated NoteData to Include Emojis

struct NoteData: Codable, Identifiable {
    let id: UUID
    let drawingData: Data
    let date: Date
    let emojiOverlays: [EmojiOverlay]
}

// MARK: - Emoji Picker View

//struct EmojiPickerView: View {
//    let emojis: [String] = ["😀", "😃", "😄", "😁", "😆", "😅", "😂", "🤣", "😊", "😍", "🤩", "😎", "😋", "😜", "🤪"]
//    var onSelect: (String) -> Void
//    
//    var body: some View {
//        ScrollView {
//            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 20) {
//                ForEach(emojis, id: \.self) { emoji in
//                    Text(emoji)
//                        .font(.largeTitle)
//                        .onTapGesture {
//                            onSelect(emoji)
//                        }
//                }
//            }
//            .padding()
//        }
//    }
//}

struct EmojiPickerView: View {
    // List your custom emoji asset names.
    let emojiAssetNames: [String] = [
        "Untitled_Artwork 12",
        "Untitled_Artwork 14",
        "Untitled_Artwork 13",
        "Untitled_Artwork 15",
        "Untitled_Artwork 11",
        "Untitled_Artwork 8",
        "Untitled_Artwork 17",
        "Untitled_Artwork 19",
        "Untitled_Artwork 18",
        "Untitled_Artwork 9",
        "Untitled_Artwork 10"
    ]
    var onSelect: (String) -> Void
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 20) {
                ForEach(emojiAssetNames, id: \.self) { assetName in
                    Image(assetName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                        .onTapGesture {
                            onSelect(assetName)
                        }
                }
            }
            .padding()
        }
    }
}


// MARK: - PencilCanvasView (Unchanged Except for Emoji Integration)

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
        
        // Toggle between pen and eraser on Apple Pencil double-tap.
        func pencilInteractionDidTap(_ interaction: UIPencilInteraction) {
            if parent.currentTool is PKEraserTool {
                parent.currentTool = PKInkingTool(.pen, color: .black, width: 5)
            } else {
                parent.currentTool = PKEraserTool(.bitmap)
            }
        }
    }
}

// MARK: - SavedNotesView

struct SavedNotesView: View {
    @Environment(\.dismiss) var dismiss
    @State private var notes: [NoteData] = []
    
    var body: some View {
        NavigationView {
            List(notes) { note in
                NavigationLink(destination: NoteEditorView(note: note)) {
                    HStack {
                        // Thumbnail for the drawing (emoji overlays not rendered in thumbnail here for simplicity)
                        if let thumbnail = drawingThumbnail(from: note.drawingData, emojiOverlays: note.emojiOverlays) {
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
    
    func drawingThumbnail(from drawingData: Data, emojiOverlays: [EmojiOverlay]) -> UIImage? {
        do {
            let drawing = try PKDrawing(data: drawingData)
            let bounds = drawing.bounds.insetBy(dx: -20, dy: -20)
            // For simplicity, we’re not compositing emojis onto the thumbnail.
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

// MARK: - NotesPageView with Emoji Picker Integration

struct NotesPageView: View {
    @State private var currentTool: PKTool = PKInkingTool(.pen, color: .black, width: 5)
    @State private var currentDrawing = PKDrawing()
    @State private var showSavedNotes = false
    @State private var showEmojiPicker = false
    @State private var emojiOverlays: [EmojiOverlay] = []
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            // Background: light pink paper.
            Color(red: 1.0, green: 0.95, blue: 0.9)
                .edgesIgnoringSafeArea(.all)
            
            // Horizontal ruled lines.
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
            
            // Left margin strip.
            Rectangle()
                .fill(Color(red: 1.0, green: 0.8, blue: 0.85))
                .frame(width: 80)
                .edgesIgnoringSafeArea(.vertical)
            
            // PencilCanvasView.
            PencilCanvasView(currentTool: $currentTool, currentDrawing: $currentDrawing)
                .edgesIgnoringSafeArea(.all)
            
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

            
            // Top bar icons.
            HStack {
                // Save icon.
                Button(action: { saveCurrentNote() }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(red: 1.0, green: 0.7, blue: 0.8))
                            .frame(width: 40, height: 40)
                        Image(systemName: "square.and.arrow.down")
                            .foregroundColor(.white)
                    }
                }
                
                // Emoji picker icon.
                Button(action: { showEmojiPicker = true }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(red: 1.0, green: 0.7, blue: 0.8))
                            .frame(width: 40, height: 40)
                        Text("😊")
                            .font(.title)
                    }
                }
                .padding(.leading, 10)
                
                // Show saved notes icon.
                Button(action: { showSavedNotes = true }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(red: 1.0, green: 0.7, blue: 0.8))
                            .frame(width: 40, height: 40)
                        Image(systemName: "list.bullet.rectangle")
                            .foregroundColor(.white)
                    }
                }
                .padding(.leading, 10)
                
                Spacer()
                
                // Toggle pen/eraser.
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
        .sheet(isPresented: $showSavedNotes) {
            SavedNotesView()
        }
        .sheet(isPresented: $showEmojiPicker) {
            EmojiPickerView(onSelect: { emoji in
                // Add the selected emoji at the center of the screen.
                let newOverlay = EmojiOverlay(id: UUID(), emoji: emoji, position: CodablePoint(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY))
                emojiOverlays.append(newOverlay)
                showEmojiPicker = false
            })
        }
        .onAppear { loadDrawing() }
    }
    
    // MARK: - Saving and Loading Functions
    
    func saveCurrentNote() {
        let newNote = NoteData(
            id: UUID(),
            drawingData: currentDrawing.dataRepresentation(),
            date: Date(),
            emojiOverlays: emojiOverlays
        )
        var allNotes = loadNotesFromDisk()
        allNotes.append(newNote)
        writeNotesToDisk(allNotes)
    }
    
    func loadDrawing() {
        let url = getDocumentsDirectory().appendingPathComponent("SavedDrawing.data")
        guard let data = try? Data(contentsOf: url) else { return }
        do {
            currentDrawing = try PKDrawing(data: data)
        } catch {
            print("Error loading drawing: \(error)")
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

struct NotesPageView_Previews: PreviewProvider {
    static var previews: some View {
        NotesPageView()
            .previewDevice("iPad (10th generation)")
            .previewInterfaceOrientation(.portrait)
    }
}


