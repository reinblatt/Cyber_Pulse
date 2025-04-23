import SwiftUI
import UIKit

struct PodcastView: View {
    @StateObject private var viewModel = PodcastViewModel()
    @State private var showingPlayer = false
    @State private var searchText = ""
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Podcast Filter
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        FilterButton(title: "All Podcasts", isSelected: viewModel.selectedPodcast == nil) {
                            viewModel.filterEpisodes(by: nil)
                        }
                        
                        ForEach(Feed.defaultFeeds.filter { $0.type == .podcast }, id: \.id) { feed in
                            FilterButton(title: feed.name, isSelected: viewModel.selectedPodcast == feed.name) {
                                viewModel.filterEpisodes(by: feed.name)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 8)
                .background(Color(.systemBackground))
                
                // Episode List
                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if viewModel.episodes.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "waveform")
                            .font(.system(size: 48))
                            .foregroundColor(.gray)
                        Text("No episodes available")
                            .font(.headline)
                        Text("Pull to refresh or check your internet connection")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(viewModel.episodes, id: \.id) { episode in
                            EpisodeRow(episode: episode, viewModel: viewModel)
                                .listRowInsets(EdgeInsets())
                                .listRowSeparator(.hidden)
                                .padding(.horizontal)
                                .padding(.vertical, 8)
                                .onTapGesture {
                                    viewModel.playEpisode(episode)
                                    showingPlayer = true
                                }
                        }
                    }
                    .listStyle(.plain)
                    .refreshable {
                        viewModel.refreshEpisodes()
                    }
                }
            }
            .navigationTitle("Podcasts")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { viewModel.refreshEpisodes() }) {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
            .overlay {
                if let currentEpisode = viewModel.currentEpisode {
                    MiniPlayer(episode: currentEpisode, viewModel: viewModel)
                        .transition(.move(edge: .bottom))
                        .onTapGesture {
                            showingPlayer = true
                        }
                }
            }
            .sheet(isPresented: $showingPlayer) {
                if let currentEpisode = viewModel.currentEpisode {
                    NavigationView {
                        PodcastPlayerView(episode: currentEpisode, viewModel: viewModel)
                    }
                }
            }
        }
    }
}

// MARK: - Supporting Views
struct FilterButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.accentColor : Color(.systemGray6))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(20)
        }
    }
}

struct EpisodeRow: View {
    let episode: PodcastEpisode
    @ObservedObject var viewModel: PodcastViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top) {
                if let imageData = episode.imageData,
                   let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 60, height: 60)
                        .cornerRadius(8)
                } else {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(.systemGray5))
                        .frame(width: 60, height: 60)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(episode.title)
                        .font(.headline)
                        .lineLimit(2)
                    
                    Text(episode.podcastName)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    HStack {
                        Text(viewModel.formatTime(Double(episode.duration)))
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        if episode.isDownloaded {
                            Image(systemName: "arrow.down.circle.fill")
                                .foregroundColor(.green)
                                .font(.caption)
                        }
                        
                        if episode.isPlayed {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.blue)
                                .font(.caption)
                        }
                    }
                }
                
                Spacer()
                
                Button(action: { viewModel.playEpisode(episode) }) {
                    Image(systemName: "play.circle.fill")
                        .font(.title2)
                        .foregroundColor(.accentColor)
                }
            }
            
            if let summary = episode.summary {
                Text(summary)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .lineLimit(2)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct MiniPlayer: View {
    let episode: PodcastEpisode
    @ObservedObject var viewModel: PodcastViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            Divider()
            
            HStack(spacing: 12) {
                if let imageData = episode.imageData,
                   let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 40, height: 40)
                        .cornerRadius(6)
                }
                
                VStack(alignment: .leading) {
                    Text(episode.title)
                        .font(.subheadline)
                        .lineLimit(1)
                    Text(episode.podcastName)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                HStack(spacing: 16) {
                    Button(action: {
                        viewModel.seek(to: viewModel.currentTime - 15)
                    }) {
                        Image(systemName: "gobackward.15")
                            .font(.title3)
                    }
                    
                    Button(action: {
                        if viewModel.isPlaying {
                            viewModel.pausePlayback()
                        } else {
                            viewModel.resumePlayback()
                        }
                    }) {
                        Image(systemName: viewModel.isPlaying ? "pause.fill" : "play.fill")
                            .font(.title)
                    }
                    
                    Button(action: {
                        viewModel.seek(to: viewModel.currentTime + 15)
                    }) {
                        Image(systemName: "goforward.15")
                            .font(.title3)
                    }
                }
            }
            .padding()
            .background(Color(.systemBackground))
        }
    }
} 