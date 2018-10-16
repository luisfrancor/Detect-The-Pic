//
//  ViewController.swift
//  Detect The Pic
//
//  Created by Luis Franco R on 25/08/2018.
//  Copyright © 2018 Luis Franco R. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var imageView: UIImageView!
    
    var resnetModel = Resnet50()
    var results = [VNClassificationObservation]()
    var pickerController = UIImagePickerController()
    
    // MARK: -
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        pickerController.delegate = self
        
        if let image = imageView.image {
            processPicture(image: image)
        }
        
        
    }
    
    
    // the function for when someone takes a picture
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[.originalImage] as? UIImage {
            
            imageView.image = image
            processPicture(image: image)
            
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    
    
    func processPicture(image: UIImage) {
        
        if let model = try? VNCoreMLModel(for: resnetModel.model) {
            let request = VNCoreMLRequest(model: model) { (request, error) in
                
                if let results = request.results as? [VNClassificationObservation] {
                    
                    self.results = Array(results.prefix(10))
                    self.tableView.reloadData()

//                    for result in results {
//                        print("\(result.identifier): \(result.confidence * 50)%")
//                    }
                }
            }
            
            if let imageData = image.jpegData(compressionQuality: 1.0) {
                let handler = VNImageRequestHandler(data: imageData, options: [:])
                try? handler.perform([request])
            }
        }
        
    }
    
    
    // MARK: -
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell()
        let result = results[indexPath.row]
        let name = result.identifier.prefix(30)
        
        cell.textLabel?.text = "\(name): \(Int(result.confidence * 100))%"
        
        return cell
    }
    
    
    
    // MARK: -
    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        
        pickerController.sourceType = .camera
        present(pickerController, animated: true, completion: nil)
    }
    
    @IBAction func mediaFolderTapped(_ sender: UIBarButtonItem) {
        
        pickerController.sourceType = .photoLibrary
        present(pickerController, animated: true, completion: nil)
        
    }
    
}

