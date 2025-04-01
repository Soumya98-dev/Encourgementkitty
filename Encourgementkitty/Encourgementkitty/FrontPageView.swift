import SwiftUI

struct FrontPageView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                // Background color
                Color(red: 1.0, green: 0.85, blue: 0.9)
                    .edgesIgnoringSafeArea(.all)
                
                // Left pink strip
                HStack(spacing: 0) {
                    Color(red: 1.0, green: 0.55, blue: 0.75)
                        .frame(width: 80)
                    Spacer()
                }
                
                // Main content in a VStack
                VStack {
                    Spacer().frame(height: 50)
                    
                    // 1) The "Encouragement Kitty" logo
                    Image("EK logo") // <-- Use your actual asset name
                        .resizable()
                        .scaledToFit()
                        .frame(width: 400) // Adjust as desired
                        .padding(.bottom, 20)
                    
                    // 2) The pink ellipse with the cat image
                    ZStack {
                        Ellipse()
                            .fill(Color(red: 1.0, green: 0.55, blue: 0.75))
                            .frame(width: 320, height: 200)
                        
                        Ellipse()
                            .fill(Color(red: 1.0, green: 0.7, blue: 0.8))
                            .frame(width: 300, height: 180)
                        
                        Image("Cat")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 320, height: 350)
                            .offset(x: 2, y: 15)
                    }
                    .padding(.bottom, 40)
                    
                    // 3) The "NOTES" button (NavigationLink)
                    NavigationLink(destination: NotesPageView()) {
                        ZStack {
                            Ellipse()
                                .fill(Color(red: 1.0, green: 0.55, blue: 0.75))
                                .frame(width: 250, height: 120)
                            
                            Ellipse()
                                .fill(Color(red: 1.0, green: 0.7, blue: 0.8))
                                .frame(width: 230, height: 100)
                            
                            Text("NOTES")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.black)
                        }
                    }
                    
                    Spacer()
                }
            }
        }
    }
}

struct FrontPageView_Previews: PreviewProvider {
    static var previews: some View {
        FrontPageView()
            .previewDevice("iPad (10th generation)")
            .previewInterfaceOrientation(.portrait)
    }
}
