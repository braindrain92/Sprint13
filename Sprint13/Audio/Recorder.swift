//
//  Recorder.swift
//  Sprint13
//
//  Created by Alex on 7/12/19.
//  Copyright © 2019 Alex. All rights reserved.
//

import AVFoundation

protocol RecorderDelegate: AnyObject {
    func recorderDidChangeState(_ recorder: Recorder)
}

class Recorder: NSObject {
    
    // MARK: - Properties
    
    var audioRecorder: AVAudioRecorder?
    var currentFile: URL?
    
    var isRecording: Bool {
        return audioRecorder?.isRecording ?? false
    }
    
    weak var delegate: RecorderDelegate?
    
    // MARK: - Funcs
    
    func toggleRecording() {
        // similar to playPause method
        if isRecording {
            stop()
        } else {
            record()
        }
    }
    
    func record() {
        switch AVAudioSession.sharedInstance().recordPermission {
        case AVAudioSession.RecordPermission.granted:
            print("Permission granted")
        case AVAudioSession.RecordPermission.denied:
            print("Pemission denied")
        case AVAudioSession.RecordPermission.undetermined:
            print("Request permission here")
            AVAudioSession.sharedInstance().requestRecordPermission({ (granted) in
                print("HERE, audio access granted: \(granted)")})
        }
        
        let fileManager = FileManager.default
        let docs = try! fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        
        // Name reflects timestamp
        let name = ISO8601DateFormatter.string(from: Date(), timeZone: .current, formatOptions: [.withInternetDateTime])
        let file = docs.appendingPathComponent(name).appendingPathExtension("caf")
        let format = AVAudioFormat(standardFormatWithSampleRate: 44_100, channels: 1)!
        
        audioRecorder = try! AVAudioRecorder(url: file, format: format) // init audio object
        currentFile = file
        
        // Start recording
        audioRecorder?.record()
        notifyDelegate()
    }
    
    func stop() {
        audioRecorder?.stop()
        audioRecorder = nil
        notifyDelegate()
    }
    
    private func notifyDelegate() {
        delegate?.recorderDidChangeState(self)
    }
}
