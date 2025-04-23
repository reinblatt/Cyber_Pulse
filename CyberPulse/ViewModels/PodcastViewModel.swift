import Foundation
import Combine
import AVFoundation

class PodcastViewModel: ObservableObject {
    private let coreDataManager = CoreDataManager.shared
    private let feedService = FeedService.shared
    private var audioPlayer: AVPlayer?
    private var timeObserver: Any?
    
    @Published var episodes: [PodcastEpisode] = []
    @Published var currentEpisode: PodcastEpisode?
    @Published var isPlaying = false
    @Published var currentTime: Double = 0
    @Published var duration: Double = 0
    @Published var playbackRate: Float = 1.0
    @Published var selectedPodcast: String?
    @Published var isLoading = false
    @Published var error: String?
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupAudioSession()
        loadEpisodes()
    }
    
    deinit {
        removeTimeObserver()
    }
    
    // MARK: - Setup
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Error setting up audio session: \(error)")
        }
    }
    
    // MARK: - Episode Management
    func loadEpisodes() {
        episodes = coreDataManager.fetchPodcastEpisodes(podcastName: selectedPodcast)
    }
    
    func refreshEpisodes() {
        isLoading = true
        error = nil
        
        feedService.refreshFeeds()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.error = error.localizedDescription
                }
            } receiveValue: { [weak self] _ in
                self?.loadEpisodes()
            }
            .store(in: &cancellables)
    }
    
    func filterEpisodes(by podcastName: String?) {
        selectedPodcast = podcastName
        loadEpisodes()
    }
    
    // MARK: - Playback Control
    func playEpisode(_ episode: PodcastEpisode) {
        if currentEpisode?.id == episode.id {
            resumePlayback()
            return
        }
        
        stopPlayback()
        currentEpisode = episode
        
        if episode.isDownloaded, let localPath = episode.localAudioPath {
            let localURL = URL(fileURLWithPath: localPath)
            audioPlayer = AVPlayer(url: localURL)
        } else {
            audioPlayer = AVPlayer(url: episode.audioURL)
        }
        
        setupTimeObserver()
        audioPlayer?.play()
        isPlaying = true
    }
    
    func pausePlayback() {
        audioPlayer?.pause()
        isPlaying = false
    }
    
    func resumePlayback() {
        audioPlayer?.play()
        isPlaying = true
    }
    
    func stopPlayback() {
        audioPlayer?.pause()
        audioPlayer = nil
        isPlaying = false
        currentTime = 0
        duration = 0
        removeTimeObserver()
    }
    
    func seek(to time: Double) {
        let time = CMTime(seconds: time, preferredTimescale: 1000)
        audioPlayer?.seek(to: time)
    }
    
    func setPlaybackRate(_ rate: Float) {
        playbackRate = rate
        audioPlayer?.rate = rate
    }
    
    // MARK: - Episode Management
    func markEpisodeAsPlayed(_ episode: PodcastEpisode) {
        coreDataManager.markEpisodeAsPlayed(episode)
        loadEpisodes()
    }
    
    func downloadEpisode(_ episode: PodcastEpisode) {
        guard !episode.isDownloaded else { return }
        
        let task = URLSession.shared.downloadTask(with: episode.audioURL) { [weak self] localURL, response, error in
            guard let localURL = localURL else { return }
            
            let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let destinationURL = documentsPath.appendingPathComponent("\(episode.id).mp3")
            
            do {
                try FileManager.default.moveItem(at: localURL, to: destinationURL)
                DispatchQueue.main.async {
                    self?.coreDataManager.markEpisodeAsDownloaded(episode, localPath: destinationURL.path)
                    self?.loadEpisodes()
                }
            } catch {
                print("Error moving downloaded file: \(error)")
            }
        }
        
        task.resume()
    }
    
    func deleteDownloadedEpisode(_ episode: PodcastEpisode) {
        coreDataManager.deleteDownloadedEpisode(episode)
        loadEpisodes()
    }
    
    // MARK: - Helper Methods
    private func setupTimeObserver() {
        removeTimeObserver()
        
        let interval = CMTime(seconds: 0.5, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserver = audioPlayer?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            self?.currentTime = time.seconds
            if let duration = self?.audioPlayer?.currentItem?.duration {
                self?.duration = duration.seconds
            }
        }
    }
    
    private func removeTimeObserver() {
        if let observer = timeObserver {
            audioPlayer?.removeTimeObserver(observer)
            timeObserver = nil
        }
    }
    
    // MARK: - Formatting
    func formatTime(_ time: Double) -> String {
        let hours = Int(time) / 3600
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%d:%02d", minutes, seconds)
        }
    }
} 