//
//  Contact.swift
//  startUp
//
//  Created by Jahongir Nematov on 3/6/18.
//  Copyright © 2018 Jahongir Nematov. All rights reserved.
//

import Foundation

struct UserData {
    
    var name : String?
    var familyName : String?
    var phoneNumber : String?
    var emailAddresses : emailAddresses?
    var homeAddress : homeAddress?
    var birthday : birthday?
    
    
    struct emailAddresses {
        var workEmail : String?
        var homeEmail : String?
    }
    
    struct homeAddress {
        var street : String?
        var city : String?
        var state : String?
        var postalCode : String?
    }
    
    struct birthday {
        var day : Int?
        var month : Int?
        var year : Int?
    }

}
