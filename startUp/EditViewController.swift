//
//  EditViewController.swift
//  startUp
//
//  Created by Jahongir Nematov on 3/7/18.
//  Copyright © 2018 Jahongir Nematov. All rights reserved.
//

import UIKit


class EditViewController: UIViewController {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var profilemageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if UserDefaults.standard.bool(forKey: "isRegistered") {
            self.nameTextField.text = UserDefaults.standard.string(forKey: "name")
            self.phoneTextField.text = UserDefaults.standard.string(forKey: "phone")
            guard let imageData = UserDefaults.standard.data(forKey: "profileImage") else {return}
            self.profilemageView.image = UIImage(data: imageData)
        } else {
            self.nameTextField.text = ""
            self.phoneTextField.text = ""
            
        }
        
        
        // Do any additional setup after loading the view.
    }

   
    
   
    
    @IBAction func save(_ sender: Any) {
        
        guard let name = nameTextField.text,
              let phone = phoneTextField.text else {return}
        
        UserDefaults.standard.set(name, forKey: "name")
        UserDefaults.standard.set(phone, forKey: "phone")
        UserDefaults.standard.set(true, forKey: "isRegistered")
        UserDefaults.standard.synchronize()
       
        navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
        
    }
    @IBAction func dismissKeyboard(_ sender: Any) {
        self.resignFirstResponder()
    }
    
   
    

   

}

extension EditViewController : UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    @objc func profileImageTapped (){
        print("Tapped")
        let image = UIImagePickerController()
        image.delegate = self
        image.sourceType = UIImagePickerControllerSourceType.photoLibrary
        
        image.allowsEditing = false
        
        self.present(image, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {

        self.dismiss(animated: true, completion: nil)
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage
        {
            profilemageView.image = image
            guard let data : Data = UIImagePNGRepresentation(image) else {return}
            UserDefaults.standard.set(data, forKey: "profileImage")
            UserDefaults.standard.synchronize()
        }
            
        else
        {
            //Error
        }
    }
    
}
