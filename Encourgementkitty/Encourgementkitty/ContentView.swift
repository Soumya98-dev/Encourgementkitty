import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack {
            Color(red: 1.0, green: 0.78, blue: 0.94) // Soft pink background
                .ignoresSafeArea()
            
            VStack(spacing: 60) {
                
                // Top Ellipse with dual border
                ZStack {
                    Ellipse()
                        .fill(Color(red: 0.89, green: 0.37, blue: 0.67)) // inner fill color
                        .frame(width: 380, height: 240)
                    
                    Ellipse()
                        .stroke(Color.orange, lineWidth: 4)
                        .frame(width: 390, height: 250)
                }
                
                // Bottom "NOTES" Oval
                ZStack {
                    Ellipse()
                        .fill(Color(red: 0.89, green: 0.37, blue: 0.67)) // same as top fill
                        .frame(width: 280, height: 100)
                        .overlay(
                            Ellipse()
                                .stroke(Color.pink.opacity(0.6), lineWidth: 8)
                        )
                    
                    Text("NOTES")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.black)
                }
            }
        }
    }
}
