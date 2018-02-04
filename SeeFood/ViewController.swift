//
//  ViewController.swift
//  SeeFood
//
//  Created by Admin on 2/2/18.
//  Copyright © 2018 Kai. All rights reserved.
//

import UIKit
//import CoreML
//import Vision
import VisualRecognitionV3
import SVProgressHUD
import Social

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var shareOutletButton: UIButton!
    
    let imagePicker = UIImagePickerController()
    let apiKey = "73f7c1a9e905bb59e8f8cc8085872434e8bb337e"
    let version = "2018-02-04"
    var classificationResults: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        // imagePicker.sourceType = .photoLibrary
        // imagePicker.allowsEditing = false
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        cameraButton.isEnabled = false
        
        SVProgressHUD.show()
        
        if let userPickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            imageView.image = userPickedImage
            
            imagePicker.dismiss(animated: true, completion: nil)
            
            shareOutletButton.isHidden = true
            
            let visualRecognition = VisualRecognition(apiKey: apiKey, version: version)
            
            let imageData = UIImageJPEGRepresentation(userPickedImage, 0.01)
            
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            
            let fileURL = documentsURL.appendingPathComponent("tempImage.jpg")
            
            try? imageData?.write(to: fileURL, options: [])
            
            visualRecognition.classify(imageFile: fileURL, success: { (classifiedImage) in
                let classes = classifiedImage.images.first!.classifiers.first!.classes
                
                self.classificationResults = []
                
                for index in 0..<classes.count {
                    self.classificationResults.append(classes[index].classification)
                }
                print(self.classificationResults)
                
                DispatchQueue.main.async {
                    self.cameraButton.isEnabled = true
                    SVProgressHUD.dismiss()
                }
                
                if self.classificationResults.contains("hotdog") {
                    DispatchQueue.main.async {
                        self.navigationItem.title = " hotdog "
                        self.navigationController?.navigationBar.barTintColor = UIColor.green
                        self.navigationController?.navigationBar.isTranslucent = false
                    }
                    
                } else { DispatchQueue.main.async {
                    self.navigationItem.title = "not hotdog"
                    self.navigationController?.navigationBar.barTintColor = UIColor.red
                    self.navigationController?.navigationBar.isTranslucent = false
                    }
                }
                self.shareOutletButton.isHidden = false
            })
        }
        else {
            print("there was an error picking the image")
        }
        
        
        
        //            guard let ciImage = CIImage(image: userPickedImage) else {        // Used in Section 22
        //                fatalError("could not convert to CIImage")
        //            }
        //            detect(image: ciImage)
        
        
        
        
        
        
    }
    
    /*   func detect(image: CIImage) {
     guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else {fatalError("Loading CoreML Model failed")}
     
     let request = VNCoreMLRequest(model: model) { (request, error) in
     guard let results = request.results as? [VNClassificationObservation] else {fatalError("Model failed to process image.")}
     
     if let firstResult = results.first {
     if firstResult.identifier.contains("hotdog") {
     self.navigationItem.title = "Hotdog! "
     }
     else {
     self.navigationItem.title = "Not Hotdog! "
     }
     }
     
     }
     
     let handler = VNImageRequestHandler(ciImage: image)
     
     do {
     try handler.perform([request])
     }
     catch {
     print(error)
     }
     
     }
     */
    
    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        
        imagePicker.sourceType = .photoLibrary
        
        imagePicker.allowsEditing = false
        
        present(imagePicker, animated: true, completion: nil)
        
        
        
    }
    
    @IBAction func shareButton(_ sender: UIButton) {
        if SLComposeViewController.isAvailable(forServiceType: SLServiceTypeFacebook) {
            let vc = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
            vc?.setInitialText("My food is \(navigationItem.title)")
            present(vc!, animated: true, completion: nil)
        }
        else {
            self.navigationItem.title = "Please log in to Facebook"
        }
    }
    
}

