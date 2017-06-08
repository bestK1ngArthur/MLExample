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
    
    func recognise(image: UIImage) -> String {
        
        /*
        let imageData = UIImagePNGRepresentation(image) as Data?
        
        func resultsMethod(request: VNRequest, error: Error?) {
            guard let results = request.results as? [VNClassificationObservation]
                else { fatalError("huh") }
            for classification in results {
                print(classification.identifier, // the scene label
                    classification.confidence)
            }
        }
        
        let model = try VNCoreMLModel(for: Inceptionv3().model)
        let request = VNCoreMLRequest(model: model, completionHandler: resultsMethod)
        let handler = VNImageRequestHandler(data: imageData!)
        try handler.perform([request])
         */
        
        return "😥"
    }
    
    //MARK: UIImagePickerControllerDelegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let image = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            imageView.image = image
            label.text = recognise(image: image)
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
