//
//  NetworkService.swift
//  PlistDesign
//
//  Created by Sajib Ghosh on 21/12/23.
//

import Foundation
protocol NetworkHandler{
    func fetchData<T:Decodable>(for: T.Type, from url: String) async throws ->T
}
class NetworkService: NetworkHandler {
    
    func fetchData<T : Decodable>(for: T.Type, from url: String) async throws -> T {
        
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


