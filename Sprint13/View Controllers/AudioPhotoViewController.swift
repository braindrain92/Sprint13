//
//  AudioPhotoViewController.swift
//  Sprint13
//
//  Created by Alex on 7/12/19.
//  Copyright © 2019 Alex. All rights reserved.
//

import UIKit
import AVFoundation

protocol AudioPostDelegate {
    func recordedFile(audio: URL)
}

class AudioPhotoViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, PlayerDelegate, RecorderDelegate {
    
    // MARK: - Outlets & Props

    let player = Player()
    let recorder = Recorder()
    let filter = CIFilter(name: "CIColorControls")!
    let context = CIContext(options: nil)
    
    var curentRecordedAudioURl: URL?
    var originalImage: UIImage?
    var experienceController: ExperienceController?
    
    @IBOutlet weak var playBtn: UIButton!
    @IBOutlet weak var recordBtn: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textField: UITextField!
    
    // MARK: - Actions
    
    @IBAction func choosePhoto(_ sender: Any) {
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
            return print("Photo library unavailable")
        }
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true, completion: nil)
    }
    
    @IBAction func playBtnPressed(_ sender: Any) {
        player.playPause(song: recorder.currentFile)
    }
    
    @IBAction func recordBtnPressed(_ sender: Any) {
        recorder.toggleRecording()
    }
    
    @IBAction func nextBtnPressed(_ sender: Any) {
        if curentRecordedAudioURl != nil && textField.text != nil && imageView.image != nil {
            performSegue(withIdentifier: "Video", sender: nil)
        } else {
            performSegue(withIdentifier: "Video", sender: nil) // temp for test
            return
        }
    }
    
    // MARK: - VC Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        player.delegate = self
        recorder.delegate = self
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Video" {
            guard let destination = segue.destination as? VideoViewController else { return }
            destination.titleString = textField.text
            destination.image = imageView.image
            destination.curentRecordedAudioURL = recorder.currentFile
        }
    }
    
    // MARK: - Functions
    
    func playerDidChangeState(_ player: Player) {
        updateViews()
    }
    
    func recorderDidChangeState(_ recorder: Recorder) {
        updateViews()
    }
    
    private func updateViews() {
        let isPlaying = player.isPlaying
        playBtn.setTitle(isPlaying ? "Pause" : "Play", for: .normal)
        
        let isRecording = recorder.isRecording
        recordBtn.setTitle(isRecording ? "Stop" : "Record", for: .normal)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        originalImage = info[.originalImage] as? UIImage
        imageView.image = filterImage(image: originalImage) //originalImage
        imageView.contentMode = .scaleAspectFill

    }
    
    private func filterImage(image: UIImage?) -> UIImage? {
        guard var inputImage: CIImage = image?.getCIImage() else { return image }
        
        let scale = CGFloat(1000) / max(inputImage.extent.size.width, inputImage.extent.size.height)
        if scale < 1 {
            let scaleFilter = CIFilter(name: "CILanczosScaleTransform")!
            scaleFilter.setValue(inputImage, forKey: kCIInputImageKey)
            scaleFilter.setValue(scale, forKey: kCIInputScaleKey)
            if let outputImage = scaleFilter.outputImage { inputImage = outputImage}
        }
        
        let monochromeFilter = CIFilter(name: "CIColorMonochrome")! // black & white
        let color = CIColor(red: 0.5, green: 0.5, blue: 0.5)
        monochromeFilter.setValue(inputImage, forKey: kCIInputImageKey)
        monochromeFilter.setValue(color, forKey: kCIInputColorKey)
        monochromeFilter.setValue(1.0, forKey: kCIInputIntensityKey)
        
        guard let outputImage = monochromeFilter.outputImage,
            let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else { return image }
        
        return UIImage(cgImage: cgImage)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
}

