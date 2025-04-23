import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            PodcastView()
                .tabItem {
                    Label("Podcasts", systemImage: "waveform")
                }
            
            Text("News Feed")
                .tabItem {
                    Label("News", systemImage: "newspaper")
                }
            
            Text("Settings")
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
} 