import SwiftUI
import UIKit

struct PodcastPlayerView: View {
    let episode: PodcastEpisode
    @ObservedObject var viewModel: PodcastViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 32) {
            // Episode Artwork
            if let imageData = episode.imageData,
               let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity)
                    .cornerRadius(12)
                    .shadow(radius: 10)
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray5))
                    .aspectRatio(1, contentMode: .fit)
                    .frame(maxWidth: .infinity)
            }
            
            // Episode Info
            VStack(spacing: 8) {
                Text(episode.title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text(episode.podcastName)
                    .font(.headline)
                    .foregroundColor(.gray)
                
                if let summary = episode.summary {
                    Text(summary)
                        .font(.body)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.top, 8)
                }
            }
            .padding(.horizontal)
            
            // Progress Bar
            VStack(spacing: 8) {
                Slider(value: Binding(
                    get: { viewModel.currentTime },
                    set: { viewModel.seek(to: $0) }
                ), in: 0...viewModel.duration)
                .accentColor(.accentColor)
                
                HStack {
                    Text(viewModel.formatTime(viewModel.currentTime))
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Spacer()
                    
                    Text(viewModel.formatTime(viewModel.duration))
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            .padding(.horizontal)
            
            // Playback Controls
            HStack(spacing: 32) {
                Button(action: {
                    viewModel.seek(to: viewModel.currentTime - 30)
                }) {
                    Image(systemName: "gobackward.30")
                        .font(.title)
                }
                
                Button(action: {
                    viewModel.seek(to: viewModel.currentTime - 15)
                }) {
                    Image(systemName: "gobackward.15")
                        .font(.title2)
                }
                
                Button(action: {
                    if viewModel.isPlaying {
                        viewModel.pausePlayback()
                    } else {
                        viewModel.resumePlayback()
                    }
                }) {
                    Image(systemName: viewModel.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(size: 64))
                }
                
                Button(action: {
                    viewModel.seek(to: viewModel.currentTime + 15)
                }) {
                    Image(systemName: "goforward.15")
                        .font(.title2)
                }
                
                Button(action: {
                    viewModel.seek(to: viewModel.currentTime + 30)
                }) {
                    Image(systemName: "goforward.30")
                        .font(.title)
                }
            }
            
            // Playback Speed
            HStack(spacing: 16) {
                ForEach([0.5, 0.75, 1.0, 1.25, 1.5, 2.0], id: \.self) { rate in
                    Button(action: {
                        viewModel.setPlaybackRate(rate)
                    }) {
                        Text("\(rate, specifier: "%.2f")x")
                            .font(.subheadline)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(viewModel.playbackRate == rate ? Color.accentColor : Color(.systemGray6))
                            .foregroundColor(viewModel.playbackRate == rate ? .white : .primary)
                            .cornerRadius(16)
                    }
                }
            }
            
            // Episode Actions
            HStack(spacing: 32) {
                Button(action: {
                    if episode.isDownloaded {
                        viewModel.deleteDownloadedEpisode(episode)
                    } else {
                        viewModel.downloadEpisode(episode)
                    }
                }) {
                    VStack {
                        Image(systemName: episode.isDownloaded ? "trash" : "arrow.down.circle")
                            .font(.title2)
                        Text(episode.isDownloaded ? "Delete" : "Download")
                            .font(.caption)
                    }
                }
                
                Button(action: {
                    viewModel.markEpisodeAsPlayed(episode)
                }) {
                    VStack {
                        Image(systemName: "checkmark.circle")
                            .font(.title2)
                        Text("Mark as Played")
                            .font(.caption)
                    }
                }
            }
            .padding(.top, 16)
            
            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                }
            }
        }
    }
} 