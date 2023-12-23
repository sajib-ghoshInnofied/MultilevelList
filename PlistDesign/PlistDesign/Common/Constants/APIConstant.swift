//
//  APIConstant.swift
//  PlistDesign
//
//  Created by Sajib Ghosh on 21/12/23.
//

import Foundation
class APIConstant{
    static let shared = APIConstant()
    private init(){
    }
    let plistURL = "https://appconfig-be7f37.firebaseapp.com/anzapp/plist/dwic_general_configuration.plist"
}
