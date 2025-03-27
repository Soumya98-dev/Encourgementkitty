import SwiftUI

struct NotesPageView: View {
    var body: some View {
        ZStack(alignment: .topLeading) {
            
            // MARK: - Background Color
            Color(red: 1.0, green: 0.95, blue: 0.9) // light pink
                .edgesIgnoringSafeArea(.all)
            
            // MARK: - Horizontal Lined Paper
            GeometryReader { geo in
                // We'll space lines every 40 points (adjust as you wish)
                let lineSpacing: CGFloat = 40
                // Figure out how many lines fit vertically
                let lineCount = Int(geo.size.height / lineSpacing)
                
                ForEach(0..<lineCount, id: \.self) { i in
                    Path { path in
                        let yPos = lineSpacing * CGFloat(i) + 80
                        path.move(to: CGPoint(x: 0, y: yPos))
                        path.addLine(to: CGPoint(x: geo.size.width, y: yPos))
                    }
                    // Use a pink stroke to match the design
                    .stroke(Color(red: 1.0, green: 0.85, blue: 0.9), lineWidth: 1)
                }
            }
            
            // MARK: - Left Margin / Vertical Strip
            Rectangle()
                .fill(Color(red: 1.0, green: 0.8, blue: 0.85)) // darker pink strip
                .frame(width: 80)
                .edgesIgnoringSafeArea(.vertical)
            
            // MARK: - Top Bar Icons
            // If you have your own images, replace the ZStacks with Image("YourIcon").
            HStack {
                // Left icons
                HStack(spacing: 20) {
                    // Example “notebook” icon
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(red: 1.0, green: 0.7, blue: 0.8))
                            .frame(width: 40, height: 40)
                        
                        // Example system icon (change as needed)
                        Image(systemName: "list.bullet.rectangle")
                            .foregroundColor(.white)
                    }
                    
                    // Example “two-page” icon
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(red: 1.0, green: 0.7, blue: 0.8))
                            .frame(width: 40, height: 40)
                        
                        Image(systemName: "rectangle.grid.2x2")
                            .foregroundColor(.white)
                    }
                }
                .padding(.leading, 90) // push icons beyond left margin
                
                Spacer()
                
                // Right icon
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(red: 1.0, green: 0.7, blue: 0.8))
                        .frame(width: 40, height: 40)
                    
                    // Example “ellipse” icon
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
