//
//  ContentViewModel.swift
//  Name That Bop
//
//  Created by Nonprawich I. on 26/12/2024.
//

import AVKit
import ShazamKit
import SwiftUI

struct ShazamMedia: Decodable {
    let title: String?
    let subtitle: String?
    let artistName: String?
    let albumArtURL: URL?
    let genres: [String]
}

@Observable
class ContentViewModel: NSObject {
    var shazamMedia = ShazamMedia(title: nil, subtitle: nil, artistName: nil, albumArtURL: nil, genres: [])
    var isRecording = false
    private let audioEngine = AVAudioEngine()
    private let session = SHSession()
    
    override init() {
        super.init()
        session.delegate = self
    }
    
    private func resetRecording() {
        audioEngine.inputNode.removeTap(onBus: 0)
        audioEngine.stop()
        try? AVAudioSession.sharedInstance().setActive(false)
        isRecording = false
    }
    
    public func startOrEndListening() {
        if audioEngine.isRunning {
            resetRecording()
            return
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        
        do {
            try audioSession.setCategory(.record, mode: .default, options: [])
            try audioSession.setActive(true)
        } catch {
            print("Failed to set up audio session: \(error)")
            return
        }
        
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        
        let generator = SHSignatureGenerator()
        inputNode.installTap(onBus: 0, bufferSize: 2048, format: recordingFormat) { buffer, time in
            do {
                try generator.append(buffer, at: time)
                if let signature = try? generator.signature() {
                    self.session.match(signature)
                }
            } catch {
                print("Error generating signature: \(error)")
            }
        }
        
        do {
            try audioEngine.start()
            isRecording = true
        } catch {
            print("Error starting audio engine: \(error)")
            resetRecording()
        }
    }
}

extension ContentViewModel: SHSessionDelegate {
    func session(_ session: SHSession, didFind match: SHMatch) {
        guard let mediaItem = match.mediaItems.first else { return }
        
        print("=== Shazam Match Found ===")
        print("Title:", mediaItem.title ?? "N/A")
        print("Artist:", mediaItem.artist ?? "N/A")
        print("Genres:", mediaItem.genres)
        
        DispatchQueue.main.async { [weak self] in
            self?.shazamMedia = ShazamMedia(
                title: mediaItem.title,
                subtitle: mediaItem.subtitle,
                artistName: mediaItem.artist,
                albumArtURL: mediaItem.artworkURL,
                genres: mediaItem.genres
            )
            self?.resetRecording()
        }
    }
}
