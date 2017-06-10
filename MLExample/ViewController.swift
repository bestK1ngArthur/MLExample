//
//  ViewController.swift
//  MLExample
//
//  Created by Arthur K1ng on 08/06/2017.
//  Copyright © 2017 Artem Belkov. All rights reserved.
//

import UIKit
import Vision
import CoreML

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var label: UILabel!
    
    let picker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        picker.delegate = self
        label.text = "Choose image ☝️"
    }
    
    func presentPicker(type:  UIImagePickerControllerSourceType) {
        picker.sourceType = type
        picker.allowsEditing = false
        self.present(picker, animated: true, completion: nil)
    }
    
    func recognise(image: UIImage, completion: @escaping (String) -> Void) {
        
        // Convert UIImage to CIImage
        guard let ciImage = CIImage(image: image) else {
            completion("😷") // If can't get CIImage
            return
        }
        
        // Get ML model
        guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else {
            completion("😵") // If can't get ML model
            return
        }
        
        // Create a Vision request with completion handler
        let request = VNCoreMLRequest(model: model) { request, error in
            guard let results = request.results as? [VNClassificationObservation],
                let topResult = results.first else {
                    completion("😱") // If can't get result
                    return
            }
            
            completion("\(Int(topResult.confidence * 100))% it's \(topResult.identifier)")
        }
        
        // Perform Vision request
        let handler = VNImageRequestHandler(ciImage: ciImage)
        DispatchQueue.global(qos: .userInteractive).async {
            do {
                try handler.perform([request])
            } catch {
                completion("😥")
            }
        }
    }
    
    //MARK: UIImagePickerControllerDelegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let image = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            
            // Try to recognise image
            recognise(image: image, completion: { (text) in
                
                // Update UI on main queue
                DispatchQueue.main.async { [weak self] in
                    self?.label.text = text
                    self?.imageView.image = image
                }
            })
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        label.text = "😱"
    }
    
    //MARK: Actions
    
    @IBAction func cameraAction(_ sender: Any) {
        self.presentPicker(type: .camera)
    }
    
    @IBAction func libraryAction(_ sender: Any) {
        self.presentPicker(type: .photoLibrary)
    }
}
