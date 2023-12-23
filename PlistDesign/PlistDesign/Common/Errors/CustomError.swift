//
//  CustomError.swift
//  PlistDesign
//
//  Created by Sajib Ghosh on 21/12/23.
//

import Foundation
enum CustomError: Error{
    case invalidURL
    case invalidResponse
    case invalidData
    case mockError
    var description: String {
        switch self{
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid Response"
        case .invalidData:
            return "Invalid Data"
        case .mockError:
            return "Mock Error"
        }
    }
}
