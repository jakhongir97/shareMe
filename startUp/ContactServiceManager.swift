//
//  ColorServiceManager.swift
//  startUp
//
//  Created by Jahongir Nematov on 2/23/18.
//  Copyright © 2018 Jahongir Nematov. All rights reserved.
//

import Foundation
import MultipeerConnectivity
import Contacts


protocol ContactServiceManagerDelegate {
    
    func connectedDevicesChanged(manager : ContactServiceManager, connectedDevices: [String])
    func contactChanged(manager : ContactServiceManager, contactNameString: String)
    
}


class ContactServiceManager : NSObject {
    
    // Service type must be a unique string, at most 15 characters long
    // and can contain only ASCII lowercase letters, numbers and hyphens.
    private let ContactServiceType = "example-contact"
    
    private let myPeerId = MCPeerID(displayName: UIDevice.current.name)
    
    private let serviceAdvertiser : MCNearbyServiceAdvertiser
    private let serviceBrowser : MCNearbyServiceBrowser
    
    var delegate : ContactServiceManagerDelegate?
    
    lazy var session : MCSession = {
        let session = MCSession(peer: self.myPeerId, securityIdentity: nil, encryptionPreference: .required)
        session.delegate = self
        return session
    }()
    
    override init() {
        self.serviceAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerId, discoveryInfo: nil, serviceType: ContactServiceType)
        self.serviceBrowser = MCNearbyServiceBrowser(peer: myPeerId, serviceType: ContactServiceType)
        
        super.init()
        
        self.serviceAdvertiser.delegate = self
        self.serviceAdvertiser.startAdvertisingPeer()
        
        self.serviceBrowser.delegate = self
        self.serviceBrowser.startBrowsingForPeers()
    }
    
    func send(contactName : String , phone : String , imageData : Data) {
        NSLog("%@", "sendContactName: \(contactName),\(phone) to \(session.connectedPeers.count) peers")
        
        if session.connectedPeers.count > 0 {
            do {
                let dictionary = ["name" : contactName , "phone" : phone , "imageData" : imageData] as [String : Any]
                let data = NSKeyedArchiver.archivedData(withRootObject: dictionary)
                let friendProfileImageData = dictionary["imageData"] as! Data
                UserDefaults.standard.set(friendProfileImageData, forKey: "friendProfileImageData")
                
                try self.session.send(data, toPeers: session.connectedPeers, with: .reliable)
                //try self.session.send(contactName.data(using: .utf8)!, toPeers: session.connectedPeers, with: .reliable)
            }
            catch let error {
                NSLog("%@", "Error for sending: \(error)")
            }
        }
        
    }
    
    deinit {
        self.serviceAdvertiser.stopAdvertisingPeer()
        self.serviceBrowser.stopBrowsingForPeers()
    }
    
}

extension ContactServiceManager : MCNearbyServiceAdvertiserDelegate {
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        NSLog("%@", "didNotStartAdvertisingPeer: \(error)")
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        NSLog("%@", "didReceiveInvitationFromPeer \(peerID)")
        invitationHandler(true, self.session)
    }
    
}

extension ContactServiceManager : MCNearbyServiceBrowserDelegate {
    
    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        NSLog("%@", "didNotStartBrowsingForPeers: \(error)")
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        NSLog("%@", "foundPeer: \(peerID)")
        NSLog("%@", "invitePeer: \(peerID)")
        browser.invitePeer(peerID, to: self.session, withContext: nil, timeout: 10)
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        NSLog("%@", "lostPeer: \(peerID)")
    }
    
}

extension ContactServiceManager : MCSessionDelegate {
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        NSLog("%@", "peer \(peerID) didChangeState: \(state)")
        self.delegate?.connectedDevicesChanged(manager: self, connectedDevices:
            session.connectedPeers.map{$0.displayName})
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        NSLog("%@", "didReceiveData: \(data)")
        let dictionary = NSKeyedUnarchiver.unarchiveObject(with: data) as! Dictionary<String, Any>
        guard let name = dictionary["name"],
              let phone = dictionary["phone"],
              let imageData = dictionary["imageData"]  else {return}
        
        saveToContacts(name: name as! String, phone: phone as! String , imageData: imageData as! Data)
        
        self.delegate?.contactChanged(manager: self, contactNameString: name as! String )
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        NSLog("%@", "didReceiveStream")
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        NSLog("%@", "didStartReceivingResourceWithName")
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        NSLog("%@", "didFinishReceivingResourceWithName")
    }
    
}

extension ContactServiceManager {
    
    func saveToContacts(name : String , phone : String , imageData : Data) {
        
        let contact = CNMutableContact()
        
        contact.imageData = imageData as Data // The profile picture as a NSData object
        
        contact.givenName = name
        //        contact.familyName = "Appleseed"
        //
        //        let homeEmail = CNLabeledValue(label:CNLabelHome, value : "john@example.com" as NSString)
        //        let workEmail = CNLabeledValue(label:CNLabelWork, value : "j.appleseed@icloud.com" as NSString)
        //
        //        contact.emailAddresses = [homeEmail, workEmail]
        
        contact.phoneNumbers = [CNLabeledValue(
            label:CNLabelPhoneNumberiPhone,
            value:CNPhoneNumber(stringValue : phone))]
        
        //        let homeAddress = CNMutablePostalAddress()
        //        homeAddress.street = "1 Infinite Loop"
        //        homeAddress.city = "Cupertino"
        //        homeAddress.state = "CA"
        //        homeAddress.postalCode = "95014"
        //        contact.postalAddresses = [CNLabeledValue(label:CNLabelHome, value:homeAddress)]
        //
        //        let birthday = NSDateComponents()
        //        birthday.day = 1
        //        birthday.month = 4
        //        birthday.year = 1988  // You can omit the year value for a yearless birthday
        //        contact.birthday = birthday as DateComponents
        
        
        
        
        // Saving the newly created contact
        let store = CNContactStore()
        
        store.requestAccess(for: .contacts) { (granted, error) in
            if let error = error {
                print("Failed : ", error)
                return
            }
            
            if granted {
                print("Access granted")
                let saveRequest = CNSaveRequest()
                saveRequest.add(contact, toContainerWithIdentifier:nil)
                do {
                    try store.execute(saveRequest)
                    print("Saved")
                }catch let error{
                    print(error)
                }
            } else {
                print("Access denied")
            }
        }
        
        
    }

}

