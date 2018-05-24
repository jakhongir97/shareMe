//
//  ViewController.swift
//  startUp
//
//  Created by Jahongir Nematov on 2/23/18.
//  Copyright © 2018 Jahongir Nematov. All rights reserved.
//

import UIKit
import Pulsator

class ContactSwitchViewController: UIViewController {
    
    @IBOutlet weak var connectionsLabel: UILabel!
    @IBOutlet weak var contactNameLabel: UILabel!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var dialogImageView: UIImageView!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var savedLabel: UILabel!
    
    
    let contactService = ContactServiceManager()
    
    var userData = UserData()
    
    let pulsator = Pulsator()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        contactService.delegate = self
        self.contactNameLabel.text = ""
        self.connectionsLabel.text = ""
        //self.connectionsLabel.isHidden = true
        self.button.layer.cornerRadius = button.frame.height/2
        self.avatarImageView.layer.cornerRadius = avatarImageView.frame.height/2
        self.dialogImageView.isHidden = true
        self.avatarImageView.isHidden = true
        self.button.isEnabled = true

        self.setupPulsator()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.pulsator.start()
    }
    
    
    @IBAction func syncronize(_ sender: Any) {
        if UserDefaults.standard.bool(forKey: "isRegistered") {
            guard let name = UserDefaults.standard.string(forKey: "name"),
                  let phone = UserDefaults.standard.string(forKey: "phone"),
                  let imageData = UserDefaults.standard.data(forKey: "profileImage") else {return}
            
            contactService.send(contactName: name, phone: phone, imageData: imageData)
            self.dialogImageView.isHidden = false
            self.contactNameLabel.text = "Saved!"
            self.button.isEnabled = false
        }
    }
    
    
    func change(value : String) {
    
        UIView.animate(withDuration: 1) {
            self.savedLabel.isHidden = false
            self.savedLabel.textColor = .white
            self.view.backgroundColor = UIColor.init(red: 0, green: 179/255, blue: 0, alpha: 1)
            self.view.backgroundColor = UIColor.white
            
            
        }
        
    }
    
    
    
    func setupPulsator(){
        self.pulsator.numPulse = 5
        self.pulsator.radius = 240.0
        self.pulsator.backgroundColor = UIColor(red: 0, green: 84/255, blue: 147/255, alpha: 1).cgColor
        self.pulsator.animationDuration = 5
        self.pulsator.pulseInterval = 1
        self.pulsator.repeatCount = .infinity
        self.pulsator.position = CGPoint(x: button.frame.width/2, y: button.frame.height/2)
        self.button.layer.addSublayer(pulsator)
        //self.pulsator.start()
        
        
    }
    
    
    
    
  
    
}

extension ContactSwitchViewController : ContactServiceManagerDelegate {
    
    func connectedDevicesChanged(manager: ContactServiceManager, connectedDevices: [String]) {
        OperationQueue.main.addOperation {
            self.connectionsLabel.text = "Connections: \(connectedDevices)"
            self.avatarImageView.isHidden = false
      

            
            
        }
    }
    
    func contactChanged(manager: ContactServiceManager, contactNameString: String) {
        OperationQueue.main.addOperation {
            self.change(value: contactNameString)
        }
    }
    
}

