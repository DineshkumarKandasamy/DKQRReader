//
//  ViewController.swift
//  DKQRReader
//
//  Created by Dineshkumar Kandasamy on 07/06/22.
//

import UIKit
import AVKit

class ViewController: UIViewController {
    
    @IBOutlet var previewView: VideoPreviewView!
    
    var captureSession: AVCaptureSession!
    
    var capturePhotoOutput: AVCapturePhotoOutput!
    
    var isCaptureSessionConfigured = false
    
    //MARK: - View Did Load
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        captureSession = AVCaptureSession()
        previewView.session = captureSession
        
    }
    
    //MARK: - View Will Appear
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if isCaptureSessionConfigured {
            if !captureSession.isRunning {
                captureSession.startRunning()
            }
        } else {
            configureCaptureSession()
            isCaptureSessionConfigured = true
            captureSession.startRunning()
            previewView.updateVideoOrientationForDeviceOrientation()
        }
        
        showFirstLaunchAlert()
        
    }
    
    //MARK: - View Will Disappear
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if captureSession.isRunning {
            captureSession.stopRunning()
        }
        
    }
    
    //MARK: - Private Methods
    
    private func configureCaptureSession() {
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: AVMediaType.video) else {
            print("Unable to find capture device")
            return
        }
        
        guard let videoInput = try? AVCaptureDeviceInput(device: videoCaptureDevice) else {
            print("Unable to obtain video input")
            return
        }
        
        capturePhotoOutput = AVCapturePhotoOutput()
        capturePhotoOutput.isHighResolutionCaptureEnabled = true
        capturePhotoOutput.isLivePhotoCaptureEnabled = capturePhotoOutput.isLivePhotoCaptureSupported
        
        guard captureSession.canAddInput(videoInput) else {
            print("Unable to add input")
            return
        }
        
        guard captureSession.canAddOutput(capturePhotoOutput) else {
            print("Unable to add output")
            return
        }
        
        captureSession.beginConfiguration()
        captureSession.sessionPreset = AVCaptureSession.Preset.photo
        captureSession.addInput(videoInput)
        captureSession.addOutput(capturePhotoOutput)
        captureSession.commitConfiguration()
        
    }
    
    @IBAction func selectPreview(_ sender: UITapGestureRecognizer) {
        snapPhoto()
    }
    
    
    private func showFirstLaunchAlert() {
        
        let alertShown = UserDefaults.standard.bool(forKey: "alertShown")
        
        guard !alertShown else {
            return
        }
        
        let alert = UIAlertController(title: "Welcome to the iOS 13+ QRCode-example!",
                                      message: "Try it out by tapping on the camera-preview in order to take a new photo and check the logs afterwards.",
                                      preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Got it!", style: .default, handler: { _ in
            UserDefaults.standard.set(true, forKey: "alertShown")
        }))
        
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
    private func snapPhoto() {
        
        guard let capturePhotoOutput = self.capturePhotoOutput else { return }
        guard let captureConnection = previewView.videoPreviewLayer.connection else { return }
        
        if let photoOutputConnection = capturePhotoOutput.connection(with: AVMediaType.video) {
            photoOutputConnection.videoOrientation = captureConnection.videoOrientation
        }
        
        let photoSettings = AVCapturePhotoSettings()
        photoSettings.isHighResolutionPhotoEnabled = true
        photoSettings.flashMode = .auto
        capturePhotoOutput.capturePhoto(with: photoSettings, delegate: self)
        
    }
    
    
    
}

// MARK: AVCapturePhotoCaptureDelegate

extension ViewController : AVCapturePhotoCaptureDelegate {
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        
        print("Finished processing photo")
        
        guard let cgImageRef = photo.cgImageRepresentation() else {
            return print("Could not get image representation")
        }
        
        let cgImage = cgImageRef
        print("Scanning image")
        
        DKQRReaderManager.shared.scanImage(cgImage: cgImage)
        
    }
    
}
