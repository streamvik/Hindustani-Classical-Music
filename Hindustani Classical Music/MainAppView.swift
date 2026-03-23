import SwiftUI

struct MainAppView: View {
    var body: some View {
        TabView {
            // Tab 1: The Landing Screen
            TanpuraView()
                .tabItem {
                    Image(systemName: "play.circle.fill")
                    Text("Practice")
                }
            
            // Tab 2: The Notepad Screen
            NotationView()
                .tabItem {
                    Image(systemName: "square.and.pencil")
                    Text("Compose")
                }
        }
        .accentColor(.blue)
    }
}

#Preview {
    MainAppView()
}
