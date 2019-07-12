//
//  VideoViewController.swift
//  Sprint13
//
//  Created by Alex on 7/12/19.
//  Copyright © 2019 Alex. All rights reserved.
//

import UIKit
import AVFoundation
import MapKit
import AVKit

class VideoViewController: UIViewController, CLLocationManagerDelegate, AVCaptureFileOutputRecordingDelegate {
    
    // MARK: - Properties
    
    var vidoeRecordedURL: URL?
    var player: AVPlayer?
    var titleString: String?
    var image: UIImage?
    var curentRecordedAudioURL: URL?
    var experienceController = ExperienceController()
    var experiences: [Experience]? = []
    var audioController: AudioPhotoViewController?
    private let fileOutput = AVCaptureMovieFileOutput()
    private let captureSession = AVCaptureSession()
    
    private lazy var locationManager: CLLocationManager = {
        let result = CLLocationManager()
        result.delegate = self
        return result
    }()
    
    // MARK: - Outlets
    
    @IBOutlet weak var recordBtn: UIButton!
    @IBOutlet weak var cameraView: CameraPreviewView!
    
    // MARK: - Actions
    
    @IBAction func saveBtnPressed(_ sender: Any) {
        locationManager.requestWhenInUseAuthorization()
        
        locationManager.startUpdatingLocation()
        guard let title = titleString, let image = image, let audioURL = curentRecordedAudioURL, let videoURL = vidoeRecordedURL,
            let location = locationManager.location else {return}
        locationManager.stopUpdatingLocation()

        let coordinate = location.coordinate
        ExperienceController.shared.addExperience(title: title, image: image, audioURL: audioURL, videoURL: videoURL, coordinate: coordinate)
        
        experiences = ExperienceController.shared.experiences
        
        if experiences != nil {
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let nextViewController = storyBoard.instantiateViewController(withIdentifier: "GeoViewController") as! GeoViewController
            self.present(nextViewController, animated:true, completion:nil)
        }
        print("HERE, SAVE BUTTON PRESSED.")
    }
    
    @IBAction func recordBtnPressed(_ sender: UIButton) {
        if fileOutput.isRecording {
            fileOutput.stopRecording()
            
            let errorAlertVC = self.createErrorAlertVC(withMessage: "Complete")

            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                
                self.present(errorAlertVC, animated: true, completion: nil)
            }


        } else {
            audioController?.recorder.record()
            fileOutput.startRecording(to: newRecordingURL(), recordingDelegate: self)
        }
    }
    
    // MARK: - VC Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let camera = bestCamera()
        guard let cameraInput = try? AVCaptureDeviceInput(device: camera) else {
            fatalError("Error using camera")
        }
        
        guard captureSession.canAddInput(cameraInput) else {
            fatalError("Error using camera")
        }
        captureSession.addInput(cameraInput)
        
        guard captureSession.canAddOutput(fileOutput) else {
            fatalError("Cannot record")
        }
        
        captureSession.addOutput(fileOutput)
        
        if captureSession.canSetSessionPreset(.hd4K3840x2160) {
            captureSession.sessionPreset = .hd4K3840x2160 // try
        } else {
            captureSession.sessionPreset = .high
        }
        
        captureSession.commitConfiguration()
        
        cameraView.session = captureSession
        cameraView.videoPreviewLayer.session = captureSession
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        captureSession.startRunning()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        captureSession.stopRunning()
    }
    
    // MARK: - Funcs
    
    func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        updateViews()
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        updateViews()
        vidoeRecordedURL = outputFileURL
    }
    
    private func bestCamera() -> AVCaptureDevice {
        if let device = AVCaptureDevice.default(.builtInDualCamera, for: .video, position: .back) {return device}
        if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {return device}
        fatalError("NO CAMERA")
    }
    
    private func newRecordingURL() -> URL {
        let fileManager = FileManager.default
        let documents = try! fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        
        let myFile = ISO8601DateFormatter()
        myFile.formatOptions = [.withInternetDateTime]
        
        let name = myFile.string(from: Date())
        return documents.appendingPathComponent(name).appendingPathExtension("mov")
    }
    
    private func updateViews() {
        let isRecording = fileOutput.isRecording
        let text = isRecording ? "stop" : "record"
        recordBtn.setImage(UIImage(named: text), for: .normal)
    }
    
    // MARK: - Error Display Helper functions
    
    private func createErrorAlertVC(withMessage : String) -> UIAlertController {
        let errorAlertVC = UIAlertController(title: "Video Added", message: withMessage, preferredStyle: .alert)
        let completionAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        errorAlertVC.addAction(completionAction)
        return errorAlertVC
    }
}
