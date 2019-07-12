//
//  Player.swift
//  Sprint13
//
//  Created by Alex on 7/12/19.
//  Copyright © 2019 Alex. All rights reserved.
//

import AVFoundation

protocol PlayerDelegate: AnyObject { // lets us know when something occurs
    func playerDidChangeState(_ playe: Player)
}

class Player: NSObject, AVAudioPlayerDelegate {
    
    // MARK: - Properties
    
    private var audioPlayer: AVAudioPlayer?
    private var timer: Timer?
    
    // MARK - Delegate
    
    weak var delegate: PlayerDelegate?
    
    var isPlaying: Bool {
        return audioPlayer?.isPlaying ?? false
    }
    
    var elapsedTime: TimeInterval {
        return audioPlayer?.currentTime ?? 0
    }
    
    var totalTime: TimeInterval {
        return audioPlayer?.duration ?? 0
    }
    
    var remainingTime: TimeInterval {
        return totalTime - elapsedTime
    }
    
    // Convenience for pause and play
    func playPause(song: URL? = nil) {
        if isPlaying {
            pause() //audioPlayer?.play()
        } else {
            play(song: song)
        }
    }
    
    // Start playing
    func play(song: URL? = nil) {
        if let file = song {
            audioPlayer = try! AVAudioPlayer(contentsOf: file)
            audioPlayer?.delegate = self
        }
        audioPlayer?.play()
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.25, repeats: true, block: { [weak self] _ in
            self?.notifyDelegate()
        })
        notifyDelegate()
    }
    
    func pause() {
        audioPlayer?.pause()
        timer?.invalidate()
        timer = nil
        notifyDelegate()
    }
    
    private func notifyDelegate() {
        delegate?.playerDidChangeState(self)
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        notifyDelegate()
    }
}
