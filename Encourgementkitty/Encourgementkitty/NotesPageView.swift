import SwiftUI

struct NotesPageView: View {
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
                
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(red: 1.0, green: 0.7, blue: 0.8))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: "circle.fill")
                        .foregroundColor(.white)
                }
                .padding(.trailing, 20)
            }
            .padding(.top, 20)
        }
    }
}

// MARK: - Preview
struct NotesPageView_Previews: PreviewProvider {
    static var previews: some View {
        NotesPageView()
            .previewDevice("iPad (10th generation)")
            .previewInterfaceOrientation(.portrait)
    }
}
