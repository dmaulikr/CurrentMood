//
//  ViewController.swift
//  CurrentMood
//
//  Created by Cristian Duica on 1/21/17.
//  Copyright © 2017 Cristian Duica. All rights reserved.
//

import UIKit
import AssetsLibrary
import MobileCoreServices

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var clarifaiClient = ClarifaiClient()
    //var imageURL: NSURL!
    
    //MARK: Outlets
    @IBOutlet weak var photoImageView: UIImageView!
    
    //MARK: Actions
    @IBAction func searchClarifai(_ sender: UIButton) {
        //if imageURL != nil {
        clarifaiClient.postImage(image: photoImageView.image!, callback: postImageCallback)
        //}
    }
    
    func postImageCallback(result: [String]){
        for item in result{
            print(item)
        }
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "Segue", sender: self)
        }
    }
    
    @IBAction func selectPhoto(_ sender: UITapGestureRecognizer) {
        
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .camera
        imagePickerController.cameraCaptureMode = .photo
        imagePickerController.allowsEditing = false
        //imagePickerController.sourceType = .photoLibrary
        imagePickerController.mediaTypes = [kUTTypeImage as String]
        imagePickerController.delegate = self
        clarifaiClient.refreshToken()
        present(imagePickerController, animated: false, completion: nil)
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // Dismiss the picker if the user canceled.
        dismiss(animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var chosenImage = UIImage()
        chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        //imageURL = info[UIImagePickerControllerReferenceURL] as! NSURL
        //print(imageURL)
        photoImageView.image = chosenImage
        
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

