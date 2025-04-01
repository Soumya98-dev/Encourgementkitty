import SwiftUI
import PencilKit

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
        
        // Initialize the canvas with the current drawing
        canvasView.drawing = currentDrawing
        
        return canvasView
    }
    
    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        // Update the tool if changed
        if type(of: uiView.tool) != type(of: currentTool) {
            uiView.tool = currentTool
        }
        // If SwiftUI changed the drawing externally, update the canvas
        if uiView.drawing != currentDrawing {
            uiView.drawing = currentDrawing
        }
    }
    
    // MARK: - Coordinator
    class Coordinator: NSObject, PKCanvasViewDelegate {
        var parent: PencilCanvasView
        
        init(_ parent: PencilCanvasView) {
            self.parent = parent
        }
        
        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            // Whenever the user draws/erases, update SwiftUI’s state
            parent.currentDrawing = canvasView.drawing
        }
    }
}

//import SwiftUI
//import PencilKit

struct NotesPageView: View {
    // Default is a black pen.
    @State private var currentTool: PKTool = PKInkingTool(.pen, color: .black, width: 5)
    
    // Track the user’s drawing
    @State private var currentDrawing = PKDrawing()
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            
            // 1) Light pink background
            Color(red: 1.0, green: 0.95, blue: 0.9)
                .edgesIgnoringSafeArea(.all)
            
            // 2) Horizontal lines
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
            
            // 3) Left margin
            Rectangle()
                .fill(Color(red: 1.0, green: 0.8, blue: 0.85))
                .frame(width: 80)
                .edgesIgnoringSafeArea(.vertical)
            
            // 4) PencilKit canvas (transparent so lines show behind it)
            PencilCanvasView(currentTool: $currentTool, currentDrawing: $currentDrawing)
                .edgesIgnoringSafeArea(.all)
            
            // 5) Top bar icons
            HStack {
                // --- FIRST ICON: Save the drawing to disk ---
                Button(action: {
                    saveDrawing()
                }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(red: 1.0, green: 0.7, blue: 0.8))
                            .frame(width: 40, height: 40)
                        
                        Image(systemName: "list.bullet.rectangle")
                            .foregroundColor(.white)
                    }
                }
                
                // --- SECOND ICON (placeholder) ---
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(red: 1.0, green: 0.7, blue: 0.8))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: "rectangle.grid.2x2")
                        .foregroundColor(.white)
                }
                .padding(.leading, 20)
                
                Spacer()
                
                // --- RIGHT ICON: Toggle pen/eraser ---
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
            
            // If you want typed text, uncomment below:
/*
            VStack {
                Spacer()
                HStack {
                    TextEditor(text: $typedNotes)
                        .frame(height: 100)
                        .padding(8)
                        .background(Color.white.opacity(0.3))
                        .cornerRadius(8)
                        .padding(.leading, 100)
                        .padding(.trailing, 100)
                }
                .padding(.bottom, 20)
            }
*/
        }
        .onAppear {
            loadDrawing()
        }
    }
    
    // MARK: - Save/Load Logic
    private func saveDrawing() {
        let data = currentDrawing.dataRepresentation()
        let url = getDocumentsDirectory().appendingPathComponent("SavedDrawing.data")
        
        do {
            try data.write(to: url)
            print("Drawing saved to: \(url.path)")
        } catch {
            print("Error saving drawing: \(error)")
        }
    }
    
    private func loadDrawing() {
        let url = getDocumentsDirectory().appendingPathComponent("SavedDrawing.data")
        
        guard let data = try? Data(contentsOf: url) else { return }
        do {
            currentDrawing = try PKDrawing(data: data)
            print("Loaded saved drawing!")
        } catch {
            print("Error loading drawing: \(error)")
        }
    }
    
    private func getDocumentsDirectory() -> URL {
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
