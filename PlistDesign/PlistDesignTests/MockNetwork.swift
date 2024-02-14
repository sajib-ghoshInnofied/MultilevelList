//
//  MockNetwork.swift
//  PlistDesignTests
//
//  Created by Sajib Ghosh on 24/12/23.
//

import Foundation
@testable import PlistDesign

class MockNetwork: NetworkHandler {
    var shouldReturnError = false
    @available(iOS 15.0, *)
    func fetchData<T>(for: T.Type, from url: String) async throws -> T where T : Decodable {
        if shouldReturnError{
            throw CustomError.mockError
        }
        guard let url = URL(string: url) else {
            throw CustomError.invalidURL
        }
        let config = URLSessionConfiguration.default
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        let session = URLSession(configuration: config)
        let (data,response) = try await session.data(from: url)
        do{
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                throw CustomError.invalidResponse
            }
            do{
                let decoder = PropertyListDecoder()
                return try decoder.decode(T.self, from: data)
            }catch{
                throw CustomError.invalidData
            }
        } catch(let error) {
            throw error
        }
    }
    
}
