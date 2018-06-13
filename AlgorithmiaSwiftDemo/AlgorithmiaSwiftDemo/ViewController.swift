//
//  ViewController.swift
//  AlgorithmiaSwiftDemo
//
//  Created by Erik Ilyin on 11/1/16.
//  Copyright © 2016 algorithmia. All rights reserved.
//
let API_KEY = "simjmvuBpdzWZu3kA1qTzfeUw8W1"

import UIKit
import Algorithmia
class ViewController: UIViewController ,UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
//    let client = Algorithmia.client(simpleKey: ProcessInfo.processInfo.environment["ALGORITHMIA_API_KEY"] ?? "%PLACE_YOUR_API_KEY%")
    let client = Algorithmia.client(simpleKey: API_KEY)
    let imagePicker = UIImagePickerController()
    var image:UIImage?
    let sourcePath = "data://.my/test/photo.jpg"
    let resultPath = "data://.my/test/result.jpg"
    let filters = ["alien_goggles", "aqua", "blue_brush", "blue_granite", "bright_sand", "cinnamon_rolls", "clean_view", "colorful_blocks", "colorful_dream", "crafty_painting", "creativity", "crunch_paper", "dark_rain", "dark_soul", "deep_connections", "dry_skin", "far_away", "gan_vogh", "gred_mash", "green_zuma", "hot_spicy", "neo_instinct", "oily_mcoilface", "plentiful", "post_modern", "purp_paper", "purple_pond", "purple_storm", "rainbow_festival", "really_hot", "sand_paper", "smooth_ride", "space_pizza", "spagetti_accident", "sunday", "yellow_collage", "yellow_paper"]
    
    @IBOutlet weak var srcImageView: UIImageView!
    @IBOutlet weak var resultImageView: UIImageView!
    @IBOutlet weak var statusLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func onCamera(_ sender: AnyObject) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .camera
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func onLibrary(_ sender: AnyObject) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            image = pickedImage
            srcImageView.image = pickedImage
            startProcess()
        }
        imagePicker.dismiss(animated: true, completion: nil)
        
    }
    
    func startProcess() {
        uploadImage()
        statusLabel.text = "Processing image..."
    }
    
    func display(error:Error) {
        DispatchQueue.main.async {
            if let error = error as? AlgoError {
            self.statusLabel.text = error.localizedDescription
            }
        }
    }
    
    func uploadImage() {
        // Upload file using Data API
        let file = client.file(sourcePath)
        file.put(data: UIImageJPEGRepresentation(image!, 0.7)!) { error in
            if let error = error {
                print(error)
                self.display(error: error)
                return
            }
            self.processImage(file: file)
        }
    }
    
    func processImage(file:AlgoDataFile) {
        // make a random index number
        let randomIndex = Int(arc4random_uniform(UInt32(filters.count)))
        let selected_filter = filters[randomIndex]

        let param:[String:Any] = [
            "images": [
                file.toDataURI()
            ],
            "savePaths": [
                resultPath
            ],
            "filterName": selected_filter
        ]
        
        // Process with DeepFilter algorithm
        self.client.algo(algoUri: "algo://deeplearning/DeepFilter").pipe(json: param, completion: { (response, error) in
            if let error = error {
                print(error)
                self.display(error: error)
                return
            }
            self.downloadOutput(file: self.client.file(self.resultPath))
        })
    }
    
    func downloadOutput(file:AlgoDataFile) {
        // Download output file
        file.getData { (data, error) in
            if let error = error {
                print(error)
                self.display(error: error)
                return
            }
            DispatchQueue.main.async {
                self.resultImageView.image = UIImage(data: data!)
                self.statusLabel.text = " "
            }
        }
        
    }
    
    
    

}

