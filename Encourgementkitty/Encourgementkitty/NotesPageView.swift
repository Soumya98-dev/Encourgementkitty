import SwiftUI
import PencilKit

// Wraps a PKCanvasView and binds its tool to a SwiftUI state.
struct PencilCanvasView: UIViewRepresentable {
    @Binding var currentTool: PKTool
    let canvasView = PKCanvasView()
    
    func makeUIView(context: Context) -> PKCanvasView {
        canvasView.drawingPolicy = .anyInput
        canvasView.backgroundColor = .clear
        canvasView.tool = currentTool
        return canvasView
    }
    
    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        if type(of: uiView.tool) != type(of: currentTool) {
            uiView.tool = currentTool
        }
    }

}

struct NotesPageView: View {
    @State private var typedNotes: String = ""
    // Default is a black pen.
    @State private var currentTool: PKTool = PKInkingTool(.pen, color: .black, width: 5)
    
    var body: some View {
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
            
            PencilCanvasView(currentTool: $currentTool)
                .edgesIgnoringSafeArea(.all)
            
            HStack {
                HStack(spacing: 20) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(red: 1.0, green: 0.7, blue: 0.8))
                            .frame(width: 40, height: 40)
                        
                        Image(systemName: "list.bullet.rectangle")
                            .foregroundColor(.white)
                    }
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(red: 1.0, green: 0.7, blue: 0.8))
                            .frame(width: 40, height: 40)
                        
                        Image(systemName: "rectangle.grid.2x2")
                            .foregroundColor(.white)
                    }
                }
                .padding(.leading, 90)
                
                Spacer()
                
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
            .padding(.top, 20)
            
//            VStack {
//                Spacer()
//                HStack {
//                    TextEditor(text: $typedNotes)
//                        .frame(height: 100)
//                        .padding(8)
//                        .background(Color.white.opacity(0.3))
//                        .cornerRadius(8)
//                        .padding(.leading, 100)
//                        .padding(.trailing, 100)
//                }
//                .padding(.bottom, 20)
//            }
        }
    }
}

struct NotesPageView_Previews: PreviewProvider {
    static var previews: some View {
        NotesPageView()
            .previewDevice("iPad (10th generation)")
            .previewInterfaceOrientation(.portrait)
    }
}
