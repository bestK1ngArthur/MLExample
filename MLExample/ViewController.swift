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
        
        // Check if device has camera
        if !UIImagePickerController.isSourceTypeAvailable(.camera) {
            navigationItem.rightBarButtonItem?.isEnabled = false
        }
    }
    
    func presentPicker(type:  UIImagePickerControllerSourceType) {
        
        // Check if device has camera
        if !UIImagePickerController.isSourceTypeAvailable(.camera) && type == .camera {
            label.text = "📸😵"
            return
        }
        
        // Set picker
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
                    self?.imageView.deleteBlurEffect()
                    self?.label.text = text
                    self?.imageView.image = image
                }
            })
            
            imageView.addBlurEffect()
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        label.text = "😱"
        picker.dismiss(animated: true, completion: nil)
    }
    
    //MARK: Actions
    
    @IBAction func cameraAction(_ sender: Any) {
        self.presentPicker(type: .camera)
    }
    
    @IBAction func libraryAction(_ sender: Any) {
        self.presentPicker(type: .photoLibrary)
    }
}

extension UIImageView {
    
    func addBlurEffect() {
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.bounds
        
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight] // for supporting device rotation
        self.addSubview(blurEffectView)
    }
    
    func deleteBlurEffect() {
        for view in self.subviews {
            if view.isKind(of: UIVisualEffectView.self) {
                view.removeFromSuperview()
            }
        }
    }
}
